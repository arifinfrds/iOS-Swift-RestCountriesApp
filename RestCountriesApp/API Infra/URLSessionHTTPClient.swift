import Foundation

final class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    enum Error: Swift.Error {
        case invalidURLResponseType
    }
    
    func load(from url: URL) async throws -> (Data, HTTPURLResponse) {
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
