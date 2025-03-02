import Cocoa
import Carbon

//@main
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var statusItem: NSStatusItem?
    var menuBar: MenuBar?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("✅ ScreenOCR Started")

        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)

        RegisterShortcut().registerGlobalHotKey(
            key: "6",
            modifiers: ["ctrl", "cmd", "shift"],
            callback: FullscreenCapture().runAll
        )
        
        menuBar = MenuBar()
        menuBar?.createMenuBarIcon()
    }
}
