//
//  SDUIScreen.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES on 14/10/26.
//

import Foundation

// Representa a resposta completa da API/JSON da tela dinâmica
struct SDUIScreen: Codable {
    let screenTitle: String
    let components: [SDUIComponent]
    
    enum CodingKeys: String, CodingKey {
        case screenTitle
        case components
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.screenTitle = try container.decodeIfPresent(String.self, forKey: .screenTitle) ?? "Vagas"
        
        // Decodifica a lista de componentes usando a tolerância a falhas que fizemos antes
        self.components = try container.decodeIfPresent([SDUIComponent].self, forKey: .components) ?? []
    }
}
