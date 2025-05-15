import SwiftUI

struct CityAttractionsView: View {
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

            // Add Button
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
