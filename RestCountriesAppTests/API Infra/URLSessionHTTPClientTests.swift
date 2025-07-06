import XCTest
@testable import RestCountriesApp

final class URLSessionHTTPClientTests: XCTestCase {

    func test_loadFromURL_deliversErrorOnClientError() async {
        URLProtocolStub.startInterceptingRequests()
        let expectedError = anyError()
        let expectedURL = anyURL()
        let sut = makeSUT()
        URLProtocolStub.complete(url: expectedURL, data: nil, response: nil, error: expectedError)
        
        do {
            let (data, response) = try await sut.load(from: expectedURL)
            XCTFail("Expect to catch error, got, data: \(data) and response: \(response) instead")
        } catch {
            XCTAssertEqual((error as NSError).domain, expectedError.domain)
            XCTAssertEqual((error as NSError).code, expectedError.code)
        }
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

}

final class URLProtocolStub: URLProtocol {
    
    struct Stub {
        let url: URL
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    static var stubs = [URL: Stub]()
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stubs.removeAll()
    }
    
    static func complete(url: URL, data: Data?, response: URLResponse?, error: Error?) {
        let stub = Stub(url: url, data: data, response: response, error: error)
        stubs[url] = stub
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        if let url = request.url, let _ = stubs[url] {
            return true
        } else {
            return false
        }
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        if let data = Self.stubs[url]?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = Self.stubs[url]?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = Self.stubs[url]?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        
    }
}
