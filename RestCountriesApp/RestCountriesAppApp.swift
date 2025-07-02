//
//  RestCountriesAppApp.swift
//  RestCountriesApp
//
//  Created by arifin on 26/06/25.
//

import SwiftUI

@main
struct RestCountriesAppApp: App {
    
    enum UIFramework {
        case swiftUI
        case uiKit
    }
    
    var uiFramework: UIFramework = .uiKit
    
    var body: some Scene {
        WindowGroup {
            rootView()
        }
    }
    
    @ViewBuilder
    private func rootView() -> some View {
        switch uiFramework {
        case .swiftUI:
            SwiftUICountriesView(viewModel: makeCountriesViewModel())
        case .uiKit:
            UIKitCountriesView()
        }
    }
    
    private func makeCountriesViewModel() -> CountriesViewModel {
        CountriesViewModel(useCase: LoadCountryFromRemoteUseCase(client: URLSessionHTTPClient(session: .shared)))
    }
}

struct UIKitCountriesView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        UINavigationController(rootViewController: UIKitCountriesViewController(viewModel: makeCountriesViewModel()))
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    private func makeCountriesViewModel() -> CountriesViewModel {
        CountriesViewModel(useCase: LoadCountryFromRemoteUseCase(client: URLSessionHTTPClient(session: .shared)))
    }
}
