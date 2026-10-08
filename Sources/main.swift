import AppKit
import OSLog

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Keep the application alive while deletion runs, without blocking AppKit.
        DispatchQueue.global(qos: .userInitiated).async {
            let result = TrashCleaner.empty(directories: TrashCleaner.trashDirectories())
            let logger = Logger(subsystem: "com.pouriaalmassi.emptytrash", category: "Cleaning")
            logger.info("Removed \(result.removed) trash items; \(result.failures.count) failures")
            for failure in result.failures {
                logger.error("\(failure, privacy: .public)")
            }
            DispatchQueue.main.async { NSApplication.shared.terminate(nil) }
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
