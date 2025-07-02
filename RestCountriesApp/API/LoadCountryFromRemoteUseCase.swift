import Foundation

struct LoadCountryFromRemoteUseCase: LoadCountryUseCase {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
        case generic
    }
    
    func loadCountries() async throws -> [CountryEntity] {
        do {
            let (data, response) =  try await client.load()
            return try CountriesMapper.map(data, response)
        } catch {
            throw error
        }
    }
}

private struct CountriesMapper {
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [CountryEntity] {
        guard response.statusCode == 200 else {
            throw LoadCountryFromRemoteUseCase.Error.generic
        }
        
        if data.isEmpty {
            throw LoadCountryFromRemoteUseCase.Error.invalidData
        } else {
            do {
                let countries = try JSONDecoder().decode([RemoteCountry].self, from: data)
                return countries.map { $0.toEntity() }
            } catch {
                throw LoadCountryFromRemoteUseCase.Error.invalidData
            }
        }
    }
}
