//
//  JobDetailView.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES on 14/10/26.
//

import SwiftUI
import MessageUI
import UniformTypeIdentifiers
import SafariServices // 1. Importado para permitir o navegador interno

struct MailView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    let body: String
    let pdfData: Data?
    let pdfFileName: String?
    
    @Environment(\.presentationMode) var presentation
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([recipient])
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        if let pdfData, let pdfFileName {
            vc.addAttachmentData(pdfData, mimeType: "application/pdf", fileName: pdfFileName)
        }
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailView
        init(_ parent: MailView) { self.parent = parent }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.presentation.wrappedValue.dismiss()
        }
    }
}

// 2. Estrutura auxiliar para abrir o Safari dentro do app
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            onPick(url)
        }
    }
}

struct JobDetailView: View {
    let jobTitle: String
    let company: String
    let location: String
    let email: String
    let jobUrl: String // 3. Adicionado para receber o link da vaga (landing page)
    let redirecturl: String
    
    @State private var applicantName: String = "Claudio José Menezes"
    @State private var applicantEmail: String = "cjsm_menezes@yahoo.com.br"
    @State private var linkedin: String = ""
    @State private var isApplied: Bool = false
    @State private var isLoading: Bool = false
    @State private var showMail: Bool = false
    @State private var mailError: Bool = false
    
    @State private var showSafari: Bool = false // 4. Estado para controlar o navegador interno
    @State private var showDocumentPicker = false
    @State private var pdfData: Data? = nil
    @State private var pdfFileName: String = "Curriculo.pdf"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Cabeçalho da Vaga
                VStack(alignment: .leading, spacing: 8) {
                    Text(jobTitle)
                        .font(.largeTitle)
                        .bold()
                    
                    Text(company)
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text(location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Seção de Informações do Candidato
                VStack(alignment: .leading, spacing: 12) {
                    Text("Seus Dados para Envio")
                        .font(.headline)
                    
                    TextField("Nome Completo", text: $applicantName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("E-mail de Contato", text: $applicantEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                    
                    TextField("LinkedIn (Toque para colar do Clipboard)", text: $linkedin)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onTapGesture {
                            // Pega o texto atual copiado no sistema
                            if let clipboardString = UIPasteboard.general.string, !clipboardString.isEmpty {
                                linkedin = clipboardString
                            }
                        }
                        
                        // (Opcional) Um pequeno aviso visual para o usuário saber que o toque cola automático
                        Text("💡 Toque no campo acima para colar o link/número copiado")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    
                    Button(action: { showDocumentPicker = true }) {
                        Label(pdfData == nil ? "Anexar Currículo (PDF)" : "Currículo Anexado", systemImage: pdfData == nil ? "paperclip" : "checkmark.circle")
                            .foregroundColor(pdfData == nil ? .blue : .green)
                    }
                    .sheet(isPresented: $showDocumentPicker) {
                        DocumentPicker { url in
                            let accessing = url.startAccessingSecurityScopedResource()
                            defer {
                                if accessing {
                                    url.stopAccessingSecurityScopedResource()
                                }
                            }
                            
                            do {
                                let data = try Data(contentsOf: url)
                                self.pdfData = data
                                self.pdfFileName = url.lastPathComponent
                                print("PDF carregado com sucesso: \(url.lastPathComponent) (\(data.count) bytes)")
                            } catch {
                                print("Erro ao carregar os dados do PDF: \(error.localizedDescription)")
                            }
                            
                            showDocumentPicker = false
                        }
                    }
                }
                .padding(.vertical)
                
                Spacer()
                
                // 5. Botão Inteligente (Híbrido: E-mail vs. Safari View)
                if isApplied {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Candidatura enviada com sucesso!")
                            .bold()
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                } else {
                    Button(action: {
                        // Verifica se existe um e-mail válido disponível
                        if !email.isEmpty {
                            if MFMailComposeViewController.canSendMail() {
                                showMail = true
                            } else {
                                mailError = true
                            }
                        } else {
                            // Se não houver e-mail, abre o site da vaga internamente
                            showSafari = true
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text(email.isEmpty ? "Candidatar-se no Site da Vaga" : "Candidatar-se por E-mail")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.blue)
                    .cornerRadius(12)
                    .disabled(isLoading)
                    .sheet(isPresented: $showMail) {
                        MailView(
                            recipient: email,
                            subject: "Candidatura para: \(jobTitle)",
                            body: "Nome: \(applicantName)\nE-mail: \(applicantEmail)\nLinkedIn: \(linkedin)\n\nEstou interessado na vaga.",
                            pdfData: pdfData,
                            pdfFileName: pdfFileName
                        )
                    }
                    .sheet(isPresented: $showSafari) {
                        if let url = URL(string: redirecturl ) {
                            SafariView(url: url)
                        }
                    }
                    .alert("Não foi possível abrir o e-mail", isPresented: $mailError) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("Configure uma conta de e-mail no dispositivo para usar esta função.")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Detalhes da Vaga")
        .navigationBarTitleDisplayMode(.inline)
    }
}
