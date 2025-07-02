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
        content.image = UIImage(systemName: "progress.indicator")
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
                DispatchQueue.main.async {
                    content.image = UIImage(named: "xmark.octagon")
                }
            }
        }
    }
    
    private func image(for country: CountryEntity, completion: @escaping (Result<Data, Error>) -> Void) {
        let imageURL = country.flag.png
        let session = URLSession(configuration: .ephemeral)
        let imageLoader = DelayedImageDataLoaderDecorator(decoratee: RemoteImageDataLoader(session: session, url: imageURL))
        imageLoader.load(completion: completion)
    }
    
}

struct DelayedImageDataLoaderDecorator: ImageDataLoader {
    let decoratee: ImageDataLoader
    
    func load(completion: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            decoratee.load(completion: completion)
        }
    }
}
