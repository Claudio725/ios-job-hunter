import Foundation

extension JobPost {
    /// Inicializador customizado para converter o modelo bruto da Adzuna (Job)
    /// no modelo oficial utilizado pelo seu aplicativo (JobPost).
    init(from adzunaJob: Job) {
        self.init(
            id: adzunaJob.id,
            title: adzunaJob.title,
            company: adzunaJob.companyName,
            location: adzunaJob.locationName,
            description: adzunaJob.description,
            email: "", // Fica vazio para o Regex da sua ViewModel extrair depois
            matchScore: nil, // Começa como nil até o seu aiOptimizerService calcular o score
            redirecturl: adzunaJob.redirectUrl
        )
    }
}


