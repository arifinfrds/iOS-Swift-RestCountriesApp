import Foundation

struct URLSessionHTTPClient: HTTPClient {
    
    let session: URLSession
    
    enum Error: Swift.Error {
        case invalidURLResponseType
    }
    
    func load() async throws -> (Data, HTTPURLResponse) {
        let url = URL(string: "https://restcountries.com/v3.1/all?fields=name,flags")!
        let urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        do {
            let (data, response) = try await session.data(for: urlRequest)
            if let httpResponse = response as? HTTPURLResponse {
                return (data, httpResponse)
            } else {
                throw Error.invalidURLResponseType
            }
        } catch {
            throw error
        }
    }
}
