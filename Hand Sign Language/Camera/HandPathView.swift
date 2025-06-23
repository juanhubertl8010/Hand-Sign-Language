import SwiftUI
import AVFoundation

struct HandPathView: View {
    
    // ------- State utama -------
    @State private var detectionStatus = "Menginisialisasi kamera…"
    @State private var detections: [Detection] = []
    
    @State private var cameraPosition: AVCaptureDevice.Position = .back
    
    // Kata target & posisi huruf saat ini

    @State private var wordSelections: [String] = [
        "AYAH", "IBU", "LAVA", "BAWA", "BIAYA",
        "BAYI", "CAHAYA", "COBA", "CABAI", "GAYA",
        "GAIB", "WABAH", "YOYO", "VIVA", "BAHAYA",
        "GAGAH", "GOYAH", "GIGI", "BOLA", "LAGI",
        "HALO", "CARI", "AYO", "GOA", "BABI"
    ]
    @State private var words: String = ""
    @State private var currentIndex: Int = 0
    
    @State private var showConfetti: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                
                // Kamera + ML
                ScannerView(detectionStatus: $detectionStatus,
                            detections:       $detections,
                            words:            $words,
                            currentIndex:     $currentIndex)
                
                // Renderer kotak
                DrawingView(detections: $detections,
                            viewSize:   .constant(geo.size))
                
                // ------- UI overlay -------
                VStack(spacing: 20) {
                    
                    // Gambar huruf saat ini dari Assets (nama file huruf besar)
                    if currentIndex < words.count {
                        let currentChar = String(words[words.index(words.startIndex, offsetBy: currentIndex)]).uppercased()
                        
                        Image(currentChar)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.3)) // background langsung di belakang gambar
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.8), lineWidth: 4) // outline di luar background
                            )
                            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)
                            .padding(.bottom, 10)


                    }
                    
                    // PROGRESS kata
                    HStack(spacing: 6) {
                        ForEach(Array(words.enumerated()), id: \.offset) { idx, ch in
                            Text(String(ch))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(idx < currentIndex ? .green : .white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    
                    // Status deteksi
                    Text(detectionStatus)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5)
                    
                    // Tombol flip kamera (opsional)
                    /*
                    Button {
                        cameraPosition = (cameraPosition == .back ? .front : .back)
                    } label: {
                        Label("Flip Camera",
                              systemImage: "arrow.triangle.2.circlepath.camera")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.blue, .mint],
                                           startPoint: .leading,
                                           endPoint:   .trailing))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: .blue.opacity(0.3),
                                radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 40)
                    .buttonStyle(ScaleButtonStyle())
                    */
                }
                .padding(.bottom, 30)
                
                if showConfetti {
                    ConfettiView()
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
            .onAppear {
                words = wordSelections.randomElement() ?? ""
            }
            .edgesIgnoringSafeArea(.all)
            .onChange(of: currentIndex) { newValue in
                if newValue == words.count {           // semua huruf selesai
                    showConfetti = true
                    // sembunyikan lagi agar bisa bermain ulang
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showConfetti = false
                        // reset progress kalau mau ulangi automatic:
                        // currentIndex = 0
                        
                        let oldWords = words
                        var newWords = words
                        while true {
                            newWords = wordSelections.randomElement() ?? ""
                            if newWords != oldWords {
                                break
                            }
                        }
                        words = newWords
                        currentIndex = 0
                    }
                }
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    HandPathView()
}
