import Foundation

protocol HTTPClient {
    func load() async throws -> (Data, HTTPURLResponse)
}
