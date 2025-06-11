import SwiftUI

struct TouristicAttractionDetailView: View {
    let attraction: TouristicAttractionResponse

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                GeometryReader { geometry in
                    AsyncImage(url: URL(string: attraction.imageUrl ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width * 0.95, height: 240)
                            .clipped()
                            .cornerRadius(12)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } placeholder: {
                        ZStack {
                            Color.gray.opacity(0.2)
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 5)
                }
                .frame(height: 240)

                VStack(alignment: .leading, spacing: 4) {
                    Text(attraction.attractionName)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(attraction.category)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                Divider()

                HStack {
                    Label(attraction.openHours, systemImage: "clock")
                    Spacer()
                    Label("€\(attraction.fee, specifier: "%.2f")", systemImage: "eurosign.circle")
                }
                .font(.subheadline)
                .foregroundColor(.gray)

                Divider()

                Text("About")
                    .font(.title2)
                    .bold()

                Text(attraction.attractionDescription)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                if let url = URL(string: attraction.link), !attraction.link.isEmpty {
                    Link(destination: url) {
                        HStack {
                            Text("More Information")
                            Image(systemName: "arrow.up.right.square")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    let example = TouristicAttractionResponse(
        id: 1,
        attractionName: "Eiffel Tower",
        attractionDescription: "An iconic symbol of Paris and one of the most recognizable structures in the world.",
        category: "Monument",
        imageUrl: "https://upload.wikimedia.org/wikipedia/commons/a/a8/Tour_Eiffel_Wikimedia_Commons.jpg",
        openHours: "9:00 - 23:00",
        fee: 25.00,
        link: "https://www.toureiffel.paris/en"
    )

    return NavigationView {
        TouristicAttractionDetailView(attraction: example)
    }
}
