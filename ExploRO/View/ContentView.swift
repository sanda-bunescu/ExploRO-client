//
//  ContentView.swift
//  FirebaseSignIn
//
//  Created by Sanda Bunescu on 10.09.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @AppStorage("hasSeenIntro") var hasSeenIntro: Bool = false
    var body: some View {
        if !hasSeenIntro {
            IntroView(hasSeenIntro: $hasSeenIntro)
        }else{
            switch authViewModel.authenticationState {
            case .authenticated:
                HomeView()
            case .authenticating:
                ProgressView("Authenticating...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            case .unauthenticated:
                AuthView(viewModel: AuthViewModel())
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
