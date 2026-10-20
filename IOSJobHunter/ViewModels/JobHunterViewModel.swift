import Foundation
import SwiftUI

@Observable
@MainActor
final class JobHunterViewModel {
    var jobs: [JobPost] = []
    var isLoading = false
    var errorMessage: String?
    
    // Certifique-se de que é 'String' e não 'String?'
    var searchText: String = ""

    // Propriedade computada para filtrar as vagas sem poluir a tela
    var filteredJobs: [JobPost] {
        if searchText.isEmpty {
            return jobs
        } else {
            return jobs.filter { job in
                job.title.localizedCaseInsensitiveContains(searchText) ||
                job.company.localizedCaseInsensitiveContains(searchText) ||
                job.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    // 1. Declare as propriedades SEM instanciá-las na linha
    private let jobRepository: JobRepositoryProtocol
    private let aiOptimizerService: AIOptimizerServiceProtocol

    // 2. Inicialize as dependências explicitamente dentro do init isolado ao @MainActor
    // Construtor seguro sem valores padrão que quebram o isolamento do Swift 6
        init(
            jobRepository: JobRepositoryProtocol? = nil,
            aiOptimizerService: AIOptimizerServiceProtocol? = nil
        ) {
            // Se não forem passados na inicialização (uso normal na View),
            // eles são instanciados aqui dentro de forma segura no @MainActor.
            self.jobRepository = jobRepository ?? JobRepository()
            self.aiOptimizerService = aiOptimizerService ?? AIOptimizerService()
        }

    func fetchAndAnalyzeIOSJobs(country: String = "br") async {
            isLoading = true
            errorMessage = nil
            
            do {
                // 1. Busca as vagas puras do repositório
                let fetchedJobs = try await jobRepository.getIOSJobs(country: country)
                
                // 2. Processa cada vaga para garantir que o e-mail seja preenchido (via API ou Regex na description)
                let processedJobs = fetchedJobs.map { job -> JobPost in
                    // Se o e-mail já vier preenchido, mantemos. Se estiver vazio, rodamos o Regex na descrição.
                    let finalEmail: String
                    if job.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        finalEmail =  extractEmail(from: job.description)
                    } else {
                        finalEmail = job.email
                    }
                    print("Vaga: \(job.title) | Empresa: \(job.company) | E-mail detectado: \(finalEmail) | Job description: \(job.description)")
                    // Retorna uma cópia atualizada do JobPost com o e-mail garantido
                    var updatedJob = job
                    updatedJob.email = finalEmail
                    updatedJob.redirecturl = job.redirecturl
                    return updatedJob
                }
                
                // 3. Comente a IA temporariamente para testar se as vagas entram na tela:
                // self.jobs = try await aiOptimizerService.calculateMatchForProfile(jobs: processedJobs)

                // Atualiza a tela direto com as vagas que vieram da Adzuna:
                self.jobs = processedJobs
                
                
            } catch {
                self.errorMessage = "Erro ao carregar vagas: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    
    // Função para varrer o texto da descrição e extrair o primeiro e-mail encontrado
    private func extractEmail(from description: String) -> String {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let nsString = description as NSString
            let results = regex.matches(in: description, range: NSRange(location: 0, length: nsString.length))
            
            if let match = results.first {
                return nsString.substring(with: match.range)
            }
        } catch {
            print("Erro ao extrair e-mail: \(error)")
        }
        return "" // Retorna vazio se não achar nenhum e-mail no texto
    }
}

