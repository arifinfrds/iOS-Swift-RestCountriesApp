import SwiftUI

struct SwiftUICountryDetailView: View {
    let country: CountryEntity
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: country.flag.png) { phrase in
                    switch phrase {
                    case .empty:
                        ProgressView()
                            .frame(width: 80, height: 40)
                    case .success(let image):
                        VStack(alignment: .center) {
                            image
                                .resizable()
                                .frame(width: 320 * 2, height: 200 * 2)
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                            
                            Text(country.flag.alt)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    case .failure:
                        fallbackImage()
                    @unknown default:
                        fallbackImage()
                    }
                }
                
                Text(country.name.official)
                Text(country.name.common)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(country.name.official)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func fallbackImage() -> some View {
        Image(systemName: "photo.fill")
            .resizable()
            .frame(width: 80, height: 40)
            .aspectRatio(contentMode: .fill)
    }
}

#Preview {
    SwiftUICountryDetailView(
        country: CountryEntity(
            flag: FlagEntity(
                png: URL(string: "https://flagcdn.com/w320/id.png")!,
                svg: URL(string: "https://flagcdn.com/id.svg")!,
                alt: "The flag of Indonesia is composed of two equal horizontal bands of red and white."
            ),
            name: NameEntity(
                common: "Indonesia",
                official: "Republic of Indonesia",
                nativeName: [
                    "ind": NativeNameEntity(
                        official: "Republik Indonesia",
                        common: "Indonesia"
                    )
                ]
            )
        )
    )
}
