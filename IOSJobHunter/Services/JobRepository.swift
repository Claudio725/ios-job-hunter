//
//  JobRepository.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES MENEZES on 13/10/26.
//
import Foundation

protocol JobRepositoryProtocol {
    // Adicionamos o parâmetro opcional 'country' com valor padrão "br"
    // Isso permite buscar vagas no Brasil ou Globais sem quebrar o resto do app
    func getIOSJobs(country: String) async throws -> [JobPost]
}

final class JobRepository: JobRepositoryProtocol {
    // Substituímos o serviço da Gupy pelo serviço oficial da Adzuna
    private let adzunaService: AdzunaService
    
    // Injetamos o AdzunaService seguindo o padrão de inicialização segura do seu app
    init(adzunaService: AdzunaService = AdzunaService()) {
        self.adzunaService = adzunaService
    }
    
    func getIOSJobs(country: String = "br") async throws -> [JobPost] {
        // 1. Busca as vagas na API da Adzuna passando o país dinamicamente (ex: "br", "us")
        let adzunaJobs = try await adzunaService.fetchJobs(keyword: "iOS Developer", country: country)
        
        // 2. Mapeia cada 'Job' da Adzuna usando a extensão que criamos
        let jobPosts = adzunaJobs.map { adzunaJob in
            return JobPost(from: adzunaJob)
        }
        
        return jobPosts
    }
}
