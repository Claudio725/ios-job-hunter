//
//  BrazilianJobRepository.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES on 15/10/26.
//

import Foundation

final class BrazilianJobRepository: JobRepositoryProtocol {
    
    // URL de exemplo de um JSON bruto contendo vagas de tecnologia no Brasil para testes rápidos
    private let endpointURL = URL(string: "https://raw.githubusercontent.com/seu-usuario/seu-repositorio/main/vagas-ios-brasil.json")!
    
    func getIOSJobs(country: String = "br") async throws -> [JobPost] {
        // Se a internet falhar ou se quiser testar offline, descomente a linha abaixo:
        // return fetchMockBrazilianJobs()
        
        let (data, response) = try await URLSession.shared.data(from: endpointURL)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "BrazilianJobRepository", code: -2, userInfo: [NSLocalizedDescriptionKey: "Erro ao conectar com o servidor nacional de vagas."])
        }
        
        let decoder = JSONDecoder()
        let allJobs = try decoder.decode([JobPost].self, from: data)
        
        let filteredJobs = allJobs.filter { job in
            let title = job.title.localizedLowercase
            return title.contains("ios") || title.contains("swift") || title.contains("mobile")
        }
        
        return filteredJobs.isEmpty ? allJobs : filteredJobs
    }
    
    // Mock de dados nacionais para você testar imediatamente rodando offline
    private func fetchMockBrazilianJobs() -> [JobPost] {
        return [
            JobPost(
                id: "br-1",
                title: "Desenvolvedor iOS Pleno (Simulado)",
                company: "Nubank (Simulado)",
                location: "São Paulo - SP (Híbrido / Remoto)",
                description: "Buscamos um desenvolvedor iOS com experiência em SwiftUI, Combine e arquitetura MVVM para atuar no nosso time de pagamentos. Envie seu CV para carreiras@nubank-exemplo.com.br",
                email: "carreiras@nubank-exemplo.com.br",
                redirecturl: ""
            ),
            JobPost(
                id: "br-2",
                title: "Engenheiro iOS Sênior (Simulado)",
                company: "Mercado Livre (Simulado)",
                location: "Florianópolis - SC (Remoto)",
                description: "Oportunidade para liderar projetos mobile de alta escala utilizando Swift moderno. Interessados enviar e-mail com pretensão salarial para rh@mercadolivre-exemplo.com",
                email: "rh@mercadolivre-exemplo.com",
                redirecturl: ""
            )
        ]
    }
}
