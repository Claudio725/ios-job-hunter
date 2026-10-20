import Foundation

class AdzunaService {
    
    private var appId: String {
        guard let filePath = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let value = plist["ADZUNA_APP_ID"] as? String else {
            fatalError("Erro: ADZUNA_APP_ID não encontrado no Config.plist")
        }
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let value = plist["ADZUNA_API_KEY"] as? String else {
            fatalError("Erro: ADZUNA_API_KEY não encontrado no Config.plist")
        }
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func fetchJobs(keyword: String, country: String) async throws -> [Job] {
        // 1. Configura os componentes base da URL da API
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.adzuna.com" // Domínio correto da API
        components.path = "/v1/api/jobs/\(country.lowercased())/search/1"
        
        // 2. Adiciona os parâmetros de forma limpa e segura
        components.queryItems = [
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "app_key", value: apiKey),
            URLQueryItem(name: "what", value: keyword), // Usando o parâmetro recebido em vez de fixo
            URLQueryItem(name: "content-type", value: "application/json")
        ]
        
        // 3. Valida se a URL foi gerada corretamente
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        print("🌐 URL CONCATENADA COM SUCESSO: " + url.absoluteString)
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedResponse = try JSONDecoder().decode(AdzunaResponse.self, from: data)
        return decodedResponse.results
    }
}
