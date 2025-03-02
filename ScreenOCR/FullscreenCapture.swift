import Carbon

class FullscreenCapture {
		func captureScreenshotToClipboard() {
				print("Capturing full screen and copying to clipboard...")
				
				let task = Process()
				task.launchPath = "/usr/sbin/screencapture"
				task.arguments = ["-c", "-x"]
				// Launch the process asynchronously
				task.launch()
		}
}
