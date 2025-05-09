import SwiftUI
import FirebaseAuth

struct TripPlanListView: View {
    var group: GroupResponse?
    var city: CityResponse?
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @State private var showCreateTripView = false
    @StateObject private var tripPlanViewModel = TripPlanViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if tripPlanViewModel.tripPlans.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "airplane.departure")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No trips found.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showCreateTripView = true
                        }) {
                            Label("Create Your First Trip", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(tripPlanViewModel.tripPlans, id: \.id) { trip in
                                NavigationLink(destination: TripPlanDetailView(group: group, city: city, tripPlan: trip, tripViewModel: TripPlanViewModel())) {
                                    TripCardView(trip: trip)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }
            }
            .navigationTitle("Trip Plans")

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateTripView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateTripView) {
                NavigationStack {
                    CreateTripPlanView(group: group, city: city, tripViewModel: tripPlanViewModel)
                }
            }
            .onAppear {
                Task {
                    if let group = group {
                        await tripPlanViewModel.fetchTripPlansByGroupId(user: authViewModel.user, groupId: group.id)
                    } else if let city = city {
                        await tripPlanViewModel.fetchTripPlansByCityAndUser(user: authViewModel.user, cityId: city.id)
                    } else {
                        await tripPlanViewModel.fetchTripPlansByUserId(user: authViewModel.user)
                    }
                }
            }
        }
    }
}



struct TripCardView: View {
    let trip: TripPlanResponse

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.blue)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 6) {
                Text(trip.tripName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(trip.cityName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    Label("\(trip.startDate.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar")
                    Text("–")
                    Label("\(trip.endDate.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
        )
    }
}






#Preview {
    TripPlanListView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
