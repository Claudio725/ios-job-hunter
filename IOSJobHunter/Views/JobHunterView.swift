//
//  JobHunterView.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES MENEZES on 13/10/26.
//

import SwiftUI

// MARK: - Main View
struct JobHunterView: View {
    @AppStorage("accentColor") private var accentColorName: String = "blue"
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var showThemeSheet: Bool = false

    private let accentColors: [String: Color] = [
        "blue": .blue,
        "green": .green,
        "orange": .orange,
        "pink": .pink,
        "purple": .purple,
        "red": .red,
        "yellow": .yellow,
        "teal": .teal
    ]
    private let accentColorNames: [String] = ["blue", "green", "orange", "pink", "purple", "red", "yellow", "teal"]

    private var accentColor: Color {
        accentColors[accentColorName, default: .blue]
    }

    struct Country: Identifiable, Hashable {
        let id: String
        let name: String
        let flag: String
        let color: Color
    }

    let countries: [Country] = [
        .init(id: "br", name: "Brasil", flag: "🇧🇷", color: .green.opacity(0.15)),
        .init(id: "us", name: "Estados Unidos", flag: "🇺🇸", color: .blue.opacity(0.15)),
        .init(id: "ca", name: "Canadá", flag: "🇨🇦", color: .red.opacity(0.15)),
        .init(id: "gb", name: "Reino Unido", flag: "🇬🇧", color: .purple.opacity(0.15))
    ]
    
    @State private var viewModel = JobHunterViewModel()
    @State private var selectedCountry: String = "br"
    @State private var selectedJob: JobPost?
    @State private var pressedJobId: String?

    var body: some View {
        NavigationStack {
            ZStack {
                // Forçamos a expansão total de limites para o iPadOS não prender a rolagem por conta do .searchable
                VStack(alignment: .leading, spacing: 12) {
                    // Cabeçalho e Seletor de País fixos no topo
                    VStack(alignment: .leading, spacing: 8) {
                        BrandingHeader(accentColor: accentColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Picker("País", selection: $selectedCountry) {
                            ForEach(countries) { country in
                                HStack {
                                    Text(country.flag)
                                    Text(country.name)
                                }
                                .padding(8)
                                .background(country.color)
                                .cornerRadius(8)
                                .tag(country.id)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: selectedCountry) { _, newCountry in
                            Task {
                                await viewModel.fetchAndAnalyzeIOSJobs(country: newCountry)
                            }
                        }
                    }
                    .padding([.top, .horizontal])

                    // Conteúdo Dinâmico
                    Group {
                        if viewModel.isLoading {
                            Spacer()
                            ProgressView()
                                .scaleEffect(1.2)
                                .frame(maxWidth: .infinity)
                            Spacer()
                        } else if let errorMessage = viewModel.errorMessage {
                            Spacer()
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            Spacer()
                        } else if viewModel.jobs.isEmpty {
                            Spacer()
                            VStack(spacing: 20) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 70))
                                    .foregroundColor(accentColor)
                                Text("Nenhuma vaga de iOS encontrada")
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                                Text("Tente atualizar a busca em breve.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Button {
                                    Task {
                                        await viewModel.fetchAndAnalyzeIOSJobs(country: selectedCountry)
                                    }
                                } label: {
                                    Text("Atualizar")
                                        .font(.headline)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 30)
                                        .background(accentColor)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .shadow(color: accentColor.opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .frame(maxWidth: .infinity)
                            Spacer()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(Array(viewModel.filteredJobs.enumerated()), id: \.element.id) { index, job in
                                        Button {
                                            withAnimation {
                                                selectedJob = job
                                            }
                                        } label: {
                                            JobCardRow(job: job, index: index, isSelected: selectedJob?.id == job.id, accentColor: accentColor, pressedJobId: $pressedJobId)
                                        }
                                        .buttonStyle(PlainButtonStyle())
//                                        .simultaneousGesture(
//                                            DragGesture(minimumDistance: 0)
//                                                .onChanged { _ in
//                                                    withAnimation {
//                                                        pressedJobId = job.id
//                                                    }
//                                                }
//                                                .onEnded { _ in
//                                                    withAnimation {
//                                                        pressedJobId = nil
//                                                    }
//                                                }
//                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            }
                            // Garante que o scroll ocupe toda a área útil de toque livre no iPad
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Correção principal para o iPadOS
                
                // Modal de Detalhes da Vaga (Sheet lateral / Overlay)
                if let job = selectedJob {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    selectedJob = nil
                                }
                            }
                        
                        HStack {
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 0) {
                                Button {
                                    withAnimation {
                                        selectedJob = nil
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.secondary)
                                        .padding([.top, .trailing], 16)
                                }
                                
                                JobDetailView(
                                    jobTitle: job.title,
                                    company: job.company,
                                    location: job.location,
                                    email: job.email,
                                    jobUrl: job.email.isEmpty
                                        ? "https://www.google.com/search?q=\(job.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                                        : "mailto:\(job.email)",
                                    redirecturl: job.redirecturl
                                )
                                .padding(.horizontal)
                                Spacer()
                            }
                            .frame(maxWidth: 420)
                            .background(Color.yellow.opacity(0.12))
                            .cornerRadius(20)
                            .padding(.vertical, 40)
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                            
                            Spacer()
                        }
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .animation(.spring(), value: selectedJob)
                    .zIndex(1)
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Filtrar por tecnologia ou empresa")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
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

                    Button {
                        showThemeSheet = true
                    } label: {
                        Image(systemName: "paintpalette")
                    }
                    .disabled(viewModel.isLoading)
                    .accessibilityLabel("Configurações de Tema e Cor")
                }
            }
            .task {
                await viewModel.fetchAndAnalyzeIOSJobs(country: selectedCountry)
            }
            .sheet(isPresented: $showThemeSheet) {
                ThemeAccentSheet(
                    accentColorName: $accentColorName,
                    isDarkMode: $isDarkMode,
                    showThemeSheet: $showThemeSheet,
                    accentColors: accentColors,
                    accentColor: accentColor
                )
            }
            .accentColor(accentColor)
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

private struct JobCardRow: View {
    let job: JobPost
    let index: Int
    let isSelected: Bool
    let accentColor: Color
    @Binding var pressedJobId: String?
    
    private let cardBackgrounds: [Color] = [
        Color(.systemBackground),
        Color.yellow.opacity(0.12)
    ]
    
    private var modalityLabel: String? {
        let lowercasedLocation = job.location.lowercased()
        if lowercasedLocation.contains("remoto") || lowercasedLocation.contains("remote") {
            return "Remoto"
        } else if lowercasedLocation.contains("presencial") || lowercasedLocation.contains("onsite") {
            return "Presencial"
        } else if lowercasedLocation.contains("híbrido") || lowercasedLocation.contains("hibrido") || lowercasedLocation.contains("hybrid") {
            return "Híbrido"
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(job.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                Spacer()
                if let modality = modalityLabel {
                    Text(modality)
                        .font(.caption.bold())
                        .padding(6)
                        .background(accentColor.opacity(0.15))
                        .foregroundColor(accentColor)
                        .cornerRadius(8)
                }
            }
            Text(job.company)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
                .lineLimit(1)
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(job.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(cardBackgrounds[index % cardBackgrounds.count])
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        //.scaleEffect(pressedJobId == job.id ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressedJobId == job.id)
    }
}

private struct BrandingHeader: View {
    let accentColor: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "briefcase.fill")
                .font(.title2)
                .foregroundColor(accentColor)
            Text("iOS Job Hunter")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(accentColor)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ThemeAccentSheet: View {
    @Binding var accentName: String
    @Binding var isDarkMode: Bool
    @Binding var showThemeSheet: Bool

    let accentColors: [String: Color]
    let accentColor: Color

    private let accentColorNames: [String] = ["blue", "green", "orange", "pink", "purple", "red", "yellow", "teal"]

    init(accentColorName: Binding<String>, isDarkMode: Binding<Bool>, showThemeSheet: Binding<Bool>, accentColors: [String : Color], accentColor: Color) {
        self._accentName = accentColorName
        self._isDarkMode = isDarkMode
        self._showThemeSheet = showThemeSheet
        self.accentColors = accentColors
        self.accentColor = accentColor
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Cor de Destaque") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(accentColorNames, id: \.self) { name in
                            let color = accentColors[name] ?? .blue
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .shadow(radius: 2)
                                    .overlay(
                                        Circle()
                                            .stroke(accentName == name ? color : .clear, lineWidth: 3)
                                    )
                                if accentName == name {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                        .shadow(radius: 1)
                                }
                            }
                            .onTapGesture {
                                withAnimation {
                                    accentName = name
                                }
                            }
                            .accessibilityLabel(Text(name.capitalized))
                        }
                    }
                    .padding(.vertical, 8)
                }
                Section("Aparência") {
                    Toggle(isOn: $isDarkMode) {
                        Text("Modo Escuro")
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Configurações")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") {
                        showThemeSheet = false
                    }
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .accentColor(accentColor)
    }
}
