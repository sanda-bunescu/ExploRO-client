import SwiftUI

struct TripPlanDetailView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    var group: GroupResponse?
    var city: CityResponse?
    let tripPlan: TripPlanResponse
    @ObservedObject var tripViewModel: TripPlanViewModel
    @Environment(\.dismiss) var dismiss

    private var formattedStartDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: tripPlan.startDate)
    }

    private var formattedEndDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: tripPlan.endDate)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Trip Overview
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(tripPlan.tripName)
                            .font(.title)
                            .fontWeight(.semibold)
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
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    HStack(spacing: 10) {
                        Label(formattedStartDate, systemImage: "calendar")
                        Text("→")
                        Label(formattedEndDate, systemImage: "calendar")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    Label("City: \(tripPlan.cityName)", systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                ItineraryTouristicAttractionsListView(tripPlan: tripPlan)
                
            }
            .padding()
        }
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    
    let mockTrip = TripPlanResponse(
        id: 49,
        tripName: "Bucuresti Trip",
        startDate: dateFormatter.date(from: "10/07/2025") ?? Date(),
        endDate: dateFormatter.date(from: "15/07/2025") ?? Date(),
        groupName: "test",
        cityName: "Bucuresti",
        cityId: 29
    )
    
    return TripPlanDetailView(tripPlan: mockTrip, tripViewModel: TripPlanViewModel()).environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
