import Cocoa
import Carbon

//@main
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var statusItem: NSStatusItem?
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("✅ ScreenOCR Started")
        print("✅ ScreenOCR Started")

        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)

        registerGlobalShortcut()
        createMenuBarIcon()
    }

    func createMenuBarIcon() {
        // Create a status bar item with variable length
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            // You can set an icon, title, or both.
            // This example just sets text:
            button.title = "SO"
            // If you want an image instead:
            // button.image = NSImage(systemSymbolName: "doc.text.magnifyingglass", accessibilityDescription: "OCR App")
            button.action = #selector(didTapStatusBarIcon)
        }

        // Create a simple menu if you want to control the app from the icon
        let menu = NSMenu()
        menu.addItem(
            NSMenuItem(
                title: "Quit",
                action: #selector(quitApp),
                keyEquivalent: "q"
            )
        )
        statusItem?.menu = menu
    }

    @objc func didTapStatusBarIcon() {
        // This is called if the user clicks the icon
        // (if no menu is assigned, or if you handle this differently)
        print("Status bar icon clicked.")
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
