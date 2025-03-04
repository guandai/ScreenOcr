import Cocoa
import Carbon

//enum CbKey: String {
//    case run = "run"
//    case setting = "setting"
//    case quit = "quit"
//}

//@main
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var statusItem: NSStatusItem?
    var menuBar: MenuBar?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("✅ ScreenOCR Started")

        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.setActivationPolicy(.accessory)
        NSApplication.shared.activate(ignoringOtherApps: true)

        let rs = RegisterShortcut()
        
        
        menuBar = MenuBar(rs: rs)
        menuBar?.createMenuBarIcon()
        
        let cbMap = menuBar?.getCbMap()
        if let cbMapSafe = cbMap {
            UpdateHotKey.initialize(rs: RegisterShortcut(), cbMap: cbMapSafe)
            UpdateHotKey.shared().registerNewKeys(keyName: "run", keyPart: "6", modifiers: ["cmd", "shift"])
            UpdateHotKey.shared().registerNewKeys(keyName: "setting", keyPart: "7", modifiers: ["cmd", "shift"] )
        }
    }
}
