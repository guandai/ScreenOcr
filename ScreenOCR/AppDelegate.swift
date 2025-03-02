import AppKit
import Vision

class ClipboardMonitor {
    private var lastImageHash: Int?

    init() {
        startMonitoring()
    }

    func startMonitoring() {
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(checkClipboard), userInfo: nil, repeats: true)
    }

    @objc private func checkClipboard() {
        if let image = getClipboardImage() {
            let currentHash = image.hashValue
            if lastImageHash != currentHash {
                lastImageHash = currentHash
                performOCR(on: image)
            }
        }
    }

    private func getClipboardImage() -> NSImage? {
        if let imageData = NSPasteboard.general.data(forType: .tiff),
           let image = NSImage(data: imageData) {
            return image
        }
        return nil
    }

    private func performOCR(on image: NSImage) {
        guard let imageData = image.tiffRepresentation,
              let ciImage = CIImage(data: imageData) else { return }

        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("OCR Error: \(error.localizedDescription)")
                return
            }

            guard let results = request.results as? [VNRecognizedTextObservation] else { return }
            let recognizedText = results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")

            DispatchQueue.main.async {
                self.updateClipboard(with: recognizedText)
            }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform OCR: \(error)")
        }
    }

    private func updateClipboard(with text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        print("Updated Clipboard with OCR Text:\n\(text)")
    }
}
