import SwiftUI
import ARKit
import Vision

struct Detection: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float
    let boundingBox: CGRect
}

struct ScannerView: UIViewControllerRepresentable {

    @Binding var detectionStatus: String
    @Binding var detections: [Detection]
    @Binding var words: String
    @Binding var currentIndex: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        context.coordinator.setupARScene(in: vc)
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        private var predictionBuffer: [String] = []
        private let predictionWindow = 5
        private let requiredVotes = 3

        let parent: ScannerView
        var sceneView: ARSCNView!
        var visionModel: VNCoreMLModel!
        var detectionRequest: VNCoreMLRequest!
        var currentOrientation: CGImagePropertyOrientation = .right
        var lastObservations: [VNRecognizedObjectObservation] = []
        var rollState: RollState = .other

        enum RollState { case started, ended, other }

        init(_ parent: ScannerView) {
            self.parent = parent
            super.init()
            setupModel()
        }

        func setupARScene(in vc: UIViewController) {
            sceneView = ARSCNView(frame: vc.view.bounds)
            sceneView.delegate = self
            sceneView.session.delegate = self
            sceneView.scene = SCNScene()
            vc.view.addSubview(sceneView)

            let config = ARWorldTrackingConfiguration()
            sceneView.session.run(config)

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(orientationChanged),
                name: UIDevice.orientationDidChangeNotification,
                object: nil
            )
            orientationChanged()
        }

        func setupModel() {
            do {
                let ml = try SignLanguage(configuration: .init()).model
                let model = try VNCoreMLModel(for: ml)
                model.featureProvider = ThresholdProvider()
                visionModel = model
                detectionRequest = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
                    self?.handleDetections(request: request, error: error)
                }
                detectionRequest.imageCropAndScaleOption = .scaleFill
            } catch {
                DispatchQueue.main.async {
                    self.parent.detectionStatus = "❌ Gagal memuat model"
                }
            }
        }

        @objc func orientationChanged() {
            switch UIDevice.current.orientation {
            case .portrait: currentOrientation = .right
            case .landscapeLeft: currentOrientation = .down
            case .landscapeRight: currentOrientation = .up
            case .portraitUpsideDown: currentOrientation = .left
            default: break
            }
        }

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage,
                                                orientation: currentOrientation,
                                                options: [:])
            try? handler.perform([detectionRequest])
        }

        func handleDetections(request: VNRequest, error: Error?) {
            guard let observations = request.results as? [VNRecognizedObjectObservation] else { return }

            if observations.isEmpty {
                DispatchQueue.main.async {
                    self.parent.detections.removeAll()
                    self.parent.detectionStatus = "Arahkan ke tangan…"
                }
                lastObservations = []
                rollState = .other
                return
            }

            var newDetections: [Detection] = []

            for obs in observations where obs.confidence > 0.6 {
                guard let label = obs.labels.first else { continue }

                // Ubah bounding box normal ke frame AR
                let screenRect = VNImageRectForNormalizedRect(obs.boundingBox,
                                                              Int(sceneView.frame.width),
                                                              Int(sceneView.frame.height))
                newDetections.append(
                    Detection(label: label.identifier.uppercased(),
                              confidence: label.confidence,
                              boundingBox: screenRect)
                )
            }

            rollState = hasRollEnded(observations: observations) ? .ended : .started

            DispatchQueue.main.async {
                self.parent.detections = newDetections

                if self.rollState == .ended,
                   self.parent.currentIndex < self.parent.words.count {

                    let word = self.parent.words.uppercased()
                    let index = word.index(word.startIndex, offsetBy: self.parent.currentIndex)
                    let targetChar = String(word[index])

                    if newDetections.map({ $0.label }).contains(targetChar) {
                        self.parent.currentIndex += 1
                        if self.parent.currentIndex == word.count {
                            self.parent.detectionStatus = "✅ Kata selesai!"
                        } else {
                            self.parent.detectionStatus = "✓ '\(targetChar)' benar"
                        }
                        return
                    }
                }

                self.parent.detectionStatus =
                    self.rollState == .ended ? "Terdeteksi stabil" : "Mencari kestabilan…"
            }

            lastObservations = observations
        }

        func hasRollEnded(observations: [VNRecognizedObjectObservation]) -> Bool {
            if lastObservations.count != observations.count { return false }

            var matchCount = 0
            for newObs in observations {
                for oldObs in lastObservations {
                    if newObs.labels.first?.identifier == oldObs.labels.first?.identifier,
                       intersectionOverUnion(oldObs.boundingBox, newObs.boundingBox) > 0.7 {
                        matchCount += 1
                        break
                    }
                }
            }
            return matchCount == observations.count
        }

        func intersectionOverUnion(_ a: CGRect, _ b: CGRect) -> Float {
            let inter = a.intersection(b)
            let union = a.union(b)
            return union.isEmpty ? 0 : Float(inter.width * inter.height / union.width / union.height)
        }
    }
}
