import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    let ocrProcessor = OCRProcessor()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("Application started: OCR Clipboard App")
        registerShortcut()
    }

    func registerShortcut() {
        NSLog("Registering global keyboard shortcut for Cmd+Shift+6")
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (event) in
            NSLog("Key event detected: \(event.keyCode)")

            if event.modifierFlags.contains(.command) &&
                event.modifierFlags.contains(.shift) &&
                event.keyCode == 0x17 { // Keycode 0x17 = 6 key
                NSLog("Cmd+Shift+6 detected. Initiating screenshot capture...")
                self.captureScreenshotAndProcessOCR()
            }
        }
    }

    func captureScreenshotAndProcessOCR() {
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-c", "-x"] // -c: Copy to clipboard, -x: No sound

        NSLog("Running screencapture command: /usr/sbin/screencapture -c -x")
        task.launch()
        task.waitUntilExit()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NSLog("Checking clipboard for image...")
            if let image = self.getClipboardImage() {
                NSLog("Image found in clipboard. Passing to OCR processor...")
                self.ocrProcessor.performOCR(on: image)
            } else {
                NSLog("Failed to retrieve image from clipboard. No image detected.")
            }
        }
    }

    func getClipboardImage() -> NSImage? {
        if let imageData = NSPasteboard.general.data(forType: .tiff) {
            NSLog("Clipboard contains TIFF image data.")
            return NSImage(data: imageData)
        }
        NSLog("No image data found in clipboard.")
        return nil
    }
}
