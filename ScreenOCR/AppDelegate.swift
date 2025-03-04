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
            let updateKey = UpdateHotKey(rs: rs, cbMap: cbMapSafe)
            updateKey.registerNewKeys(keyName: "run", keyPart: "6", modifiers: ["cmd", "shift"])
            updateKey.registerNewKeys(keyName: "setting", keyPart: "7", modifiers: ["cmd", "shift"] )
        }
    }
}
