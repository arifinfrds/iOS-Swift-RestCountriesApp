import XCTest

extension XCTestCase {
    
    func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    func httpURLResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
}
