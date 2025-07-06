import Foundation

protocol HTTPClient {
    func load(from url: URL) async throws -> (Data, HTTPURLResponse)
}
