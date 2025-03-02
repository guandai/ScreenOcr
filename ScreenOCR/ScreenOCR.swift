import Cocoa
import Carbon

@main
class AppDelegate: NSObject, NSApplicationDelegate {
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
            button.title = "ScreenOCR"
            // If you want an image instead:
            // button.image = NSImage(systemSymbolName: "doc.text.magnifyingglass", accessibilityDescription: "OCR App")
            button.action = #selector(didTapStatusBarIcon)
        }

        // Create a simple menu if you want to control the app from the icon
        let menu = NSMenu()
        menu.addItem(
            NSMenuItem(
                title: "Quit ScreenOCR",
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

    func registerGlobalShortcut() {
        NSLog("🔄 Registering global hotkey Ctrl + Cmd + Shift + 6")

        let keyCode: UInt32 = UInt32(kVK_ANSI_6)  // Key "6"
        let modifierFlags: UInt32 = UInt32(cmdKey | shiftKey | controlKey) // Ctrl + Cmd + Shift

        let hotKeyID = EventHotKeyID(signature: OSType(1234), id: 1)
        var hotKeyRef: EventHotKeyRef?

        let eventHandler: EventHandlerUPP = { (nextHandler, theEvent, userData) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout.size(ofValue: hotKeyID), nil, &hotKeyID)

            if hotKeyID.id == 1 {
                NSLog("🚀 Hotkey Ctrl + Cmd + Shift + 6 pressed!")
                print("🚀 Hotkey Ctrl + Cmd + Shift + 6 pressed!")
            }
            return noErr
        }

        let eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), eventHandler, 1, [eventType], nil, nil)

        let status = RegisterEventHotKey(keyCode, modifierFlags, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        
        if status == noErr {
            NSLog("✅ Hotkey registered successfully")
            print("✅ Hotkey registered successfully")
        } else {
            NSLog("❌ Failed to register hotkey. Error code: \(status)")
            print("❌ Failed to register hotkey. Error code: \(status)")
        }
    }
}
