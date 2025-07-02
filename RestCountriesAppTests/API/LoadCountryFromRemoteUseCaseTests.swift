import XCTest
@testable import RestCountriesApp

final class LoadCountryFromRemoteUseCaseTests: XCTestCase {
    
    // MARK: - Init

    func testInit_doesNotRequestItems() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.invocations.isEmpty)
    }
    
    // MARK: - loadCountries
    
    func testLoadCountries_requestItems() async {
        let (sut, client) = makeSUT()
        
        _ = try? await sut.loadCountries()
        
        XCTAssertEqual(client.invocations, [ .load ])
    }
    
    func testLoadCountriesTwice_requestItemsTwice() async {
        let (sut, client) = makeSUT()
        
        _ = try? await sut.loadCountries()
        _ = try? await sut.loadCountries()
        
        XCTAssertEqual(client.invocations, [ .load, .load ])
    }
    
    func testLoadCountries_whenHasError_throwsError() async {
        let (sut, _) = makeSUT(
            client: MockHTTPClient(loadResult: .failure(LoadCountryFromRemoteUseCase.Error.connectivity))
        )
        
        var receivedErrors = [LoadCountryFromRemoteUseCase.Error]()
        do {
            _ = try await sut.loadCountries()
            XCTFail("Expect to throw error, but did not instead.")
        } catch {
            receivedErrors.append(error as! LoadCountryFromRemoteUseCase.Error)
        }
        
        XCTAssertEqual(receivedErrors, [ .connectivity ])
    }
    
    func testLoadCountries_whenNon200HTTPResponse_deliversError() async {
        let samples = [199, 201, 300, 400, 500]
        
        for (index, statusCode) in samples.enumerated() {
            let (sut, _) = makeSUT(
                client: MockHTTPClient(loadResult: .success((emptyData(), httpURLResponse(statusCode: statusCode))))
            )
            
            var receivedErrors = [LoadCountryFromRemoteUseCase.Error]()
            do {
                _ = try await sut.loadCountries()
                XCTFail("Expect to throw error, but did not instead. Fail at index: \(index) with statusCode: \(statusCode)")
            } catch {
                receivedErrors.append(error as! LoadCountryFromRemoteUseCase.Error)
            }
            
            XCTAssertEqual(receivedErrors, [ .generic ], "Fail at index: \(index) with statusCode: \(statusCode)")
        }
    }
    
    func testLoadCountries_whenSuccess200HTTPResponseWithEmptyData_deliversInvalidError() async {
        let (sut, _) = makeSUT(
            client: MockHTTPClient(loadResult: .success((emptyData(), httpURLResponse(statusCode: 200))))
        )
        
        var receivedErrors = [LoadCountryFromRemoteUseCase.Error]()
        do {
            _ = try await sut.loadCountries()
            XCTFail("Expect to throw error, but did not instead.")
        } catch {
            receivedErrors.append(error as! LoadCountryFromRemoteUseCase.Error)
        }
        
        XCTAssertEqual(receivedErrors, [ .invalidData ])
    }
    
    func testLoadCountries_whenSuccess200HTTPResponseWithInvalidData_deliversInvalidError() async {
        let (sut, _) = makeSUT(
            client: MockHTTPClient(loadResult: .success((invalidData(), httpURLResponse(statusCode: 200))))
        )
        
        var receivedErrors = [LoadCountryFromRemoteUseCase.Error]()
        do {
            _ = try await sut.loadCountries()
            XCTFail("Expect to throw error, but did not instead.")
        } catch {
            receivedErrors.append(error as! LoadCountryFromRemoteUseCase.Error)
        }
        
        XCTAssertEqual(receivedErrors, [ .invalidData ])
    }
    
    func testLoadCountries_whenSuccess200HTTPResponseWithEmptyItemData_deliversEmptyItem() async {
        let (sut, _) = makeSUT(
            client: MockHTTPClient(loadResult: .success((emptyItemData(), httpURLResponse(statusCode: 200))))
        )
        
        var items = [CountryEntity]()
        do {
            items = try await sut.loadCountries()
        } catch {
            XCTFail("Expect to get items, but throw error instead: \(error)")
        }
        
        XCTAssertTrue(items.isEmpty)
    }
    
    func testLoadCountries_whenSuccess200HTTPResponseWithSingleItemData_deliversSingleItem() async {
        let (sut, _) = makeSUT(
            client: MockHTTPClient(loadResult: .success((singleItemData(), httpURLResponse(statusCode: 200))))
        )
        
        var items = [CountryEntity]()
        do {
            items = try await sut.loadCountries()
        } catch {
            XCTFail("Expect to get items, but throw error instead: \(error)")
        }
        
        XCTAssertEqual(items.count, 1)
    }
    
    func testLoadCountries_whenSuccess200HTTPResponseWithTwoItemsData_deliversTwoItems() async {
        let (sut, _) = makeSUT(
            client: MockHTTPClient(loadResult: .success((twoItemsData(), httpURLResponse(statusCode: 200))))
        )
        
        var items = [CountryEntity]()
        do {
            items = try await sut.loadCountries()
        } catch {
            XCTFail("Expect to get items, but throw error instead: \(error)")
        }
        
        XCTAssertEqual(items.count, 2)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(client: MockHTTPClient = MockHTTPClient()) -> (sut: LoadCountryFromRemoteUseCase, client: MockHTTPClient) {
        let sut = LoadCountryFromRemoteUseCase(client: client)
        return (sut, client)
    }
    
    private func emptyData() -> Data {
        Data()
    }
    
    private func invalidData() -> Data {
        let json =
        """
                [
                  {
                    "invalid-key": {
                      "png": 1,
                      "svg": 1,
                      "alt": 2
                    },
                    "invalid-key2": {
                      "common": "Togo",
                      "official": "Togolese Republic",
                      "nativeName": {
                        "fra": {
                          "official": 2,
                          "common": "Togo"
                        }
                      }
                    }
                  }
                ]
        """
        return json.data(using: .utf8)!
    }
    
    private func emptyItemData() -> Data {
        let json =
        """
                []
        """
        return json.data(using: .utf8)!
    }
    
    private func singleItemData() -> Data {
        let json =
        """
                [
                  {
                    "flags": {
                      "png": "https://flagcdn.com/w320/tg.png",
                      "svg": "https://flagcdn.com/tg.svg",
                      "alt": "The flag of Togo is composed of five equal horizontal bands of green alternating with yellow. A red square bearing a five-pointed white star is superimposed in the canton."
                    },
                    "name": {
                      "common": "Togo",
                      "official": "Togolese Republic",
                      "nativeName": {
                        "fra": {
                          "official": "République togolaise",
                          "common": "Togo"
                        }
                      }
                    }
                  }
                ]
        """
        return json.data(using: .utf8)!
    }
    
    private func twoItemsData() -> Data {
        let json =
        """
        [
            {
                "flags": {
                  "png": "https://flagcdn.com/w320/tg.png",
                  "svg": "https://flagcdn.com/tg.svg",
                  "alt": "The flag of Togo is composed of five equal horizontal bands of green alternating with yellow. A red square bearing a five-pointed white star is superimposed in the canton."
                },
                "name": {
                  "common": "Togo",
                  "official": "Togolese Republic",
                  "nativeName": {
                    "fra": {
                      "official": "République togolaise",
                      "common": "Togo"
                    }
                  }
                }
              },
              {
                "flags": {
                  "png": "https://flagcdn.com/w320/yt.png",
                  "svg": "https://flagcdn.com/yt.svg",
                  "alt": ""
                },
                "name": {
                  "common": "Mayotte",
                  "official": "Department of Mayotte",
                  "nativeName": {
                    "fra": {
                      "official": "Département de Mayotte",
                      "common": "Mayotte"
                    }
                  }
                }
              }
        ]
        """
        return json.data(using: .utf8)!
    }
}
