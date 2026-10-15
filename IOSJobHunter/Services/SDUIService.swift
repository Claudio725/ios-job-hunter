//
//  SDUIService.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES on 14/10/26.
//

import Foundation

class SDUIService {
    
    // Simula o carregamento do JSON da tela de vagas do iOSJobHunter
    static func fetchScreenJSON() -> Data {
        let jsonString = """
        {
          "screenTitle": "Vagas iOSJobHunter",
          "components": [
            {
              "id": "header-1",
              "type": "header",
              "data": {
                "title": "Olá, Desenvolvedor",
                "subtitle": "Explore oportunidades selecionadas para você"
              }
            },
            {
              "id": "card-1",
              "type": "job_card",
              "data": {
                "jobId": "101",
                "title": "Senior iOS Developer",
                "company": "Grupo FCamara",
                "location": "Remoto"
              }
            }
          ]
        }
        """
        return jsonString.data(using: .utf8) ?? Data()
    }
    
    // Função que decodifica os dados usando o nosso modelo tolerante a falhas
    static func loadScreen() -> SDUIScreen? {
        let data = fetchScreenJSON()
        do {
            let decoder = JSONDecoder()
            let screen = try decoder.decode(SDUIScreen.self, from: data)
            return screen
        } catch {
            print("Erro ao decodificar a tela SDUI: \\(error)")
            return nil
        }
    }
}
