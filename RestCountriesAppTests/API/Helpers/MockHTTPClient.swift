import Foundation
@testable import RestCountriesApp

final class MockHTTPClient: HTTPClient {
    enum Invocation {
        case load
    }
    
    private(set) var invocations = [Invocation]()
    
    private let loadResult: Result<(Data, HTTPURLResponse), Error>
    
    init(loadResult: Result<(Data, HTTPURLResponse), Error> = .failure(NSError(domain: "any-error", code: 1))) {
        self.loadResult = loadResult
    }
    
    func load() async throws -> (Data, HTTPURLResponse) {
        invocations.append(.load)
        return try loadResult.get()
    }
}
