import SwiftUI

@main
struct ScreenOCR: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var hasFullDiskAccess = PermissionsManager().checkFullDiskAccess()

    init() {
        print("start ...A")
        ensureSingleInstance()
    }

    var body: some Scene {
//        Settings {
//            // We won’t show a normal window.
//            // Put an empty Settings scene so there's something in the .app "scenes".
//            Text("")
//        }
        
        WindowGroup("Drop To PDF", id: "MainWindow") {
            if hasFullDiskAccess {
                EmptyView() // ✅ Show drop area if FDA is granted
            } else {
                FDAView()
            }
        }
        .environmentObject(appDelegate)
        .handlesExternalEvents(matching: ["*"])
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { } // Hide "New Window" option
        }
    }


    /// Ensures that only a single instance of the app runs
    private func ensureSingleInstance() {
        print("start ...B")
        let bundleIdentifier = Bundle.main.bundleIdentifier!
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)

        if runningApps.count > 1 {
            NSApplication.shared.terminate(nil)
        }
    }
}
