import SwiftUI

struct TouristicAttractionListView: View {
    @StateObject private var viewModel = TouristicAttractionViewModel()
    var cityId: Int
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.errorMessage != nil {
                    Text("Something went wrong")
                        .foregroundColor(.red)
                } else if viewModel.attractions.isEmpty {
                    ProgressView("Loading attractions...")
                } else {
                    List(viewModel.attractions, id: \.id) { attraction in
                        HStack(alignment: .top) {
                            if let imageUrl = attraction.imageUrl,
                               let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 80, height: 80)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipped()
                                    case .failure:
                                        Image(systemName: "photo")
                                            .frame(width: 80, height: 80)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(attraction.attractionName)
                                    .font(.headline)
                                Text(attraction.attractionDescription)
                                    .font(.subheadline)
                                    .lineLimit(2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Attractions")
            .task {
                await viewModel.fetchTouristicAttractionsByCityId(cityId: cityId)
            }
        }
    }
}

#Preview {
    TouristicAttractionListView(cityId: 85)
}
