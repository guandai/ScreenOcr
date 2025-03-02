import Carbon
import Cocoa

class FullscreenCapture {
		func runAll() {
			captureScreenshotToClipboard()
			// Wait for a moment to let the screenshot process complete.
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.processClipboardImageForOCR()
			}
		}

		func captureScreenshotToClipboard() {
				print("Capturing full screen and copying to clipboard...")
				
				let task = Process()
				task.launchPath = "/usr/sbin/screencapture"
				task.arguments = ["-c", "-x"]
				// Launch the process asynchronously
				task.launch()
		}



		func processClipboardImageForOCR() {
			guard let imageData = NSPasteboard.general.data(forType: .tiff) else {
					print("No image data found in clipboard.")
					return
			}
			
			// Unwrap the NSImage initializer as well
			guard let image = NSImage(data: imageData) else {
					print("Failed to create NSImage from data.")
					return
			}
			
			// Now you have a non-optional image to work with
			let ocrProcessor = OCRProcessor()
			ocrProcessor.performOCR(on: image)
		}
}
