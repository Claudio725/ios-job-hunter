//
//  MuseJobModel.swift
//  IOSJobHunter
//
//  Created by Claudio José on 15/10/26.
//

import Foundation

// MARK: - Resposta da API
struct TheMuseResponse: Codable {
    let page: Int
    let pageCount: Int
    let results: [MuseJob]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pageCount = "page_count"
        case results
    }
}

// MARK: - Modelo da Vaga
struct MuseJob: Codable, Identifiable {
    let id: Int
    let name: String
    let company: MuseCompany
    let locations: [MuseLocation]
    let publicationDate: String
    let contents: String // Descrição completa em HTML
    let refs: MuseRefs
    
    // Propriedade computada para tentar extrair o e-mail diretamente do HTML da vaga
    var extractedEmail: String? {
        return extractEmail(from: contents)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, company, locations, contents, refs
        case publicationDate = "publication_date"
    }
}

struct MuseCompany: Codable {
    let id: Int
    let name: String
}

struct MuseLocation: Codable {
    let name: String
}

struct MuseRefs: Codable {
    let landingPage: String
    
    enum CodingKeys: String, CodingKey {
        case landingPage = "landing_page"
    }
}

// MARK: - Função Auxiliar de Regex para E-mail
private func extractEmail(from htmlString: String) -> String? {
    let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    do {
        let regex = try NSRegularExpression(pattern: pattern)
        let nsString = htmlString as NSString
        let results = regex.matches(in: htmlString, range: NSRange(location: 0, length: nsString.length))
        
        if let match = results.first {
            return nsString.substring(with: match.range)
        }
    } catch {
        print("Erro ao processar regex para e-mail: \(error)")
    }
    
    return nil
}
