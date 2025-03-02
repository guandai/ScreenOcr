import Cocoa
import Carbon

//@main
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("✅ ScreenOCR Started")
        print("✅ ScreenOCR Started")

        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)

        registerGlobalHotKey(
                    key: "6",
                    modifiers: ["ctrl", "cmd", "shift"]
                )
        
        MenuBar(statusItem: statusItem).createMenuBarIcon()
    }
}
