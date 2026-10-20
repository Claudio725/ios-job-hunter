//
//  JobHunterView.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES MENEZES on 13/10/26.
//
import SwiftUI

// MARK: - Main View
struct JobHunterView: View {
    struct Country: Identifiable, Hashable {
        let id: String
        let name: String
        let flag: String
        let color: Color //Cor de fundo especifica para o card
    }

    let countries: [Country] = [
        .init(id: "br", name: "Brasil", flag: "🇧🇷", color: .green.opacity(0.15)),
        .init(id: "us", name: "Estados Unidos", flag: "🇺🇸", color: .blue.opacity(0.15)),
        .init(id: "ca", name: "Canadá", flag: "🇨🇦", color: .red.opacity(0.15)),
        .init(id: "gb", name: "Reino Unido", flag: "🇬🇧", color: .purple.opacity(0.15))
    ]
    
    @State private var viewModel = JobHunterViewModel()
    @State private var selectedCountry: String = "br"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("País", selection: $selectedCountry) {
                    ForEach(countries) { country in
                        HStack {
                            Text(country.flag)
                            Text(country.name)
                        }
                        .padding(8)
                        .background(country.color) // Aplica a cor de fundo diferente em cada card
                        .cornerRadius(8)
                        .tag(country.id)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedCountry) { _, newCountry in
                    Task {
                        await viewModel.fetchAndAnalyzeIOSJobs(country: newCountry)
                    }
                }
                
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
                            // Esse símbolo existe e representa uma maleta riscada/indisponível corretamente
                            Image(systemName: "questionmark.folder")
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
                        List(Array(viewModel.filteredJobs.enumerated()), id: \.element.id) { index, job in
                            // Array de cores sutis para alternar o fundo dos cards
                            let cardBackgrounds: [Color] = [
                                Color(.systemBackground),
                                Color.yellow.opacity(0.12)
                            ]
                            
                            // Usamos as propriedades reais do seu JobPost
                            let safeTitle = job.title
                            let safeCompany = job.company
                            let safeLocation = job.location
                            let safeEmail = job.email
                            let redirecturl = job.redirecturl
                            
                            let safeUrl = safeEmail.isEmpty
                                ? "https://www.google.com/search?q=\(safeTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                                : "mailto:\(safeEmail)"
                            
                            let detailView = JobDetailView(
                                jobTitle: safeTitle,
                                company: safeCompany,
                                location: safeLocation,
                                email: safeEmail,
                                jobUrl: safeUrl,
                                redirecturl: redirecturl
                            )
                            
                            NavigationLink(destination: detailView) {
                                JobRowView(job: job)
                                    .padding()
                                    .background(cardBackgrounds[index % cardBackgrounds.count]) // Alterna a cor de fundo por índice
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                                    .padding(.horizontal, 4)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                    .listRowSeparator(.hidden) // Remove a linha padrão feia do List se quiser um visual mais limpo de cards separados
                            }
                        }
                        .listStyle(.plain)                    }
                }
            }
            .navigationTitle("iOS Job Hunter")
            .searchable(text: $viewModel.searchText, prompt: "Filtrar por tecnologia ou empresa")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        Task {
                            await viewModel.fetchAndAnalyzeIOSJobs(country: selectedCountry)
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
                await viewModel.fetchAndAnalyzeIOSJobs(country: selectedCountry)
            }
        }
    }
}
