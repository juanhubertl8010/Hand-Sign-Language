//
//  NZHandPathView.swift
//  Hand Sign Language
//
//  Created by Juan Hubert Liem on 20/06/25.
//

import SwiftUI
import AVFoundation

struct NZHandPathView: View {
    let letters: [String] = Array("NOPQRSTUVWXYZ").map { String($0) }

    @State private var currentIndex: Int = 0
    @State private var detectionStatus: String = "Menginisialisasi kamera…"
    @State private var detections: [Detection] = []
    @State private var showConfetti = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                
                // Kamera + ML
                ScannerView(detectionStatus: $detectionStatus,
                            detections:       $detections,
                            words:            .constant("NOPQRSTUVWXYZ"),
                            currentIndex:     $currentIndex)

                // Kotak Deteksi
                DrawingView(detections: $detections, viewSize: .constant(geo.size))

                // ------- UI overlay -------
                VStack(spacing: 20) {
                    
                    // Gambar huruf saat ini
                    if currentIndex < letters.count {
                        let currentChar = letters[currentIndex]
                        
                        Image(currentChar)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.3))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.8), lineWidth: 4)
                            )
                            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)
                            .padding(.bottom, 4)
                        
                        // Tambahan teks huruf yang sedang dikerjakan
                        Text("\(currentChar)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                    }

                    // Status deteksi
                    Text(detectionStatus)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5)
                }
                .padding(.bottom, 30)

                if showConfetti {
                    ConfettiView()
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
            .onChange(of: currentIndex) { newValue in
                if newValue == letters.count {
                    detectionStatus = "🎉 Selesai semua huruf!"
                    showConfetti = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showConfetti = false
                        currentIndex = 0
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    NZHandPathView()
}
