//
//  SDUIComponent.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES on 14/10/26.
//

import Foundation

// 1. Enumeração que define os tipos conhecidos de componentes da nossa Server-Driven UI
enum SDUIComponentType: String, Codable {
    case header
    case jobCard = "job_card"
    case button
    case unknown // Fallback para componentes futuros não suportados por esta versão
}

// 2. Modelo polimórfico principal que representa um bloco genérico
struct SDUIComponent: Identifiable, Codable {
    let id: String
    let type: SDUIComponentType
    let payload: [String: AnyCodable] // Dicionário flexível para guardar os dados específicos de cada componente
    
    // Mapeamento manual de chaves JSON (opcional, dependendo do contrato do seu backend)
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case payload = "data"
    }
    
    // Implementação personalizada de Decodable para tolerância a falhas
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Tenta ler o ID ou gera um UUID se vier nulo/ausente
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        
        // Se o tipo enviado pelo servidor for desconhecido, define como .unknown em vez de dar erro fatal
        let typeString = try container.decodeIfPresent(String.self, forKey: .type) ?? "unknown"
        self.type = SDUIComponentType(rawValue: typeString) ?? .unknown
        
        // Decodifica o payload de forma segura
        self.payload = try container.decodeIfPresent([String: AnyCodable].self, forKey: .payload) ?? [:]
    }
}

// 3. Estrutura auxiliar para lidar com tipos arbitrários dentro do dicionário do Payload JSON
public struct AnyCodable: Codable {
    let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal.map { $0.value }
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal.mapValues { $0.value }
        } else {
            value = "Unknown"
        }
    }

    public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            switch value {
            case let stringVal as String:
                try container.encode(stringVal)
            case let intVal as Int:
                try container.encode(intVal)
            case let doubleVal as Double:
                try container.encode(doubleVal)
            case let boolVal as Bool:
                try container.encode(boolVal)
            default:
                try container.encode(String(describing: value))
            }
        }
}
