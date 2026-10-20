//
//  IOSJobHunterApp.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES on 13/10/26.
//

import SwiftUI

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
            // 1. Sua tela principal (ContentView ou a raiz do seu app)
            JobHunterView()
            
            // 2. Camada da Splash Screen por cima
            if showSplash {
                ZStack {
                    // Tom cinza-claro/gelo sutil que acompanha o fundo da figura original
                        Color(red: 0.93, green: 0.94, blue: 0.95)
                            .ignoresSafeArea()
                        
                    // Usamos GeometryReader para garantir centralização matemática exata
                        GeometryReader { geometry in
                            Image("LogoSplash")
                                .resizable()
                                .scaledToFill()
                                // Força a imagem a ter o tamanho da tela e centraliza o eixo de corte
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
            // Tempo que a Splash Screen fica visível na tela (ex: 1.5 segundos) antes de sumir suavemente
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showSplash = false
                }
            }
        }
    }
}
