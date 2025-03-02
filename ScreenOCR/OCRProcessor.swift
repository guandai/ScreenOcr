import AppKit
import Vision

class OCRProcessor {
    func performOCR(on image: NSImage) {
        NSLog("performOCR")
        print("Starting OCR process...")

        guard let imageData = image.tiffRepresentation,
            let ciImage = CIImage(data: imageData) else {
            print("Failed to convert NSImage to CIImage.")
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("OCR Error: \(error.localizedDescription)")
                return
            }

            guard let results = request.results as? [VNRecognizedTextObservation] else {
                print("OCR failed to retrieve recognized text.")
                return
            }

            let recognizedText = results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            print("OCR Result:\n\(recognizedText)")

            DispatchQueue.main.async {
                self.updateClipboard(with: recognizedText)
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US"] // English OCR

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
            print("OCR processing completed successfully.")
        } catch {
            print("Failed to perform OCR: \(error.localizedDescription)")
        }
    }

    private func updateClipboard(with text: String) {
        NSLog("updateClipboard")
        if text.isEmpty {
            print("OCR did not return any text. Skipping clipboard update.")
            return
        }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        print("Updated Clipboard with OCR Text:\n\(text)")
    }
}
