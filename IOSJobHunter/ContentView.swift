import SwiftUI

// 1. Atualizamos o JobModel local para suportar os novos campos da tela de detalhes
struct JobModel: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let company: String
    let location: String
    let email: String      // Para testar o envio por e-mail
    let jobUrl: String     // Para testar a abertura do site via Safari
}

struct ContentView: View {
    // Lista de teste atualizada
    private let jobs: [JobModel] = [
        JobModel(
            title: "Desenvolvedor iOS Sênior",
            company: "Grupo FCamara",
            location: "Remoto / São Paulo",
            email: "recrutamento@fcamara.com.br", // Tem e-mail -> vai testar o botão de e-mail com PDF
            jobUrl: "https://www.fcamara.com.br"
        ),
        JobModel(
            title: "Engenheiro iOS Pleno",
            company: "Tech Solutions",
            location: "Híbrido / Rio de Janeiro",
            email: "", // Vazio -> vai testar o comportamento de abrir o link no Safari interno
            jobUrl: "https://github.com"
        )
    ]

    var body: some View {
        NavigationStack {
            List(jobs) { job in
                // Passamos diretamente os valores corretos do JobModel para a JobDetailView
                NavigationLink(destination: JobDetailView(
                    jobTitle: job.title,
                    company: job.company,
                    location: job.location,
                    email: job.email,
                    jobUrl: job.jobUrl, redirecturl: ""
                )) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(job.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(job.company)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Text(job.location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("iOSJobHunter")
        }
    }
}

#Preview {
    ContentView()
}
