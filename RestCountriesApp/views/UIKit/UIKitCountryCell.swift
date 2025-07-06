import UIKit

final class UIKitCountryCell: UITableViewCell {
    
    static let cellId = "UIKitCountryCell"
    private var currentCountry: CountryEntity?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with country: CountryEntity) {
        currentCountry = country
        
        var content = defaultContentConfiguration()
        content.text = country.name.common
        content.secondaryText = country.name.official
        content.image = UIImage(systemName: "progress.indicator")
        content.imageProperties.maximumSize = CGSize(width: 44, height: 44)
        contentConfiguration = content
        
        image(for: country) { [weak self] result in
            guard let self, self.currentCountry == country else { return }
            
            DispatchQueue.main.async {
                var updatedContent = self.defaultContentConfiguration()
                updatedContent.text = country.name.common
                updatedContent.secondaryText = country.name.official
                updatedContent.imageProperties.maximumSize = CGSize(width: 44, height: 44)
                
                switch result {
                case .success(let data):
                    updatedContent.image = UIImage(data: data)
                    
                case .failure:
                    updatedContent.image = UIImage(named: "xmark.octagon")
                }
                
                self.contentConfiguration = updatedContent
            }
        }
    }
    
    private func image(for country: CountryEntity, completion: @escaping (Result<Data, Error>) -> Void) {
        let imageURL = country.flag.png
        let session = URLSession(configuration: .ephemeral)
        let imageLoader = DelayedImageDataLoaderDecorator(decoratee: RemoteImageDataLoader(session: session, url: imageURL))
        imageLoader.load(completion: completion)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        currentCountry = nil
        contentConfiguration = nil
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
