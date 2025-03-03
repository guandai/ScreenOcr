import Cocoa

class SettingsWindowController: NSWindowController {

    let quitButton = NSButton()
    var btnActions: [BtnWrapper] = []
    
    var rs: RegisterShortcut
    var cbMap: CbMap

    init(rs: RegisterShortcut, cbMap: CbMap) {
        self.rs = rs
        self.cbMap = cbMap
        
        // Create a new window instance
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        settingsWindow.title = "Settings"

        // Call the designated initializer of NSWindowController
        super.init(window: settingsWindow)

        // Setup the UI elements
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    func setupUI() {
        guard let cv = window?.contentView else { return }
        
        // Label for instructions
        let label = NSTextField(labelWithString: "Enter new hotkey combination (e.g. cmd+shift+6):")
        label.frame = NSRect(x: 20, y: 160, width: 360, height: 24)
        cv.addSubview(label)
        
        addChangeKeyGroup(cv: cv, name: "setting" , title: "Change Setting Key" )
        addChangeKeyGroup(cv: cv, name: "run", title: "Change Run Key" )

        addBtn(cv: cv, title: "Quit Application", action: quitApp, x: 20, y: 20, w: btnW, h: btnH)
    }
    
    func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    func updateHotkey(name: String, tf: NSTextField) {
        let keyStr = tf.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if keyStr.isEmpty {
            print("No hotkey combination entered.")
            return
        }
        
        print("Changing hotkey to: \(keyStr)")
        // Split the input string by '+'.
        // The last element is assumed to be the key, the rest are modifiers.
        let parts = keyStr.split(separator: "+").map { String($0).lowercased() }
        guard let keyPart = parts.last else {
            print("Invalid hotkey combination.")
            return
        }

        let modifiers = parts.dropLast().map { String($0) }
        print("Registering hotkey with key: \(keyPart) and modifiers: \(modifiers)")
        
        if let oldHotkey = hotkeyMap[name] {
            rs.unregisterGlobalHotKey(oldHotkey)
        }

        // Register the new hotkey
        let newHotkey = rs.registerGlobalHotKey(
            key: keyPart,
            modifiers: Array(modifiers),
            callback: cbMap[name] ?? {},
            hotKeyIDNumber: 1
        )

        // Store the new hotkey reference
        hotkeyMap[name] = newHotkey
        
    }

}
