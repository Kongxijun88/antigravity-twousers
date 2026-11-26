import Cocoa
import Carbon
import Foundation

struct AntigravityInstance {
    let id: String
    let label: String
    let pid: pid_t
    let sandboxHome: String
    let isSandboxed: Bool
}

class RouterAppDelegate: NSObject, NSApplicationDelegate {
    private var handledURL = false
    private let realHome = NSHomeDirectory()

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // If launched directly without a URL event, exit promptly after brief grace period
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            if self?.handledURL == false {
                if let target = self?.selectTargetInstance(verbose: false) {
                    self?.activate(instance: target, urlString: nil)
                }
                NSApp.terminate(nil)
            }
        }
    }

    @objc func handleGetURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        handledURL = true
        let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue

        if let target = selectTargetInstance(verbose: false) {
            activate(instance: target, urlString: urlString)
        } else {
            // No running Antigravity instance found: launch primary app
            let primaryURL = URL(fileURLWithPath: "/Applications/Antigravity.app")
            let config = NSWorkspace.OpenConfiguration()
            if let str = urlString, let deepLink = URL(string: str) {
                NSWorkspace.shared.open([deepLink], withApplicationAt: primaryURL, configuration: config, completionHandler: nil)
            } else {
                NSWorkspace.shared.openApplication(at: primaryURL, configuration: config, completionHandler: nil)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            NSApp.terminate(nil)
        }
    }

    // MARK: - Instance Discovery

    func discoverRunningInstances() -> [AntigravityInstance] {
        let runningApps = NSWorkspace.shared.runningApplications.filter { app in
            if app.bundleIdentifier == "com.google.antigravity" {
                return true
            }
            if let exePath = app.executableURL?.path,
               exePath.hasSuffix("/Antigravity.app/Contents/MacOS/Antigravity") {
                return true
            }
            return false
        }

        var instances: [AntigravityInstance] = []
        for app in runningApps {
            let pid = app.processIdentifier
            let args = readProcessArgs(pid: pid)

            if let sandboxHome = extractSandboxHome(from: args) {
                let dirName = (sandboxHome as NSString).lastPathComponent
                let id: String
                let label: String
                if dirName.contains("ultra") {
                    id = "ultra"
                    label = "Antigravity Ultra"
                } else if dirName.contains("pro2") {
                    id = "pro2"
                    label = "Antigravity Pro 2"
                } else {
                    id = dirName
                    label = "Antigravity (\(dirName))"
                }
                instances.append(AntigravityInstance(
                    id: id,
                    label: label,
                    pid: pid,
                    sandboxHome: sandboxHome,
                    isSandboxed: true
                ))
            } else {
                instances.append(AntigravityInstance(
                    id: "primary",
                    label: "Antigravity (Primary)",
                    pid: pid,
                    sandboxHome: realHome,
                    isSandboxed: false
                ))
            }
        }
        return instances
    }

    private func readProcessArgs(pid: pid_t) -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = ["-p", "\(pid)", "-o", "args="]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice
        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }

    private func extractSandboxHome(from args: String) -> String? {
        // Match --user-data-dir=<home>/Library/Application Support/Antigravity
        guard let range = args.range(of: "--user-data-dir=") else { return nil }
        let afterFlag = String(args[range.upperBound...])
        // Locate "/Library/Application Support"
        guard let libRange = afterFlag.range(of: "/Library/Application Support") else { return nil }
        let homePath = String(afterFlag[..<libRange.lowerBound]).trimmingCharacters(in: CharacterSet(charactersIn: "\"' "))
        if homePath.isEmpty || homePath == realHome {
            return nil
        }
        return homePath
    }

    // MARK: - Dual-Signal Target Selection

    func selectTargetInstance(verbose: Bool) -> AntigravityInstance? {
        let instances = discoverRunningInstances()
        if instances.isEmpty {
            if verbose { print("[Router] No running Antigravity instances found.") }
            return nil
        }
        if instances.count == 1 {
            if verbose { print("[Router] Only 1 instance running -> \(instances[0].label) (PID \(instances[0].pid))") }
            return instances[0]
        }

        // Signal 1: Check if any sandboxed instance's dedicated Keychain was modified in the last 15 seconds.
        // Because only that Antigravity instance writes to its own isolated login.keychain-db,
        // a fresh mtime within 15s is a high-confidence indicator that OAuth just completed there.
        let now = Date()
        var freshestSandbox: (instance: AntigravityInstance, date: Date)? = nil

        for inst in instances where inst.isSandboxed {
            let keychainPath = (inst.sandboxHome as NSString).appendingPathComponent("Library/Keychains/login.keychain-db")
            if let attrs = try? FileManager.default.attributesOfItem(atPath: keychainPath),
               let mdate = attrs[.modificationDate] as? Date {
                let age = now.timeIntervalSince(mdate)
                if verbose {
                    print(String(format: "[Router] Signal 1 (Keychain mtime): %@ (PID %d) -> %.1fs ago", inst.label, inst.pid, age))
                }
                if age >= -5 && age <= 15 {
                    if freshestSandbox == nil || mdate > freshestSandbox!.date {
                        freshestSandbox = (inst, mdate)
                    }
                }
            }
        }

        if let winner = freshestSandbox {
            if verbose { print("[Router] Selected via Signal 1 (Fresh Keychain write): \(winner.instance.label) (PID \(winner.instance.pid))") }
            return winner.instance
        }

        // Signal 2: macOS Window Z-Order (frontmost Antigravity window right behind the browser).
        let pidMap = Dictionary(uniqueKeysWithValues: instances.map { ($0.pid, $0) })
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        if let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] {
            for win in windowList {
                guard let layer = win[kCGWindowLayer as String] as? Int, layer == 0,
                      let pid = win[kCGWindowOwnerPID as String] as? Int32,
                      let matched = pidMap[pid] else {
                    continue
                }
                if verbose {
                    print("[Router] Selected via Signal 2 (Topmost Window Z-Order): \(matched.label) (PID \(matched.pid))")
                }
                return matched
            }
        }

        if verbose {
            print("[Router] Fallback to first running instance: \(instances[0].label) (PID \(instances[0].pid))")
        }
        return instances[0]
    }

    // MARK: - Precision Activation & Forwarding

    func activate(instance: AntigravityInstance, urlString: String?) {
        // 1. Bring the exact target instance PID to the foreground (requires zero TCC permissions)
        if let app = NSRunningApplication(processIdentifier: instance.pid) {
            app.unhide()
            if #available(macOS 14.0, *) {
                app.activate(options: [.activateAllWindows])
            } else {
                app.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
            }
        }

        // 2. If the antigravity:// URL carries a meaningful deep-link payload (beyond bare scheme),
        //    forward the GURL AppleEvent directly to that exact PID.
        if let rawURL = urlString, hasDeepLinkPayload(rawURL) {
            forwardURLEvent(rawURL, toPID: instance.pid)
        }
    }

    private func hasDeepLinkPayload(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        let host = url.host ?? ""
        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let query = url.query ?? ""
        return !host.isEmpty || !path.isEmpty || !query.isEmpty
    }

    private func forwardURLEvent(_ urlString: String, toPID pid: pid_t) {
        var targetPID = pid
        var targetDesc = AEDesc()
        guard AECreateDesc(typeKernelProcessID, &targetPID, MemoryLayout<pid_t>.size, &targetDesc) == noErr else {
            return
        }
        defer { AEDisposeDesc(&targetDesc) }

        var appleEvent = AppleEvent()
        guard AECreateAppleEvent(
            AEEventClass(kInternetEventClass),
            AEEventID(kAEGetURL),
            &targetDesc,
            AEReturnID(kAutoGenerateReturnID),
            AETransactionID(kAnyTransactionID),
            &appleEvent
        ) == noErr else {
            return
        }
        defer { AEDisposeDesc(&appleEvent) }

        let urlData = Array(urlString.utf8)
        guard AEPutParamPtr(&appleEvent, keyDirectObject, typeUTF8Text, urlData, urlData.count) == noErr else {
            return
        }

        var reply = AppleEvent()
        _ = AESendMessage(&appleEvent, &reply, AESendMode(kAENoReply), 1000)
    }
}

// MARK: - CLI Diagnostics Mode & App Entry Point

let cliArgs = CommandLine.arguments
if cliArgs.contains("--status") || cliArgs.contains("--test") {
    let delegate = RouterAppDelegate()
    let instances = delegate.discoverRunningInstances()
    print("=== Antigravity Smart URL Router Diagnostics ===")
    print("Running instances (\(instances.count)):")
    for inst in instances {
        print("  - \(inst.label) | PID=\(inst.pid) | sandbox=\(inst.isSandboxed ? inst.sandboxHome : "default")")
    }
    if let chosen = delegate.selectTargetInstance(verbose: true) {
        print("=> Active route target: \(chosen.label) (PID \(chosen.pid))")
    } else {
        print("=> No running instance (would launch /Applications/Antigravity.app)")
    }
    exit(0)
}

let app = NSApplication.shared
let delegate = RouterAppDelegate()
app.delegate = delegate
app.setActivationPolicy(.prohibited)
app.run()
