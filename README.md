# 📱 iOS Job Hunter

Aplicativo em **Swift / SwiftUI** desenvolvido para auxiliar desenvolvedores iOS a encontrarem vagas de trabalho de forma prática, utilizando uma arquitetura limpa e desacoplada.

## 🚀 Sobre o Projeto
O **iOS Job Hunter** consome dados de vagas (com suporte a repositórios remotos e dados simulados nacionais), aplica filtros inteligentes por termos-chave (como *iOS*, *Swift* e *Mobile*) e apresenta uma interface moderna com busca dinâmica e detalhes da vaga.

## 🏛️ Arquitetura e Padrões
O projeto foi construído seguindo as melhores práticas de desenvolvimento mobile e padrões de mercado:
- **Clean Architecture & Separação de Responsabilidades:** Regras de negócio isoladas da interface.
- **Dependency Inversion (Protocol-Oriented):** Uso de `JobRepositoryProtocol`, permitindo trocar facilmente a fonte de dados (API real, mock nacional ou serviços externos) sem alterar o ViewModel ou a View.
- **Async/Await:** Uso nativo de concorrência moderna em Swift para chamadas de rede seguras (`URLSession`).
- **Testes Unitários:** Cobertura de testes garantindo a integridade dos repositórios e filtros de busca.

## 🛠️ Tecnologias Utilizadas
- **SwiftUI** para a construção da interface declarativa.
- **Combine / Concurrency** (`async/await`) para gerenciamento de fluxo assíncrono.
- **XCTest** para validação e testes unitários.

## 📦 Como Executar o Projeto
1. Clone o repositório na sua máquina:
   ```bash
   git clone [https://github.com/Claudio725/ios-job-hunter.git](https://github.com/Claudio725/ios-job-hunter.git)
