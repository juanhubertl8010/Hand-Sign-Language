import SwiftUI

struct Games: View {
    var body: some View {
        NavigationStack {
            ZStack {
                
                Image("Retro Game Competition Poster-17")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(width: 500, height: 800)
                    .offset(x: -25)
                    .allowsHitTesting(false)
                
                VStack {
                    VStack(spacing: 30) {
                        NavigationLink(destination: HandPathView()) {
                            Image("Retro_Game_Competition_Poster-18-removebg-preview")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 500, height: 100)
                            
                            
                            
                                .position(x: 250, y: 350)
                        }
                    }
                    
                    NavigationLink(destination: MediumHandPath()) {
                        Image("Retro_Game_Competition_Poster-19-removebg-preview")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 500, height: 100)
                        
                            .position(x: 250, y: 120)
                    }
                    
                    
                    Spacer()
                    NavigationLink(destination: HardHandPath()) {
                        Image("Retro_Game_Competition_Poster-20-removebg-preview")
                        
                            .resizable()
                            .scaledToFill()
                            .frame(width: 500, height: 100)
                        
                            .offset(y: 70)
                            .position(x: 250, y: 40)
                    }
                    
                }
                
            }
        }
    }
}

#Preview {
    Games()
}
