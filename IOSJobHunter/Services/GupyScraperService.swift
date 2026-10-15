import Foundation

protocol GupyScraperServiceProtocol {
    func fetchOpenIOSJobs() async throws -> [JobPost]
}

final class GupyScraperService: GupyScraperServiceProtocol {
    
    private let apiURL = URL(string: "https://remotive.com/api/remote-jobs?category=software-dev&limit=10")!
    
    func fetchOpenIOSJobs() async throws -> [JobPost] {
        // 1. Executa a requisição HTTP
        let (data, response) = try await URLSession.shared.data(from: apiURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            // 2. Decodifica o JSON usando o modelo estruturado
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(RemotiveAPIResponse.self, from: data)
            
            // 3. Mapeia os dados de forma explícita para evitar o colapso do compilador
            var mappedJobs: [JobPost] = []
            for item in apiResponse.jobs {
                let job = JobPost(
                    id: String(item.id),
                    title: item.title,
                    company: item.company_name,
                    location: item.candidate_required_location,
                    description: "Vaga obtida via API Remotive (Remoto/Global).",
                    email: "",
                    matchScore: nil
                )
                mappedJobs.append(job)
            }
            
            return mappedJobs
            
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}

// MARK: - Modelos de Decodificação da API Remotive
private struct RemotiveAPIResponse: Codable {
    let jobs: [RemotiveJobDTO]
}

private struct RemotiveJobDTO: Codable {
    let id: Int
    let title: String
    let company_name: String
    let candidate_required_location: String
}

// MARK: - Tratamento de Erros de Rede
enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Falha na conexão com o servidor. Verifique sua internet."
        case .decodingFailed(let error):
            return "Erro ao processar os dados recebidos: \(error.localizedDescription)"
        }
    }
}
