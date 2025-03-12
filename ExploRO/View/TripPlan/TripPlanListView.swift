import SwiftUI

struct TripPlan:Identifiable {
    let id = UUID()
    var Name: String
    var StartDate: Date
    var EndDate: Date
    var NrDays: Int
}

struct TripPlanListView: View {
    
    @State private var showCreateTripView = false
    let tripPlans: [TripPlan] = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"

        return [
            TripPlan(Name: "Bucuresti", StartDate: dateFormatter.date(from: "01/06/2025") ?? Date(), EndDate: dateFormatter.date(from: "05/06/2025") ?? Date(), NrDays: 5),
            TripPlan(Name: "Brasov", StartDate: dateFormatter.date(from: "09/02/2025") ?? Date(), EndDate: dateFormatter.date(from: "12/02/2025") ?? Date(), NrDays: 4)
        ]
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(tripPlans, id: \.Name) { trip in
                        VStack(spacing: 15) {
                            HStack {
                                Text(trip.Name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)

                                Spacer()

                                Button {
                                    // Add navigation action
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 36, height: 36)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.blue)
                                    }
                                }
                            }

                            HStack {
                                Text("\(trip.NrDays) days")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Spacer()

                                VStack{
                                    Text("From \(trip.StartDate, style: .date)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text("To \(trip.EndDate, style: .date)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue.opacity(0.15))
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                    }
                    
                    Button{
                        //display create
                        showCreateTripView = true
                    }label:{
                        HStack{
                            Image(systemName: "plus.circle.fill")
                            Text("Create Trip Plan")
                        }
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Trip Plans")
            .sheet(isPresented: $showCreateTripView) {
                NavigationStack {
                    CreateTripPlanView()
                }
            }
        }
    }
}

#Preview {
    TripPlanListView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
