import Cocoa

class SettingsControl: NSWindowController {
    let quitButton = NSButton()
    var wraps: [BtnWrapper] = []
    
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
        let label = NSTextField(labelWithString: "Enter new keyId combination (e.g. cmd+shift+6):")
        label.frame = NSRect(x: 20, y: 160, width: 360, height: 26)
        cv.addSubview(label)
        
        let addFields = AddFields(rs: rs, cbMap: cbMap)
    
        addFields.addChangeKey(cv: cv, keyName: "setting" , title: "Setting Shortcut", wraps: &wraps)
        addFields.addChangeKey(cv: cv, keyName: "run", title: "Run Shortcut", wraps: &wraps)

        addFields.addBtn(cv: cv, title: "Quit Application", action: quitApp, wraps: &wraps, x: 20, y: 20, w: btnW, h: btnH)
    }
    
    func quitApp() {
        print(1)
        NSApplication.shared.terminate(nil)
    }
}
