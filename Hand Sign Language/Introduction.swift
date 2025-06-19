//
//  Introduction.swift
//  Hand Sign Language
//
//  Created by Juan Hubert Liem on 17/06/25.
//

import SwiftUI

struct Introduction: View {
    @State private var Kumpulanhuruf = 0
    
    let FotoAJ = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    let FotoKT = ["K", "L", "M", "N", "O", "P", "Q", "R", "S", "T"]
    let FotoUZ = ["U", "V", "W", "X", "Z"]
    
    let teksAJ = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    let teksKT = ["K", "L", "M", "N", "O", "P", "Q", "R", "S", "T"]
    let teksUZ = ["U", "V", "W", "X", "Z"]
    
    var selectedData: ([String], [String]) {
        switch Kumpulanhuruf {
        case 0: return (FotoAJ, teksAJ)
        case 1: return (FotoKT, teksKT)
        case 2: return (FotoUZ, teksUZ)
        default: return ([], [])
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Pilihan huruf", selection: $Kumpulanhuruf) {
                    Text("A-J").tag(0)
                    Text("K-T").tag(1)
                    Text("U-Z").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 20)
                .padding(.horizontal)
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(0..<selectedData.0.count, id: \.self) { index in
                            HStack {
                                Image(selectedData.0[index])            .resizable()
                                    .scaledToFit()
                                    .frame(width: 320, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .offset(x:-110)
                                
                                Text(selectedData.1[index])
                                    .font(.system(size: 28, weight: .bold))
                                    .padding(.leading, 16)
                                    .offset(x:-120)
                               
                            }
                            
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Introduction")
        }
    }
}

#Preview {
    Introduction()
}
