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
        if let cbMapUnwrapped = cbMap {
            registerCombines(rs: rs, cbMap: cbMapUnwrapped)
        }
    }
    
    func registerCombines(rs: RegisterShortcut, cbMap: CbMap ){
        rs.registerGlobalHotKey(
            key: "6",
            modifiers: ["cmd", "shift"],
            callback: cbMap["run"] ?? {},
            hotKeyIDNumber: 1001
        )
        
        rs.registerGlobalHotKey(
            key: "7",
            modifiers: ["cmd", "shift"],
            callback: cbMap["setting"] ?? {},
            hotKeyIDNumber: 1002
        )
    }
}
