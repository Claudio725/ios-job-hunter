//
//  JobHunterView.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES MENEZES on 13/10/26.
//
import SwiftUI

// MARK: - Main View
struct JobHunterView: View {
    @State private var viewModel = JobHunterViewModel(jobRepository: BrazilianJobRepository())

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else if viewModel.jobs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "briefcase.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("Nenhuma vaga de iOS encontrada")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Tente atualizar a busca em breve.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List(viewModel.filteredJobs) { job in
                        // Usamos as propriedades reais do seu JobPost
                        let safeTitle = job.title
                        let safeCompany = job.company
                        let safeLocation = job.location
                        let safeEmail = job.email
                        
                        // Se o e-mail vier vazio, criamos uma URL de busca como fallback para o Safari interno
                        let safeUrl = safeEmail.isEmpty
                            ? "https://www.google.com/search?q=\(safeTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                            : "mailto:\(safeEmail)"
                        
                        let detailView = JobDetailView(
                            jobTitle: safeTitle,
                            company: safeCompany,
                            location: safeLocation,
                            email: safeEmail,
                            jobUrl: safeUrl
                        )
                        
                        NavigationLink(destination: detailView) {
                            JobRowView(job: job)
                                .listRowInsets(EdgeInsets())
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("iOS Job Hunter")
            .searchable(text: $viewModel.searchText, prompt: "Filtrar por tecnologia ou empresa")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        Task {
                            await viewModel.fetchAndAnalyzeIOSJobs()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text("Atualizar")
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .task {
                await viewModel.fetchAndAnalyzeIOSJobs()
            }
        }
    }
}
