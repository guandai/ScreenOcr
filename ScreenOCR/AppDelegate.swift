import Cocoa
import Carbon

//@main
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
//    var statusItem: NSStatusItem?
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("✅ ScreenOCR Started")
        print("✅ ScreenOCR Started")

        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)

        registerGlobalShortcut()
        MenuBar().createMenuBarIcon(statusItem)
    }


}
