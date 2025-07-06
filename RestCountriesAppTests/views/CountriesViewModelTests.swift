import XCTest
import Foundation
@testable import RestCountriesApp

final class CountriesViewModelTests: XCTestCase {
    
    @MainActor
    func testInit_doesNotLoad() {
        let (_, useCase) = makeSUT()
        
        XCTAssertTrue(useCase.invocations.isEmpty)
    }
    
    @MainActor
    
    func testOnLoad_loadCountries() async {
        let (sut, useCase) = makeSUT()
        
        await sut.onLoad()
        
        XCTAssertEqual(useCase.invocations, [ .loadCountries ])
    }
    
    @MainActor
    func testOnLoad_loadTwice_loadCountriesTwice() async {
        let (sut, useCase) = makeSUT()
        
        await sut.onLoad()
        await sut.onLoad()
        
        XCTAssertEqual(useCase.invocations, [ .loadCountries, .loadCountries ])
    }
    
    @MainActor
    func testOnLoad_whenFailsToLoad_deliversError() async {
        let (sut, _) = makeSUT(useCase: MockLoadCountryUseCase(result: .failure(anyError())))
        
        var receivedViewStates = [CountriesViewModel.ViewState]()
        let viewStateExp = expectation(description: "wait for ViewState subscription")
        viewStateExp.expectedFulfillmentCount = 2
        let viewStateCancellable = sut.$viewState
            .dropFirst()
            .sink { viewState in
                receivedViewStates.append(viewState)
                viewStateExp.fulfill()
        }
        
        await sut.onLoad()
        await fulfillment(of: [viewStateExp], timeout: 0.1)
        
        XCTAssertEqual(receivedViewStates, [ .loading, .error ])
        viewStateCancellable.cancel()
    }
    
    @MainActor
    func testOnLoad_whenLoadsSuccessfullyWithEmptyItems_showsEmptyItems() async {
        let emptyItems = [CountryEntity]()
        let (sut, _) = makeSUT(useCase: MockLoadCountryUseCase(result: .success(emptyItems)))
        
        var receivedViewStates = [CountriesViewModel.ViewState]()
        let viewStateExp = expectation(description: "wait for ViewState subscription")
        viewStateExp.expectedFulfillmentCount = 2
        let viewStateCancellable = sut.$viewState
            .dropFirst()
            .sink { viewState in
                receivedViewStates.append(viewState)
                viewStateExp.fulfill()
        }
        
        var receivedCountries = [CountryEntity]()
        let countriesExp = expectation(description: "wait for countries subscription")
        let countriesCancallable = sut.$countries
            .dropFirst()
            .sink { countries in
                receivedCountries = countries
                countriesExp.fulfill()
        }
        
        await sut.onLoad()
        await fulfillment(of: [viewStateExp, countriesExp], timeout: 0.1)
        
        XCTAssertEqual(receivedViewStates, [ .loading, .empty ])
        XCTAssertEqual(receivedCountries, emptyItems)
        viewStateCancellable.cancel()
        countriesCancallable.cancel()
    }
    
    @MainActor
    func testOnLoad_whenLoadsSuccessfullyWithNonEmptyItems_showsNonItems() async {
        let nonEmptyItems = anyCountries()
        let (sut, _) = makeSUT(useCase: MockLoadCountryUseCase(result: .success(nonEmptyItems)))
        
        var receivedViewStates = [CountriesViewModel.ViewState]()
        let viewStateExp = expectation(description: "wait for ViewState subscription")
        viewStateExp.expectedFulfillmentCount = 2
        let viewStateCancellable = sut.$viewState
            .dropFirst()
            .sink { viewState in
                receivedViewStates.append(viewState)
                viewStateExp.fulfill()
        }
        
        var receivedCountries = [CountryEntity]()
        let countriesExp = expectation(description: "wait for countries subscription")
        let countriesCancallable = sut.$countries
            .dropFirst()
            .sink { countries in
                receivedCountries = countries
                countriesExp.fulfill()
        }
        
        await sut.onLoad()
        await fulfillment(of: [viewStateExp, countriesExp], timeout: 0.1)
        
        XCTAssertEqual(receivedViewStates, [ .loading, .loaded ])
        XCTAssertEqual(receivedCountries, nonEmptyItems)
        viewStateCancellable.cancel()
        countriesCancallable.cancel()
    }
    
    // MARK: - Helpers
    
    
    @MainActor
    private func makeSUT(
        useCase: MockLoadCountryUseCase = MockLoadCountryUseCase(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: CountriesViewModel, useCase: MockLoadCountryUseCase) {
        let sut = CountriesViewModel(useCase: useCase)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, useCase)
    }
    
    private func anyCountries() -> [CountryEntity] {
        let mockCountry1 = CountryEntity(
            flag: FlagEntity(
                png: URL(string: "https://example.com/flags/indonesia.png")!,
                svg: URL(string: "https://example.com/flags/indonesia.svg")!,
                alt: "Flag of Indonesia"
            ),
            name: NameEntity(
                common: "Indonesia",
                official: "Republic of Indonesia",
                nativeName: [
                    "ind": NativeNameEntity(
                        official: "Republik Indonesia",
                        common: "Indonesia"
                    )
                ]
            )
        )

        let mockCountry2 = CountryEntity(
            flag: FlagEntity(
                png: URL(string: "https://example.com/flags/japan.png")!,
                svg: URL(string: "https://example.com/flags/japan.svg")!,
                alt: "Flag of Japan"
            ),
            name: NameEntity(
                common: "Japan",
                official: "Japan",
                nativeName: [
                    "jpn": NativeNameEntity(
                        official: "日本",
                        common: "日本"
                    )
                ]
            )
        )
        
        return [mockCountry1, mockCountry2]
    }

}
