import SwiftUI

struct TouristicAttractionView: View {
    let stopPoint: StopPointResponse
    let itineraryId: Int
    @ObservedObject var stopPointViewModel: StopPointViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @Binding var stopPointsList: [StopPointResponse]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image with Placeholder
            AsyncImage(url: URL(string: stopPoint.touristicAttraction.imageUrl ?? "")) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                ZStack {
                    Color.gray.opacity(0.2)
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(radius: 8, y: 5)

            // Title
            HStack{
                Text(stopPoint.touristicAttraction.attractionName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                Menu {
                    Button(role: .destructive) {
                        // Handle delete stopPoint here
                        Task{
                            await stopPointViewModel.removeStopPoint(stopPointId: stopPoint.id, itineraryId: itineraryId, user: authViewModel.user)
                            
                        }
                    } label: {
                        Label("Delete Stop Point", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(8)
                }
            }

            // Category
            Text(stopPoint.touristicAttraction.category)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Description
            Text(stopPoint.touristicAttraction.attractionDescription)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)
                .padding(.top, 4)

            // Open Hours & Fee
            HStack {
                Label(stopPoint.touristicAttraction.openHours, systemImage: "clock")
                Spacer()
                Label("€\(stopPoint.touristicAttraction.fee, specifier: "%.2f")", systemImage: "eurosign.circle")
            }
            .font(.subheadline)
            .foregroundColor(.gray)

            // More Info Button
            if let url = URL(string: stopPoint.touristicAttraction.link), !stopPoint.touristicAttraction.link.isEmpty {
                Link(destination: url) {
                    HStack {
                        Text("More Info")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundColor(.blue)
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemBackground)).shadow(radius: 5))
        .padding(.trailing)
    }
}

#Preview {
    @Previewable @State var emptyStopPointList: [StopPointResponse] = []
    let stopPoint = StopPointResponse(
        id: 1,
        itineraryId: 1,
        touristicAttraction: TouristicAttractionResponse(
            id: 1,
            attractionName: "Test Attraction",
            attractionDescription: "A beautiful historical monument that attracts thousands of visitors each year.",
            category: "Monument",
            imageUrl: "https://via.placeholder.com/400",
            openHours: "10:00 - 15:00",
            fee: 10,
            link: "https://www.example.com"
        )
    )
    
    return TouristicAttractionView(stopPoint: stopPoint, itineraryId: 1, stopPointViewModel: StopPointViewModel(), stopPointsList: $emptyStopPointList)
}
