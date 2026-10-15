//
//  BrazilianJobRepository.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES on 15/10/26.
//

import Foundation

final class BrazilianJobRepository: JobRepositoryProtocol {
    
    // URL de exemplo de um JSON bruto contendo vagas de tecnologia no Brasil
    // (Você pode hospedar um JSON próprio no seu GitHub ou usar um endpoint parceiro)
    private let endpointURL = URL(string: "https://raw.githubusercontent.com/seu-usuario/seu-repositorio/main/vagas-ios-brasil.json")!
    
    func getIOSJobs() async throws -> [JobPost] {
            // Se preferir testar com dados simulados nacionais:
            return fetchMockBrazilianJobs()
            
            let (data, response) = try await URLSession.shared.data(from: endpointURL)
            
            // Correção do cast para HTTPURLResponse de forma segura
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "BrazilianJobRepository", code: -2, userInfo: [NSLocalizedDescriptionKey: "Erro ao conectar com o servidor nacional de vagas."])
            }
            
            let decoder = JSONDecoder()
            
            // 1. Decodifica diretamente como um array simples de JobPost (evita o erro do compilador)
            let allJobs = try decoder.decode([JobPost].self, from: data)
            
            // 2. Se quiser filtrar apenas as vagas que contêm "iOS" ou "Swift" no título, fazemos de forma limpa:
            let filteredJobs = allJobs.filter { job in
                let title = job.title.localizedLowercase
                return title.contains("ios") || title.contains("swift") || title.contains("mobile")
            }
            
            // Se a sua lista do JSON já for dedicada só a iOS, pode retornar apenas 'allJobs' direto.
            return filteredJobs.isEmpty ? allJobs : filteredJobs
        }
    
    // Opcional: Mock de dados nacionais para você testar imediatamente rodando offline
    private func fetchMockBrazilianJobs() -> [JobPost] {
        return [
            JobPost(
                id: "br-1",
                title: "Desenvolvedor iOS Pleno",
                company: "Nubank (Simulado)",
                location: "São Paulo - SP (Híbrido / Remoto)",
                description: "Buscamos um desenvolvedor iOS com experiência em SwiftUI, Combine e arquitetura MVVM para atuar no nosso time de pagamentos. Envie seu CV para carreiras@nubank-exemplo.com.br",
                email: "carreiras@nubank-exemplo.com.br"
            ),
            JobPost(
                id: "br-2",
                title: "Engenheiro iOS Sênior",
                company: "Mercado Livre (Simulado)",
                location: "Florianópolis - SC (Remoto)",
                description: "Oportunidade para liderar projetos mobile de alta escala utilizando Swift moderno. Interessados enviar e-mail com pretensão salarial para rh@mercadolivre-exemplo.com",
                email: "rh@mercadolivre-exemplo.com"
            ),
            JobPost(
                id: "br-3",
                title: "Desenvolvedor iOS Junior",
                company: "Startup Local SP",
                location: "São Paulo - SP (Presencial)",
                description: "Vaga júnior para início imediato. Conhecimentos básicos em UIKit, SwiftUI e Git. Cadastre seu currículo através do nosso site oficial de recrutamento.",
                email: "" // Testando o fluxo de busca web caso venha vazio
            )
        ]
    }
}
