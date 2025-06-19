//
//  ConfettiView.swift
//  HandSign
//
//  Overlay confetti 3 detik memakai CAEmitterLayer
//

import SwiftUI

struct ConfettiView: UIViewRepresentable {

    let duration: TimeInterval = 3.0     // lama animasi

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        // --- konfigurasi partikel ---
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 2)

        // warna‐warna kertas
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen,
                                 .systemOrange, .systemPink, .systemYellow]

        var cells: [CAEmitterCell] = []
        for color in colors {
            let cell = CAEmitterCell()
            cell.birthRate = 6
            cell.lifetime  = 5
            cell.velocity  = 180
            cell.velocityRange = 60
            cell.spin = 4
            cell.spinRange = 4
            cell.scale = 0.6
            cell.scaleRange = 0.3
            cell.emissionRange = .pi
            cell.color = color.cgColor
            cell.contents = UIImage(systemName: "rectangle.fill")?
                .withTintColor(color, renderingMode: .alwaysOriginal)
                .cgImage
            cells.append(cell)
        }
        emitter.emitterCells = cells
        view.layer.addSublayer(emitter)

        // hentikan emisi setelah `duration` detik
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            emitter.birthRate = 0
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
