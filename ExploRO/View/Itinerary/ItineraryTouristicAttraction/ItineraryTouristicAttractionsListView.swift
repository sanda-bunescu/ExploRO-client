import SwiftUI

struct ItineraryTouristicAttractionsListView: View {
    let tripPlan: TripPlanResponse
    @StateObject private var itineraryViewModel = ItineraryViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @State private var addedItineraryIndex: Int?
    @State private var showAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Itineraries")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button {
                    Task {
                        addedItineraryIndex = await itineraryViewModel.addItinerary(tripPlanId: tripPlan.id, user: authViewModel.user)
                        showAlert = true
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(.subheadline.bold())
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(red: 57/255, green: 133/255, blue: 72/255))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
            .padding(.top)

            // Itinerary List
            if itineraryViewModel.itineraryList.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No itineraries yet")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach($itineraryViewModel.itineraryList, id: \.id) { $itinerary in
                            StopPointView(
                                itinerary: itinerary,
                                tripPlan: tripPlan,
                                itineraryList: $itineraryViewModel.itineraryList
                            )
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.bottom)
                }
            }
        }
        .onAppear {
            Task {
                await itineraryViewModel.fetchItineraries(tripPlanId: tripPlan.id, user: authViewModel.user)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Itinerary Added"), message: Text("Your new itinerary has been added successfully."), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ItineraryTouristicAttractionsListView(tripPlan: TripPlanResponse(id: 49, tripName: "Test trip", startDate: Date(), endDate: Date(), groupName: "TestGroup", cityName: "Bucharest", cityId: 86))
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
