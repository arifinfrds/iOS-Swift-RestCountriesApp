import SwiftUI

struct SwiftUICountriesView: View {
    
    @ObservedObject var viewModel: CountriesViewModel
    
    var body: some View {
        NavigationSplitView {
            SwiftUICountriesContentView(
                viewState: viewModel.viewState,
                countries: viewModel.filteredCountries,
                onRetry: { reload() }
            )
            .navigationTitle("Countries")
            .task {
                await viewModel.onLoad()
            }
            .task {
                await viewModel.monitorSearching()
            }
            .refreshable {
                reload()
            }
            .searchable(text: $viewModel.searchText)
        } detail: {
            Text("Select a country")
        }
    }
    
    private func reload() {
        Task {
            await viewModel.onLoad()
        }
    }
}

struct SwiftUICountriesContentView: View {
    
    let viewState: CountriesViewModel.ViewState
    let countries: [CountryEntity]
    let onRetry: (() -> Void)?
    
    var body: some View {
        switch viewState {
        case .initial:
            ProgressView()
        case .loading:
            ProgressView()
        case .empty:
            ContentUnavailableView(
                "No Items",
                systemImage: "magnifyingglass",
                description: Text("There is no items to be shown.")
            )
        case .loaded:
            List(countries) { country in
                NavigationLink(value: country) {
                    SwiftUISwiftUICountryCell(country: country)
                }
            }
            .navigationDestination(for: CountryEntity.self) { country in
                SwiftUICountryDetailView(country: country)
            }
        case .error:
            ContentUnavailableView {
                Text("Failed to load")
            } description: {
                Text("Something went wrong. Please try again")
            } actions: {
                Button {
                    onRetry?()
                } label: {
                    Text("Retry")
                }
                .padding()
                .buttonStyle(.bordered)
            }
        }
    }
}

struct SwiftUISwiftUICountryCell: View {
    
    var country: CountryEntity
    
    var body: some View {
        HStack {
            AsyncImage(url: country.flag.png) { phrase in
                switch phrase {
                case .empty:
                    ProgressView()
                        .frame(width: 80, height: 40)
                case .success(let image):
                    image
                        .resizable()
                        .frame(width: 80, height: 40)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                case .failure:
                    fallbackImage()
                @unknown default:
                    fallbackImage()
                }
            }
            
            Text(country.name.official)
        }
    }
    
    private func fallbackImage() -> some View {
        Image(systemName: "photo.fill")
            .resizable()
            .frame(width: 80, height: 40)
            .aspectRatio(contentMode: .fill)
    }
}

#Preview {
    SwiftUICountriesView(viewModel: CountriesViewModel(useCase: LoadCountryFromRemoteUseCase(client: URLSessionHTTPClient(session: .shared))))
}

#Preview {
    countriesContentView(viewState: .empty, countries: [])
}

#Preview {
    countriesContentView(viewState: .error, countries: [])
}

#Preview {
    countriesContentView(viewState: .loading, countries: [])
}

#Preview {
    countriesContentView(viewState: .initial, countries: [])
}

private func countriesContentView(
    viewState: CountriesViewModel.ViewState,
    countries: [CountryEntity],
    onRetry: (() -> Void)? = nil
) -> some View {
     SwiftUICountriesContentView(
        viewState: viewState,
        countries: countries,
        onRetry: { onRetry?() }
    )
}
