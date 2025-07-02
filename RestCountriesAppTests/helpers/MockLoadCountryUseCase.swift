import Foundation
@testable import RestCountriesApp

final class MockLoadCountryUseCase: LoadCountryUseCase {
    
    enum Invocation {
        case loadCountries
    }
    
    private(set) var invocations = [Invocation]()
    
    private let result: Result<[CountryEntity], Error>
    
    init(result: Result<[CountryEntity], Error> = .failure(NSError(domain: "any-error", code: -1))) {
        self.result = result
    }
    
    func loadCountries() async throws -> [CountryEntity] {
        invocations.append(.loadCountries)
        return try result.get()
    }
}
