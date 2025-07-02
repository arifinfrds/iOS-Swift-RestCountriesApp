import Foundation

struct CountryEntity: Equatable {
    let flag: FlagEntity
    let name: NameEntity
}

struct FlagEntity: Equatable {
    let png: URL
    let svg: URL
    let alt: String
}

struct NameEntity: Equatable {
    let common: String
    let official: String
    let nativeName: [String: NativeNameEntity]
}

struct NativeNameEntity: Equatable {
    let official: String
    let common: String
}

extension CountryEntity: Hashable {}
extension FlagEntity: Hashable {}
extension NameEntity: Hashable {}
extension NativeNameEntity: Hashable {}
