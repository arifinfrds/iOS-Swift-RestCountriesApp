import Foundation

struct RemoteCountry: Decodable {
    let flag: RemoteCountryFlag
    let name: RemoteCountryName
    
    enum CodingKeys: String, CodingKey {
        case flag = "flags"
        case name
    }
}

struct RemoteCountryFlag: Decodable {
    let png: URL
    let svg: URL
    let alt: String
}

struct RemoteCountryName: Decodable {
    let common: String
    let official: String
    let nativeName: [String: RemoteNativeCountryName]
}

struct RemoteNativeCountryName: Decodable {
    let official: String
    let common: String
}

extension RemoteCountry {
    func toEntity() -> CountryEntity {
        let flag = FlagEntity(png: flag.png, svg: flag.svg, alt: flag.alt)
        let name = NameEntity(common: name.common, official: name.official, nativeName: [:])
        return CountryEntity(flag: flag, name: name)
    }
}
