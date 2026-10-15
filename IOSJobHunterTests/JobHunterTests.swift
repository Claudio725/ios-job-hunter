//
//  JobHunterTests.swift
//  IOSJobHunterTests
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES MENEZES on 15/10/26.
//

import XCTest
@testable import IOSJobHunter

// MARK: - Mocks para Isolamento de Testes (Padrão Sênior)
final class MockJobRepository: JobRepositoryProtocol {
    var stubbedJobs: [JobPost] = []
    var shouldFail = false

    func getIOSJobs() async throws -> [JobPost] {
        if shouldFail {
            throw NSError(domain: "TestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Falha na API"])
        }
        return stubbedJobs
    }
}

final class MockAIOptimizerService: AIOptimizerServiceProtocol {
    var matchScoreToReturn = 85

    func calculateMatchForProfile(jobs: [JobPost]) async throws -> [JobPost] {
        return jobs.map { job in
            var modifiedJob = job
            modifiedJob.matchScore = self.matchScoreToReturn
            return modifiedJob
        }
    }
}

// MARK: - Suíte de Testes Principais
@MainActor
final class JobHunterTests: XCTestCase {

    var sut: JobHunterViewModel! // SUT = System Under Test
    var mockRepository: MockJobRepository!
    var mockAIService: MockAIOptimizerService!

    override func setUp() {
        super.setUp()
        mockRepository = MockJobRepository()
        mockAIService = MockAIOptimizerService()
        
        // Injetamos os mocks no ViewModel para testes controlados e determinísticos
        sut = JobHunterViewModel(jobRepository: mockRepository, aiOptimizerService: mockAIService)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockAIService = nil
        super.tearDown()
    }

    // MARK: - Testes de Extração de E-mail por Regex (O Coração da Regra)
    
    func test_extractEmail_whenEmailIsInDescription_shouldExtractSuccessfully() async {
        // Given (Cenário com e-mail escondido em meio a um texto real de recrutador)
        let descriptionWithEmail = "Olá desenvolvedor! Estamos contratando iOS Senior. Envie seu CV para rh.vagas@applejobs.com.br com pretensão."
        
        let job = JobPost(
            id: "1",
            title: "iOS Dev",
            company: "Apple",
            location: "Remoto",
            description: descriptionWithEmail,
            email: "" // Vazio para forçar o Regex
        )
        
        mockRepository.stubbedJobs = [job]

        // When (Executamos a busca que roda o Regex no ViewModel)
        await sut.fetchAndAnalyzeIOSJobs()

        // Then (Validamos se o e-mail foi extraído com sucesso para o objeto)
        XCTAssertEqual(sut.jobs.count, 1)
        XCTAssertEqual(sut.jobs.first?.email, "rh.vagas@applejobs.com.br")
        XCTAssertEqual(sut.jobs.first?.matchScore, 85)
    }

    func test_extractEmail_whenEmailAlreadyExists_shouldNotOverwrite() async {
        // Given (Cenário onde a API já mandou o e-mail preenchido)
        let job = JobPost(
            id: "2",
            title: "SwiftUI Dev",
            company: "Google",
            location: "São Paulo",
            description: "Texto sem e-mail explícito.",
            email: "direto@api.com"
        )
        
        mockRepository.stubbedJobs = [job]

        // When
        await sut.fetchAndAnalyzeIOSJobs()

        // Then (Garante que manteve o e-mail original da API sem estragar nada)
        XCTAssertEqual(sut.jobs.first?.email, "direto@api.com")
    }

    func test_extractEmail_whenNoEmailExists_shouldReturnEmptyString() async {
        // Given (Cenário onde não há e-mail nem na API nem no texto)
        let job = JobPost(
            id: "3",
            title: "Junior iOS",
            company: "Startup",
            location: "Rio",
            description: "Acesse nosso site e cadastre seu currículo pela plataforma web.",
            email: ""
        )
        
        mockRepository.stubbedJobs = [job]

        // When
        await sut.fetchAndAnalyzeIOSJobs()

        // Then (Garante que retorna string vazia em vez de crashar)
        XCTAssertEqual(sut.jobs.first?.email, "")
    }

    // MARK: - Testes de Erro e Estados da View
    
    func test_fetchJobs_whenRepositoryFails_shouldShowErrorMessage() async {
        // Given
        mockRepository.shouldFail = true

        // When
        await sut.fetchAndAnalyzeIOSJobs()

        // Then
        XCTAssertTrue(sut.jobs.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }
}
