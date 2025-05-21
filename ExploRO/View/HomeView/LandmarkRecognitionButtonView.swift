//
//  LandmarkRecognitionButtonView.swift
//  ExploRO
//
//  Created by Sanda Bunescu on 19.05.2025.
//

import SwiftUI

struct LandmarkRecognitionButtonView: View {
    var body: some View {
        VStack{
            NavigationLink {
                LandmarkRecognitionView()
            } label: {
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 175/255, green: 197/255, blue: 179/255), Color(red: 57/255, green: 133/255, blue: 72/255)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 70)
                    .overlay(
                        HStack(spacing: 12) {
                            Image(systemName: "location.viewfinder")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Location Detection")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    )

            }
            .padding(.horizontal)
            Spacer()
        }
    }
}

#Preview {
    LandmarkRecognitionButtonView()
}
