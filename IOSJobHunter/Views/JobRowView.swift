//
//  JobRowView.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES on 13/10/26.
//

import SwiftUI

// MARK: - Subview: Card da Vaga (JobRowView)
struct JobRowView: View {
    let job: JobPost

    var body: some View {
        HStack(spacing: 0) {
            // Barra vertical de Match colorida dinamicamente
            Rectangle()
                .fill(matchColor(for: job.matchScore))
                .frame(width: 6)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(job.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    // Indicador numérico do Match Score
                    if let score = job.matchScore {
                        Text("\(score)% Match")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(matchColor(for: score))
                            .padding(6)
                            .background(matchColor(for: score).opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                // Substituído o Label por HStack para evitar conflito de inicializador
                HStack(spacing: 4) {
                    Image(systemName: "building.2")
                    Text(job.company)
                    Spacer()
                    Image(systemName: "mappin.and.ellipse")
                    Text(job.location)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // Função auxiliar para definir a cor do Match Score
    private func matchColor(for score: Int?) -> Color {
        guard let score = score else { return .gray }
        switch score {
        case 80...100: return .green
        case 50..<80: return .orange
        default: return .red
        }
    }
}
