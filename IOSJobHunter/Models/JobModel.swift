//
//  JobModel.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES on 16/10/26.
//

import Foundation

// ESSA STRUCT PRECISA ESTAR NO ESCOPO GLOBAL DO ARQUIVO (FORA DE QUALQUER CLASSE)
struct AdzunaResponse: Decodable {
    let results: [Job]
}

struct Job: Identifiable, Decodable {
    let id: String
    let title: String
    let companyName: String
    let locationName: String
    let description: String
    let redirectUrl: String
    let salaryMax: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description
        case company = "company"
        case location = "location"
        case redirectUrl = "redirect_url"
        case salaryMax = "salary_max"
    }
    
    enum SubKeys: String, CodingKey {
        case displayName = "display_name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        
        let rawTitle = try container.decode(String.self, forKey: .title)
        self.title = rawTitle.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        let rawDesc = try container.decode(String.self, forKey: .description)
        self.description = rawDesc.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        self.redirectUrl = try container.decode(String.self, forKey: .redirectUrl)
        self.salaryMax = try container.decodeIfPresent(Double.self, forKey: .salaryMax)
        
        let companyContainer = try container.nestedContainer(keyedBy: SubKeys.self, forKey: .company)
        self.companyName = try companyContainer.decode(String.self, forKey: .displayName)
        
        let locationContainer = try container.nestedContainer(keyedBy: SubKeys.self, forKey: .location)
        self.locationName = try locationContainer.decode(String.self, forKey: .displayName)
    }
}
