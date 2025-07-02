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
        
        contentConfiguration = content
    }
}
