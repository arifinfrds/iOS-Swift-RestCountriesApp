import Foundation

protocol ImageDataLoader {
    func load(completion: @escaping (Result<Data, Error>) -> Void)
}

