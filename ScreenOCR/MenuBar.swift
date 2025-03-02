import Cocoa
import Carbon

class MenuBar: NSObject {
    // Create a status item and store it as a property
    var statusItem: NSStatusItem? = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func createMenuBarIcon() {
    // Create a status bar item with variable length
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    if let button = statusItem?.button {
        // Set a text title or an image for the menu bar icon
        button.title = "SO"
        // Set the button's target if you have an action
        button.action = #selector(didTapStatusBarIcon)
        button.target = self
    }
    
    // Create a simple menu for the status item
    let menu = NSMenu()
    let quitItem = NSMenuItem(
        title: "Quit",
        action: #selector(quitApp),
        keyEquivalent: "q"
    )
    // Set the target for the quit item so that the action is properly routed
    quitItem.target = self
    menu.addItem(quitItem)
    
    statusItem?.menu = menu
}

    
    @objc func didTapStatusBarIcon() {
        print("Status bar icon clicked.")
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
