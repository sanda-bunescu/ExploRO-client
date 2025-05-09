import SwiftUI

struct TripPlanDetailView: View {
    var group: GroupResponse?
    var city: CityResponse?
    let tripPlan: TripPlanResponse
    @ObservedObject var tripViewModel: TripPlanViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @Environment(\.dismiss) var dismiss
    private var formattedStartDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: tripPlan.startDate)
    }
    
    private var formattedEndDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: tripPlan.endDate)
    }
    var body: some View {
        NavigationView{
            ScrollView{
                LazyVStack(alignment: .leading, spacing: 16) {
                    HStack{
                        Text("\(tripPlan.tripName)")
                            .font(.headline)
                        Spacer()
                        Menu {
                            Button(role: .destructive) {
                                Task {
                                    await tripViewModel.deleteTripPlan(
                                        user: authViewModel.user,
                                        tripPlanId: tripPlan.id,
                                        groupId: group?.id ?? 0,
                                        cityId: city?.id ?? 0
                                    )
                                    dismiss()
                                }
                            } label: {
                                Label("Delete Trip Plan", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.title2)
                        }
                    }
                    Text("\(formattedStartDate) - \(formattedEndDate)")
                    Text("City: \(tripPlan.cityName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    VStack{
                        Text("Itineraries")
                            .bold()
                            .font(.title)
                        Divider()
                    }
                }
                .padding()
                
                
                //display StopPoints
                ItineraryTouristicAttractionsListView(tripPlan: tripPlan)
                
            }
        }
    }
}

#Preview {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    
    let mockTrip = TripPlanResponse(
        id: 1,
        tripName: "Bucuresti Trip",
        startDate: dateFormatter.date(from: "10/07/2025") ?? Date(),
        endDate: dateFormatter.date(from: "15/07/2025") ?? Date(),
        groupName: "test",
        cityName: "Bucuresti",
        cityId: 29
    )
    
    return TripPlanDetailView(tripPlan: mockTrip, tripViewModel: TripPlanViewModel())
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
