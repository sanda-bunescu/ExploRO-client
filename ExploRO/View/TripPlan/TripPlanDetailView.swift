import SwiftUI

struct TripPlanDetailView: View {
    let tripPlan: TripPlan
    private var formattedStartDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: tripPlan.StartDate)
    }
    
    private var formattedEndDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: tripPlan.EndDate)
    }
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                Text("\(tripPlan.Name) · \(formattedStartDate) - \(formattedEndDate)")
                
                Text("Itinerary")
                    .bold()
                    .font(.system(size: 20))
                Divider()
            }
            .padding()
        }
    }
}

#Preview {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    
    let mockTrip = TripPlan(
        Name: "Bucuresti",
        StartDate: dateFormatter.date(from: "10/07/2025") ?? Date(),
        EndDate: dateFormatter.date(from: "15/07/2025") ?? Date(),
        NrDays: 6
    )
    
    return TripPlanDetailView(tripPlan: mockTrip)
}
