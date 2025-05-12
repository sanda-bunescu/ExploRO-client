import SwiftUI

struct TouristicAttractionShortView: View {
    let stopPoint: StopPointResponse
    let itineraryId: Int
    @ObservedObject var stopPointViewModel: StopPointViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @Binding var stopPointsList: [StopPointResponse]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Image
            AsyncImage(url: URL(string: stopPoint.touristicAttraction.imageUrl ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ZStack {
                    Color.gray.opacity(0.2)
                    Image(systemName: "photo")
                        .resizable().scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 180)
            .clipped()
            .cornerRadius(12)

            HStack {
                VStack(alignment: .leading) {
                    Text(stopPoint.touristicAttraction.attractionName)
                        .font(.headline)
                        .lineLimit(2)
                    Text(stopPoint.touristicAttraction.category)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Menu {
                    Button(role: .destructive) {
                        Task {
                            await stopPointViewModel.removeStopPoint(
                                stopPointId: stopPoint.id,
                                itineraryId: itineraryId,
                                user: authViewModel.user
                            )
                        }
                    } label: {
                        Label("Delete Stop Point", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .padding(.trailing, 8)
                        .foregroundStyle(.black)
                }
            }

            Text(stopPoint.touristicAttraction.attractionDescription)
                .font(.body)
                .lineLimit(2)
                .foregroundColor(.primary)

            // Open Hours and Fee
            HStack {
                Label(stopPoint.touristicAttraction.openHours, systemImage: "clock")
                Spacer()
                Label("€\(stopPoint.touristicAttraction.fee, specifier: "%.2f")", systemImage: "eurosign.circle")
            }
            .font(.subheadline)
            .foregroundColor(.gray)

            NavigationLink(destination: TouristicAttractionDetailView(attraction: stopPoint.touristicAttraction)) {
                HStack(spacing: 4) {
                    Text("More Info")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right.circle")
                }
                .font(.footnote)
                .foregroundColor(.blue)
                .padding(.top, 6)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        )
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
            attractionDescription: "A beautiful historical monument that attracts thousands of visitors each year. A beautiful historical monument that attracts thousands of visitors each year.",
            category: "Monument",
            imageUrl: "https://via.placeholder.com/400",
            openHours: "10:00 - 15:00",
            fee: 10,
            link: "https://www.example.com"
        )
    )
    
    return TouristicAttractionShortView(stopPoint: stopPoint, itineraryId: 1, stopPointViewModel: StopPointViewModel(), stopPointsList: $emptyStopPointList)
}
