import Cocoa
import Carbon

typealias CbMap = [String: HotKeyCallback]

class MenuBar: NSObject {
    // Create and retain the status item
    var statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var rs: RegisterShortcut
    var cbMap: CbMap = [:]
    private var settingsWindowController: SettingsWindowController?

    func terminate() {
        NSApplication.shared.terminate(nil)
    }
    
    init(rs: RegisterShortcut) {
        self.rs = rs
    }
    
    func createMenuBarIcon() {
        createIcon()
        createMenu()
    }
    
    func createIcon() {
        if let iconBtn = statusItem.button {
            // Instead of setting a text title, assign an image.
            // "MenuIcon" should be the name of your image asset (PNG or PDF) in your Assets.xcassets.
            if let icon = NSImage(named: "MenuIcon") {
                iconBtn.image = icon
            } else {
                iconBtn.title = "SO"
                print("Failed to load MenuIcon asset")
            }
            iconBtn.action = #selector(didTapStatusBarIcon)
            iconBtn.target = self
        }
    }
    func createMenu() {
        // Create a menu and add items
        let menu = NSMenu()

        // Add "Settings" menu item
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: "s")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        // Add a separator (optional)
        menu.addItem(NSMenuItem.separator())
        
        // Add "Quit" menu item
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
//    func getCbMap
    func getCbMap() -> [String: () -> Void] {
        self.cbMap = [
            "run": FullscreenCapture().runAll,
            "quit": terminate,
            "setting": openSettings  // Now it can reference openSettings safely
        ]
        
        return cbMap
    }

    @objc func didTapStatusBarIcon() {
        print("Status bar icon clicked.")
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func openSettings() {
        // If the settings window already exists, just bring it to the front
        if let controller = settingsWindowController {
            controller.showWindow(nil)
            controller.window?.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
            return
        }

        // Otherwise, create a new instance and store it
        settingsWindowController = SettingsWindowController(rs: rs, cbMap: cbMap)
        settingsWindowController?.showWindow(nil)

        if let window = settingsWindowController?.window, let screen = NSScreen.main {
            let screenRect = screen.frame
            let windowRect = window.frame
            let centerX = (screenRect.width - windowRect.width) / 2
            let centerY = (screenRect.height - windowRect.height) / 2
            window.setFrameOrigin(NSPoint(x: centerX, y: centerY))
        }

        NSApplication.shared.activate(ignoringOtherApps: true) // Bring to front
    }
}
