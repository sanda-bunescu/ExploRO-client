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
                VStack(alignment: .leading) {
                    Text("\(tripPlan.tripName) · \(formattedStartDate) - \(formattedEndDate)")
                        .font(.headline)
                    Text("City: \(tripPlan.cityName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    VStack{
                        Text("Itinerary")
                            .bold()
                            .font(.title)
                        Divider()
                    }
                }
                .padding()
                Button{
                    //perform addStopPoint
                }label:{
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Stop Point to Trip Plan")
                        Spacer()
                    }
                    .font(.headline)
                    .padding([.top, .horizontal])
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.green)
                    .cornerRadius(10)
                }
                //display StopPoints
                
                Button{
                    Task{
                        await tripViewModel.deleteTripPlan(user: authViewModel.user , tripPlanId: tripPlan.id, groupId: group?.id ?? 0, cityId: city?.id ?? 0)
                        dismiss()
                    }
                }label:{
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Trip Plan")
                        Spacer()
                    }
                    .font(.headline)
                    .padding([.top, .horizontal])
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
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
        cityName: "Bucuresti"
    )
    
    return TripPlanDetailView(tripPlan: mockTrip, tripViewModel: TripPlanViewModel())
}
