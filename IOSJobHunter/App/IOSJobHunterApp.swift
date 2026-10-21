//
//  IOSJobHunterApp.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES on 13/10/26.
//

import SwiftUI

@main
struct IOSJobHunterApp: App {
    var body: some Scene {
        WindowGroup {
            MainCoordinatorView()
        }
    }
}

// MARK: - Coordenador que controla a transição da Splash Screen
struct MainCoordinatorView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            // 1. Sua tela principal
            JobHunterView()
            
            // 2. Camada da Splash Screen por cima
            if showSplash {
                ZStack {
                    // Gradiente azul de fundo (você pode alterar as cores conforme preferir)
                    LinearGradient(
                        colors: [Color.blue, Color.indigo],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                        
                    // Logo centralizado
                    GeometryReader { geometry in
                        Image("LogoSplash")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                    .ignoresSafeArea()
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .onAppear {
            // Garantindo que a alteração de estado ocorra de forma segura na thread principal
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSplash = false
                }
            }
        }
    }
}
