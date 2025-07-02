//
//  RestCountriesAppApp.swift
//  RestCountriesApp
//
//  Created by arifin on 26/06/25.
//

import SwiftUI

@main
struct RestCountriesAppApp: App {
    var body: some Scene {
        WindowGroup {
            SwiftUICountriesView(viewModel: makeCountriesViewModel())
        }
    }
    
    private func makeCountriesViewModel() -> CountriesViewModel {
        CountriesViewModel(useCase: LoadCountryFromRemoteUseCase(client: URLSessionHTTPClient(session: .shared)))
    }
}
