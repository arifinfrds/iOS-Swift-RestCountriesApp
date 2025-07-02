protocol LoadCountryUseCase {
    func loadCountries() async throws -> [CountryEntity]
}
