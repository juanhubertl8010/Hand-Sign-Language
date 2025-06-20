//
//  IntroductionAJ.swift
//  Hand Sign Language
//
//  Created by Juan Hubert Liem on 19/06/25.
//

import SwiftUI

struct IntroductionAJ: View {
    var body: some View {
        NavigationStack{
            ZStack{
                Image("Retro Game Competition Poster-7")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .offset(x: -40)
                    .allowsHitTesting(false)
                VStack {
                    Spacer()
                    VStack(spacing: 30) {
                        NavigationLink(destination: AMHandPathView()) {
                            Image("A-M")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300)
                                .contentShape(Rectangle())
                                .offset(x:-5, y: 120)
                        }
                        Spacer()
                        NavigationLink(destination: NZHandPathView()) {
                            Image("N-Z")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300)
                                .contentShape(Rectangle())
                                .offset(x:-5, y: -180)
                        }
                    }
                  
                       
                    }
                }
            }
        }
    }


#Preview {
    IntroductionAJ()
}
