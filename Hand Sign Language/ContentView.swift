import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .offset(x: -25)
                    .allowsHitTesting(false)

                VStack {
                    Spacer()
                    VStack(spacing: 30) {
                        NavigationLink(destination: IntroductionAJ()) {
                            Image("Introduction")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300)
            
                                .offset(y: 200)
                        }

                        NavigationLink(destination: HandPathView()) {
                            Image("Games")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300)
                                .offset(y: -150)
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}


#Preview {
    ContentView()
}
