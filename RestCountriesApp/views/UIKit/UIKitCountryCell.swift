import UIKit

final class UIKitCountryCell: UITableViewCell {
    
    static let cellId = "UIKitCountryCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with country: CountryEntity) {
        var content = defaultContentConfiguration()
        content.text = country.name.common
        content.secondaryText = country.name.official
        content.imageProperties.maximumSize = CGSize(width: 44, height: 44)
        contentConfiguration = content
        
        image(for: country) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    content.image = UIImage(data: data)
                    self?.contentConfiguration = content
                }
            case .failure:
                content.image = UIImage(named: "photo")
            }
        }
    }
    
    enum Error: Swift.Error {
        case failedToFetchImage
    }
    
    private func image(for country: CountryEntity, completion: @escaping (Result<Data, Error>) -> Void) {
        let imageURL = country.flag.png
        let request = URLRequest(url: imageURL, cachePolicy: .useProtocolCachePolicy)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                return
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
