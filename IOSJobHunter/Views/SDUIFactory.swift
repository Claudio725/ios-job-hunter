import SwiftUI

// 1. Fábrica que mapeia o tipo do componente para uma View em SwiftUI
struct SDUIComponentView: View {
    let component: SDUIComponent

    var body: some View {
        switch component.type {
        case .header:
            HeaderComponentView(payload: component.payload)
        case .jobCard:
            JobCardComponentView(payload: component.payload)
        case .button:
            ButtonComponentView(payload: component.payload)
        case .unknown:
            EmptyView()
        }
    }
}

// 2. Visual para o Cabeçalho
struct HeaderComponentView: View {
    let payload: [String: AnyCodable]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(payload["title"]?.value as? String ?? "")
                .font(.title2)
                .bold()
            Text(payload["subtitle"]?.value as? String ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}

// 3. Visual para o Cartão de Vaga (Apenas o visual puro)
struct JobCardComponentView: View {
    let payload: [String: AnyCodable]

    var body: some View {
        let title = payload["title"]?.value as? String ?? "Vaga"
        let company = payload["company"]?.value as? String ?? "Empresa"
        let location = payload["location"]?.value as? String ?? "Remoto"

        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Text(company)
                .font(.subheadline)
                .foregroundColor(.blue)
            Text(location)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.vertical, 4)
    }
}

// 4. Visual para Botões dinâmicos
struct ButtonComponentView: View {
    let payload: [String: AnyCodable]

    var body: some View {
        Button(action: {
            print("Botão clicado")
        }) {
            Text(payload["label"]?.value as? String ?? "Avançar")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(10)
        }
        .padding(.vertical, 4)
    }
}
