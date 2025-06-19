//
//  DrawingView.swift
//  HandSign
//
//  File ini bertugas menggambar kotak dan label, meniru proses render CALayer dari app lama.
//

import SwiftUI
import Vision

struct DrawingView: UIViewRepresentable {
    
    @Binding var detections: [Detection]
    @Binding var viewSize: CGSize
    
    // Fungsi ini hanya dipanggil sekali untuk membuat UIView kosong sebagai kanvas.
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isOpaque = false // Buat transparan agar kamera di belakangnya terlihat.
        return view
    }
    
    // Fungsi ini dipanggil setiap kali @Binding 'detections' berubah.
    func updateUIView(_ uiView: UIView, context: Context) {
        // 1. Hapus semua gambar lama (sama seperti `detectionOverlay.sublayers = nil`).
        uiView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // 2. Loop melalui setiap deteksi dan gambar yang baru.
        for detection in detections {
            let objectBounds = detection.boundingBox
            
            // 3. Panggil fungsi helper yang meniru kode lama Anda.
            let rectLayer = createRoundedRectLayer(with: objectBounds, containerHeight: uiView.bounds.height)
            let labelLayer = createTextLayer(           // ➜ tak butuh hostBounds/container lagi
                boxSize: objectBounds.size,
                text: detection.label)
            
            // 4. Susun layer: label di dalam kotak (sama seperti `rectLayer.addSublayer(labelLayer)`).
            rectLayer.addSublayer(labelLayer)
            
            // 5. Tambahkan layer kotak utama ke kanvas.
            uiView.layer.addSublayer(rectLayer)
        }
    }
    
    // MARK: - Helper Functions (Meniru Kode Lama)

    /// Membuat CALayer untuk kotak pembatas, sama persis dengan 'createRoundedRectLayerWithBounds'.
    /// Kotak pembatas. `containerHeight` = tinggi UIView kanvas.
    private func createRoundedRectLayer(with rect: CGRect,
                                        containerHeight: CGFloat) -> CALayer {

        let layer = CALayer()

        // a. Ukuran layer = ukuran kotak
        layer.bounds = CGRect(origin: .zero, size: rect.size)

        // b. Balik sumbu-Y ➜ y' = H − midY
        let invertedY = containerHeight - rect.midY
        layer.position = CGPoint(x: rect.midX, y: invertedY)

        layer.name            = "Found Object"
        layer.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.35).cgColor
        layer.cornerRadius    = 14
        return layer
    }

    /// Label persis di atas kotak (koordinat INTERNAL kotak)
    private func createTextLayer(boxSize: CGSize, text: String) -> CATextLayer {

        // 1. Atribut teks
        let fontSize: CGFloat = 30
        let attr: [NSAttributedString.Key: Any] = [
            .font           : UIFont.boldSystemFont(ofSize: fontSize),
            .foregroundColor: UIColor.white
        ]
        let textAttr = NSAttributedString(string: text, attributes: attr)

        // 2. Ukuran label + padding
        let padX: CGFloat = 4, padY: CGFloat = 2
        var tRect = textAttr.boundingRect(with: .init(width: .greatestFiniteMagnitude,
                                                      height: fontSize * 1.4),
                                          options: .usesLineFragmentOrigin,
                                          context: nil)
        tRect.size.width  = ceil(tRect.width)  + padX * 2
        tRect.size.height = ceil(tRect.height) + padY * 2

        // 3. Posisi: horizontal tengah, 2 pt di atas kotak
        let x = max(2, (boxSize.width  - tRect.width ) / 2)
        let y = -tRect.height - 2                       // negatif ⇒ di atas

        // 4. Bangun layer
        let tl = CATextLayer()
        tl.string        = textAttr
        tl.frame         = CGRect(origin: .init(x: x, y: y), size: tRect.size)
        tl.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
        tl.cornerRadius    = 3
        tl.contentsScale   = UIScreen.main.scale
        return tl
    }

}
