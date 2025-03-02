import Cocoa
import Carbon

class MenuBar {
    func createMenuBarIcon( statusItem: NSStatusItem? ) {

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
