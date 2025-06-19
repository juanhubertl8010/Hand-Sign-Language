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
            let rectLayer = createRoundedRectLayer(with: objectBounds)
            let labelLayer = createTextLayer(in: uiView.bounds, for: objectBounds, text: detection.label)
            
            // 4. Susun layer: label di dalam kotak (sama seperti `rectLayer.addSublayer(labelLayer)`).
            rectLayer.addSublayer(labelLayer)
            
            // 5. Tambahkan layer kotak utama ke kanvas.
            uiView.layer.addSublayer(rectLayer)
        }
    }
    
    // MARK: - Helper Functions (Meniru Kode Lama)

    /// Membuat CALayer untuk kotak pembatas, sama persis dengan 'createRoundedRectLayerWithBounds'.
    private func createRoundedRectLayer(with bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.35).cgColor
        shapeLayer.cornerRadius = 14
        return shapeLayer
    }
    
    /// Membuat CATextLayer untuk label, sama persis dengan 'createTextSubLayerInBounds'.
    private func createTextLayer(in hostBounds: CGRect, for box: CGRect, text: String) -> CATextLayer {
        // a. Atur font & atribut
        let fontSize: CGFloat = 30
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: fontSize),
            .foregroundColor: UIColor.white
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        
        // b. Hitung ukuran label dengan padding
        let paddingX: CGFloat = 4
        let paddingY: CGFloat = 2
        var textRect = attributedText.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: fontSize * 1.4), options: .usesLineFragmentOrigin, context: nil)
        textRect.size.width = ceil(textRect.width) + paddingX * 2
        textRect.size.height = ceil(textRect.height) + paddingY * 2
        
        // c. Posisi label (di atas kotak) dengan logika clamping
        var origin = CGPoint(x: box.minX, y: box.minY - textRect.height - 2)
        
        // Kalau mentok atas, pindah ke dalam kotak
        if origin.y < 0 { origin.y = box.minY + 2 }
        
        // Kalau mentok kanan, geser ke kiri
        let maxX = hostBounds.width - textRect.width - 2
        if origin.x > maxX { origin.x = maxX }
        
        // Pastikan tidak keluar dari sisi kiri
        if origin.x < 0 { origin.x = 2 }
        
        // d. Bangun CATextLayer
        let textLayer = CATextLayer()
        textLayer.string = attributedText
        textLayer.frame = CGRect(origin: origin, size: textRect.size)
        textLayer.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
        textLayer.cornerRadius = 3
        textLayer.contentsScale = UIScreen.main.scale // Penting untuk display Retina
        
        return textLayer
    }
}
