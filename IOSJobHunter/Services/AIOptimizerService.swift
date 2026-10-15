//
//  AIOptimizerService.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES on 13/10/26.
//

import Foundation

protocol AIOptimizerServiceProtocol {
    func calculateMatchForProfile(jobs: [JobPost]) async throws -> [JobPost]
}

final class AIOptimizerService: AIOptimizerServiceProtocol {
    
    func calculateMatchForProfile(jobs: [JobPost]) async throws -> [JobPost] {
        // Simulação de processamento inteligente/IA comparando com o perfil do dev
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return jobs.map { job in
            var updatedJob = job
            // Atribui uma pontuação de match inteligente baseada nas keywords da vaga
            if job.description.contains("SwiftUI") || job.description.contains("Swift Concurrency") {
                updatedJob.matchScore = Int.random(in: 85...98) // Match alto para o seu perfil sênior
            } else {
                updatedJob.matchScore = Int.random(in: 60...79)
            }
            return updatedJob
        }
    }
}
