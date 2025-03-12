import SwiftUI

struct CityAttractionsView: View {
    @StateObject private var viewModel = CityAttractionViewModel()
    let cityId: Int
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.attractions, id: \ .id) { attraction in
                        AttractionCardView(attraction: attraction)
                    }
                }
                .padding()
            }
        }
        .task {
            await viewModel.fetchAllByCityId(cityId: cityId)
        }
    }
}


struct AttractionCardView: View {
    let attraction: TouristicAttractionResponse
    
    var body: some View {
        HStack {
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
            
            VStack(alignment: .leading, spacing: 6) {
                Text(attraction.attractionName)
                    .font(.headline)
                Text(attraction.category)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("Open hours: \(attraction.openHours)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white).shadow(radius: 2))
    }
}

#Preview {
    CityAttractionsView(cityId: 1)
}
