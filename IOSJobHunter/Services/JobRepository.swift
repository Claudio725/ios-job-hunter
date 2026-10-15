//
//  JobRepository.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES MENEZES on 13/10/26.
//
import Foundation

protocol JobRepositoryProtocol {
    func getIOSJobs() async throws -> [JobPost]
}

final class JobRepository: JobRepositoryProtocol {
    private let networkService: GupyScraperServiceProtocol
    
    // Injetamos o serviço de rede (ou um mock padrão)
    init(networkService: GupyScraperServiceProtocol = GupyScraperService()) {
        self.networkService = networkService
    }
    
    func getIOSJobs() async throws -> [JobPost] {
        do {
            // Tenta buscar da API real via URLSession
            let remoteJobs = try await networkService.fetchOpenIOSJobs()
            // Se obtiver sucesso e não estiver vazio, retorna os dados reais
            if !remoteJobs.isEmpty {
                // Adicionando o campo email com string vazia para cada JobPost do remoto
                return remoteJobs.map { job in
                    JobPost(
                        id: job.id,
                        title: job.title,
                        company: job.company,
                        location: job.location,
                        description: job.description,
                        email: "", // campo email vazio enquanto não estiver disponível no dado real
                        matchScore: job.matchScore
                    )
                }
            }
            throw NetworkError.invalidResponse
        } catch {
            print("⚠️ Falha na rede ou API indisponível (\(error.localizedDescription)). Acionando fallback local de segurança...")
            
            // FALLBACK LOCAL: Se a rede falhar, retorna os dados mockados estruturados
            // para garantir que a experiência do usuário nunca seja interrompida offline.
            return [
                JobPost(
                    id: "fallback-1",
                    title: "Desenvolvedor iOS Sênior (Offline/Fallback)",
                    company: "Tech Solutions Rio",
                    location: "Rio de Janeiro (Híbrido)",
                    description: "Modo offline ativo. Sólida experiência em Swift, SwiftUI, Clean Architecture e Swift Concurrency.",
                    email: "recrutamento@techsolutions.com",
                    matchScore: nil
                ),
                JobPost(
                    id: "fallback-2",
                    title: "iOS Engineer Pleno/Sênior",
                    company: "Inovação Mobile Brasil",
                    location: "Remoto",
                    description: "Modo offline ativo. Foco em aplicativos nativos de alta performance e consumo de APIs RESTful.",
                    email: "contato@inovacaomobile.com",
                    matchScore: nil
                ),
                JobPost(
                    id: "fallback-3",
                    title: "Desenvolvedor Mobile iOS",
                    company: "E-Frame Tecnologia",
                    location: "Rio de Janeiro (Presencial)",
                    description: "Modo offline ativo. Desenvolvimento e manutenção de aplicativos utilizando Swift e SwiftUI.",
                    email: "rh@eframe.com.br",
                    matchScore: nil
                )
            ]
        }
    }
}

