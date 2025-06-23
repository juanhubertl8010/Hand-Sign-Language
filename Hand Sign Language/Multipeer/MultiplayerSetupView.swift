//
//  MultiplayerSetupView.swift
//  Hand Sign Language
//
//  Created by Nicholas Sindoro on 23/06/25.
//

import SwiftUI

struct MultiplayerSetupView: View {
    var mpcManager: MPCManager = MPCManager(yourName: UIDevice.current.name)
    @Environment(\.dismiss) var dismiss
    
//    init() {
//        mpcManager = MPCManager(yourName: UIDevice.current.name)
//        print("Initialized MPCManager \(mpcManager.myPeerId), \(mpcManager.myPeerId.displayName)")
//    }
    
    var body: some View {
        VStack {
            Text("Multiplayer Setup")
                .font(.title)
                .padding()
            
            if mpcManager.receivedInvite {
                VStack {
                    Text("Invite from \(mpcManager.receivedInviteFrom?.displayName ?? "Unknown")")
                    HStack {
                        Button("Accept") {
                            mpcManager.invitationHandler?(true, mpcManager.session)
                        }
                        Button("Reject") {
                            mpcManager.invitationHandler?(false, mpcManager.session)
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            
            List(mpcManager.availablePeers, id: \.self) { peer in
                Button(peer.displayName) {
                    mpcManager.nearbyServiceBrowser.invitePeer(peer, to: mpcManager.session, withContext: nil, timeout: 30)
                }
            }
            
            Button("Start Game") {
                dismiss()
            }
            .disabled(!mpcManager.paired)
            .padding()
        }
        .onAppear {
            mpcManager.startAdvertising()
            mpcManager.startBrowsing()
            mpcManager.isAvailableToPlay = true
        }
        .onDisappear {
            mpcManager.stopAdvertising()
            mpcManager.stopBrowsing()
        }
    }
}
