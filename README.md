📸 photoUIKit - Clean Architecture Demo
A simple iOS application built with Clean Architecture principles, featuring a modular design with clear separation of concerns.
This project demonstrates best practices for scalable, testable, and maintainable iOS development using Swift and UIKit.
It fetches and displays a paginated list of photos from the Picsum.photos API.
🏛️ Architecture Overview
This project implements Clean Architecture (Onion Architecture) with the following key principles:

Dependency Rule: Dependencies only point inward. Inner layers know nothing about outer layers.
Separation of Concerns: Each layer has a specific responsibility.
Testability: Business logic is isolated and easily testable.
Independence: Business logic is independent of UI, networking, and frameworks.
Reusability: Modules are designed for easy reuse and extension.

Architecture Diagram
text┌─────────────────────────────────────────────────────┐
│ Presentation                                        │
│ (ViewModels, UI Models)                             │
├─────────────────────────────────────────────────────┤
│ Domain                                              │
│ (Use Cases)                                         │
├─────────────────────────────────────────────────────┤
│ Data Layer                                          │
│ (Repositories, DTOs, Network)                       │
├─────────────────────────────────────────────────────┤
│ Core                                                │
│ (Entities, Protocols, Errors)                       │
└─────────────────────────────────────────────────────┘
Dependencies: ↓ (only inward)
📁 Project Structure
textModules/
├── Core/ # Business entities & contracts
│ ├── Entities/ # Business models
│ │ └── PhotoEntity.swift
│ ├── Protocols/ # Repository and API interfaces
│ │ ├── PhotoRepositoryProtocol.swift
│ │ ├── APIEnviroments.swift
│ │ ├── APIOperation.swift
│ │ └── APIRequest.swift
│ ├── Errors/ # Domain errors
│ │ └── DomainError.swift
│ ├── Network/ # HTTP utilities
│ │ ├── HeaderField.swift
│ │ └── HTTPMethod.swift
│ └── Extensions/ # URLRequest extensions
│   └── URLRequest+Network.swift
│
├── Domain/ # Business rules
│ └── UseCases/ # Application use cases
│   └── FetchPhotosUseCase.swift
│
├── DataLayer/ # Data management
│ ├── Configuration/ # API configurations
│ │ ├── NetworkConfig.swift
│ │ └── NetworkEnvironment.swift
│ ├── DTOs/ # Data transfer objects
│ │ └── PhotoDTOs.swift
│ ├── Mappers/ # DTO to Entity mappers
│ │ └── PhotoMapper.swift
│ ├── Network/ # API clients and operations
│ │ ├── PhotoListRequest.swift
│ │ ├── APIOperation.swift
│ │ └── APIRequest+Ex.swift
│ └── Repositories/ # Repository implementations
│   └── PhotoRepository.swift
│
├── Presentation/ # UI layer
│ ├── ViewModels/ # Presentation logic
│ │ ├── PhotoViewModel.swift
│ │ └── PhotoEntityViewModel.swift
│ └── Views/ # UIKit Views
│   ├── PhotoListViewController.swift # (Example: List of photos with UITableView)
│   └── AppDelegate.swift # (Example: Main entry point)
│   └── SceneDelegate.swift # (For scene management)
│
└── DI/ # Dependency injection
    └── DIContainer.swift

✨ Key Features
🧩 Architecture Features

✅ Clean Architecture with dependency inversion
✅ Modular, testable, and reusable design
✅ SOLID principles applied
✅ Type-safe concurrency using Sendable

📱 Application Features

📷 Fetch and paginate photo lists
⚡ Real-time loading and state management
🚨 Domain-based error handling

🎨 UI/UX Features

Built entirely with UIKit
Clean, minimal UI with loading indicators
Infinite scroll or "Load More" pagination using UITableView


🛠️ Technology Stack





































ComponentTechnologyLanguageSwift 6.2UIUIKitiOS TargetiOS 17.0+ArchitectureClean ArchitectureNetworkingURLSession (async/await)DependencySwift Package ManagerConcurrencySwift Concurrency (async/await)

🚀 Getting Started
Prerequisites

Xcode 16.0 or later
iOS 17.0+ deployment target
Swift 6.2

Installation
bashgit clone https://github.com/yourusername/photoUIKit.git
cd photoUIKit
open photoUIKit.xcodeproj
Then build and run (Cmd + R).

No API keys required — uses a public endpoint.


📦 Module Dependencies
🧭 Dependency Graph
#mermaid-diagram-mermaid-hwvslum{font-family:"trebuchet ms",verdana,arial,sans-serif;font-size:16px;fill:#ccc;}@keyframes edge-animation-frame{from{stroke-dashoffset:0;}}@keyframes dash{to{stroke-dashoffset:0;}}#mermaid-diagram-mermaid-hwvslum .edge-animation-slow{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 50s linear infinite;stroke-linecap:round;}#mermaid-diagram-mermaid-hwvslum .edge-animation-fast{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 20s linear infinite;stroke-linecap:round;}#mermaid-diagram-mermaid-hwvslum .error-icon{fill:#a44141;}#mermaid-diagram-mermaid-hwvslum .error-text{fill:#ddd;stroke:#ddd;}#mermaid-diagram-mermaid-hwvslum .edge-thickness-normal{stroke-width:1px;}#mermaid-diagram-mermaid-hwvslum .edge-thickness-thick{stroke-width:3.5px;}#mermaid-diagram-mermaid-hwvslum .edge-pattern-solid{stroke-dasharray:0;}#mermaid-diagram-mermaid-hwvslum .edge-thickness-invisible{stroke-width:0;fill:none;}#mermaid-diagram-mermaid-hwvslum .edge-pattern-dashed{stroke-dasharray:3;}#mermaid-diagram-mermaid-hwvslum .edge-pattern-dotted{stroke-dasharray:2;}#mermaid-diagram-mermaid-hwvslum .marker{fill:lightgrey;stroke:lightgrey;}#mermaid-diagram-mermaid-hwvslum .marker.cross{stroke:lightgrey;}#mermaid-diagram-mermaid-hwvslum svg{font-family:"trebuchet ms",verdana,arial,sans-serif;font-size:16px;}#mermaid-diagram-mermaid-hwvslum p{margin:0;}#mermaid-diagram-mermaid-hwvslum .label{font-family:"trebuchet ms",verdana,arial,sans-serif;color:#ccc;}#mermaid-diagram-mermaid-hwvslum .cluster-label text{fill:#F9FFFE;}#mermaid-diagram-mermaid-hwvslum .cluster-label span{color:#F9FFFE;}#mermaid-diagram-mermaid-hwvslum .cluster-label span p{background-color:transparent;}#mermaid-diagram-mermaid-hwvslum .label text,#mermaid-diagram-mermaid-hwvslum span{fill:#ccc;color:#ccc;}#mermaid-diagram-mermaid-hwvslum .node rect,#mermaid-diagram-mermaid-hwvslum .node circle,#mermaid-diagram-mermaid-hwvslum .node ellipse,#mermaid-diagram-mermaid-hwvslum .node polygon,#mermaid-diagram-mermaid-hwvslum .node path{fill:#1f2020;stroke:#ccc;stroke-width:1px;}#mermaid-diagram-mermaid-hwvslum .rough-node .label text,#mermaid-diagram-mermaid-hwvslum .node .label text,#mermaid-diagram-mermaid-hwvslum .image-shape .label,#mermaid-diagram-mermaid-hwvslum .icon-shape .label{text-anchor:middle;}#mermaid-diagram-mermaid-hwvslum .node .katex path{fill:#000;stroke:#000;stroke-width:1px;}#mermaid-diagram-mermaid-hwvslum .rough-node .label,#mermaid-diagram-mermaid-hwvslum .node .label,#mermaid-diagram-mermaid-hwvslum .image-shape .label,#mermaid-diagram-mermaid-hwvslum .icon-shape .label{text-align:center;}#mermaid-diagram-mermaid-hwvslum .node.clickable{cursor:pointer;}#mermaid-diagram-mermaid-hwvslum .root .anchor path{fill:lightgrey!important;stroke-width:0;stroke:lightgrey;}#mermaid-diagram-mermaid-hwvslum .arrowheadPath{fill:lightgrey;}#mermaid-diagram-mermaid-hwvslum .edgePath .path{stroke:lightgrey;stroke-width:2.0px;}#mermaid-diagram-mermaid-hwvslum .flowchart-link{stroke:lightgrey;fill:none;}#mermaid-diagram-mermaid-hwvslum .edgeLabel{background-color:hsl(0, 0%, 34.4117647059%);text-align:center;}#mermaid-diagram-mermaid-hwvslum .edgeLabel p{background-color:hsl(0, 0%, 34.4117647059%);}#mermaid-diagram-mermaid-hwvslum .edgeLabel rect{opacity:0.5;background-color:hsl(0, 0%, 34.4117647059%);fill:hsl(0, 0%, 34.4117647059%);}#mermaid-diagram-mermaid-hwvslum .labelBkg{background-color:rgba(87.75, 87.75, 87.75, 0.5);}#mermaid-diagram-mermaid-hwvslum .cluster rect{fill:hsl(180, 1.5873015873%, 28.3529411765%);stroke:rgba(255, 255, 255, 0.25);stroke-width:1px;}#mermaid-diagram-mermaid-hwvslum .cluster text{fill:#F9FFFE;}#mermaid-diagram-mermaid-hwvslum .cluster span{color:#F9FFFE;}#mermaid-diagram-mermaid-hwvslum div.mermaidTooltip{position:absolute;text-align:center;max-width:200px;padding:2px;font-family:"trebuchet ms",verdana,arial,sans-serif;font-size:12px;background:hsl(20, 1.5873015873%, 12.3529411765%);border:1px solid rgba(255, 255, 255, 0.25);border-radius:2px;pointer-events:none;z-index:100;}#mermaid-diagram-mermaid-hwvslum .flowchartTitleText{text-anchor:middle;font-size:18px;fill:#ccc;}#mermaid-diagram-mermaid-hwvslum rect.text{fill:none;stroke-width:0;}#mermaid-diagram-mermaid-hwvslum .icon-shape,#mermaid-diagram-mermaid-hwvslum .image-shape{background-color:hsl(0, 0%, 34.4117647059%);text-align:center;}#mermaid-diagram-mermaid-hwvslum .icon-shape p,#mermaid-diagram-mermaid-hwvslum .image-shape p{background-color:hsl(0, 0%, 34.4117647059%);padding:2px;}#mermaid-diagram-mermaid-hwvslum .icon-shape rect,#mermaid-diagram-mermaid-hwvslum .image-shape rect{opacity:0.5;background-color:hsl(0, 0%, 34.4117647059%);fill:hsl(0, 0%, 34.4117647059%);}#mermaid-diagram-mermaid-hwvslum :root{--mermaid-font-family:"trebuchet ms",verdana,arial,sans-serif;}AppDI ContainerPresentationDomainData LayerCoreURLSession
🧩 Module Descriptions



































ModuleDependenciesDescriptionCoreNoneDefines business entities, domain protocols, and errors. Innermost and most stable layer.DomainCoreContains application use cases — pure business logic independent of frameworks.DataLayerCoreHandles external data sources: API requests, repositories, DTOs, and mappers.PresentationDomain, CoreUIKit-based UI and ViewModels that observe app states and handle user interaction.DI (Dependency Injection)All modulesCentralized dependency resolver managing object creation and wiring.

📊 Layer Responsibilities
🧱 Core Layer

Entities, Protocols, Errors
Pure business logic, no framework dependency

⚙️ Domain Layer

Use Cases that define business rules

🌐 Data Layer

Repository implementations, DTOs, API requests

🎨 Presentation Layer

UIKit ViewControllers + ViewModels managing state


🔄 Data Flow Example
textUser Input (ViewController)
    ↓
PhotoViewModel (Presentation)
    ↓
FetchPhotosUseCase (Domain)
    ↓
PhotoRepository (Data)
    ↓
API Client (External)
    ↓
DTO → Entity Mapping
    ↓
UI Update

🧪 Testing

Unit Tests: Mock repositories and test use cases.
Integration Tests: Real API repository tests.
UI Tests: XCTest for UIKit views and interactions.
Example:

swiftfunc testFetchPhotosSuccess() async throws {
    let mockRepo = MockPhotoRepository()
    let useCase = FetchPhotosUseCase(photoRepository: mockRepo)
    let result = try await useCase.execute(limit: 10, offset: 1)
    XCTAssertEqual(result?.count, 10)
}

📐 Best Practices

Use Dependency Injection via DIContainer
Follow Protocol-Oriented Programming
Apply ViewModel pattern for state management
Handle errors via DomainError
Ensure thread safety with Sendable
Modularize code by responsibility


🔒 Security & ⚡ Performance

✅ Public API — no keys exposed
✅ Validate all input data
✅ Efficient pagination and lazy loading


🤝 Contributing

Fork the repo
Create a feature branch
bashgit checkout -b feat/new-feature

Commit your changes
bashgit commit -m "feat: add new feature"

Push and open a Pull Request

Commit Convention

































TypeMeaningfeatNew featurefixBug fixdocsDocumentation onlyrefactorCode refactortestAdd/Update testschoreMaintenance

📄 License
MIT License – see LICENSE for details.
⭐ Contact
If you find this project helpful, please give it a ⭐ star!
For questions, open an issue on GitHub.
