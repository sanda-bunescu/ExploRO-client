import SwiftUI

struct ItineraryTouristicAttractionsListView: View {
    let tripPlan: TripPlanResponse
    @StateObject private var itineraryViewModel = ItineraryViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @State private var addedItineraryIndex: Int?
    @State private var showAlert = false  // State for showing alert
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Button {
                    Task {
                        addedItineraryIndex = await itineraryViewModel.addItinerary(tripPlanId: tripPlan.id, user: authViewModel.user)
                        showAlert = true
                    }
                } label: {
                    Label("Add Itinerary to Trip Plan", systemImage: "plus.circle")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .controlSize(.large)
                .padding()
                
                ForEach($itineraryViewModel.itineraryList, id: \.id) { $itinerary in
                    ItineraryTouristicAttractionView(itinerary: itinerary, tripPlan: tripPlan, itineraryList: $itineraryViewModel.itineraryList)
                        .padding(.vertical)
                }
            }
            .onAppear {
                Task {
                    await itineraryViewModel.fetchItineraries(tripPlanId: tripPlan.id, user: authViewModel.user)
                }
            }
        }
        
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Itinerary Added"), message: Text("Your new itinerary has been added successfully."), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ItineraryTouristicAttractionsListView(tripPlan: TripPlanResponse(id: 1, tripName: "Test trip", startDate: Date(), endDate: Date(), groupName: "TestGroup", cityName: "Bucharest", cityId: 29))
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}

