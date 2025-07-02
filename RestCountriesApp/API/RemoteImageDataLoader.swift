import Foundation

struct RemoteImageDataLoader: ImageDataLoader {
    let session: URLSession
    let url: URL
    
    enum Error: Swift.Error {
        case failedToFetchImage
        case unknownError
    }
    
    func load(completion: @escaping (Result<Data, Swift.Error>) -> Void) {
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        session.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(.failure(Error.unknownError))
            }
            if let data, let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completion(.success(data))
                } else {
                    completion(.failure(Error.failedToFetchImage))
                }
            }
        }
        .resume()
    }
}
