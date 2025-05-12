import SwiftUI

struct AddStopPointsView: View {
    @StateObject private var viewModel = TouristicAttractionViewModel()
    @ObservedObject var stopPointViewModel: StopPointViewModel
    @State private var selectedAttractions: Set<Int> = []
    let cityId: Int
    let itineraryId: Int
    let tripPlanId: Int
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 0) {
            // Title
            HStack {
                Text("Select Attractions")
                    .font(.title2.bold())
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.attractions, id: \.id) { attraction in
                        AttractionCardView(attraction: attraction, isSelected: selectedAttractions.contains(attraction.id)) {
                            toggleSelection(for: attraction.id)
                        }
                    }
                }
                .padding()
            }

            Divider()

            Button(action: {
                Task {
                    await addSelectedStopPoints()
                    dismiss()
                }
            }) {
                HStack {
                    Spacer()
                    Label("Add \(selectedAttractions.count) to Itinerary", systemImage: "plus")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                    Spacer()
                }
                .background(selectedAttractions.isEmpty ? Color.gray : Color.blue)
                .cornerRadius(10)
                .padding()
            }
            .disabled(selectedAttractions.isEmpty)
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await viewModel.fetchTouristicAttractionsNotInTripPlan(cityId: cityId, user: authViewModel.user, tripPlanId: tripPlanId)
        }
    }

    private func toggleSelection(for id: Int) {
        if selectedAttractions.contains(id) {
            selectedAttractions.remove(id)
        } else {
            selectedAttractions.insert(id)
        }
    }

    private func addSelectedStopPoints() async {
        await stopPointViewModel.addStopPoints(ids: Array(selectedAttractions), itineraryId: itineraryId, user: authViewModel.user)
    }
}



struct AttractionCardView: View {
    let attraction: TouristicAttractionResponse
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "building.columns")
                        .font(.title2)
                        .foregroundColor(.blue)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(attraction.attractionName)
                    .font(.headline)
                Text(attraction.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Open: \(attraction.openHours)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
    }
}


#Preview {
    AddStopPointsView(stopPointViewModel: StopPointViewModel(), cityId: 86, itineraryId: 97, tripPlanId: 49)
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
