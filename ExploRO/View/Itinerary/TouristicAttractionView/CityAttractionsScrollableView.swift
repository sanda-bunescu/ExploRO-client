import SwiftUI

struct CityAttractionsScrollableView: View {
    @StateObject private var viewModel = TouristicAttractionViewModel()
    var cityId: Int
    var body: some View {
        VStack(alignment: .leading){
            Text("What to visit")
                .font(.title)
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 20){
                    ForEach(viewModel.attractions, id: \.id){ attraction in
                        NavigationLink(destination: TouristicAttractionDetailView(attraction: attraction)) {
                            AttractionVerticalCardView(attraction: attraction)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .task {
            await viewModel.fetchTouristicAttractionsByCityId(cityId: cityId)
        }
        .padding()
    }
}

struct AttractionVerticalCardView: View {
    let attraction: TouristicAttractionResponse
    
    var body: some View {
        VStack(alignment: .leading){
            AsyncImage(url: URL(string: attraction.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            } placeholder: {
                Image(systemName: "building.2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            Text(attraction.attractionName)
                .font(.headline)
        }
        .frame(width: 150, height: 150)
    }
}

#Preview {
    CityAttractionsScrollableView(cityId: 57)
}
