import Foundation

@MainActor
final class CountriesViewModel: ObservableObject {
    
    private let useCase: LoadCountryUseCase
    
    enum ViewState {
        case initial
        case loading
        case empty
        case loaded
        case error
    }
    
    @Published var viewState: ViewState = .initial
    @Published var countries = [CountryEntity]()
    @Published var searchText = ""
    
    var filteredCountries: [CountryEntity] {
        if searchText.isEmpty {
            countries
        } else {
            countries.filter {
                $0.name.common.localizedCaseInsensitiveContains(searchText)
                || $0.name.official.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    init(useCase: LoadCountryUseCase) {
        self.useCase = useCase
    }
    
    func onLoad() async {
        viewState = .loading
        do {
            countries = try await useCase.loadCountries()
            viewState = countries.isEmpty ? .empty : .loaded
        } catch {
            viewState = .error
        }
    }
    
    func monitorSearching() async {
        for await _ in $searchText.values {
            if filteredCountries.isEmpty {
                viewState = .empty
            } else {
                viewState = .loaded
            }
        }
    }
}
