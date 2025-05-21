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
            ZStack {
                Color(hex: "#E2F1E5").ignoresSafeArea()

                VStack {
                    HStack {
                        Text("Trip Plans")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Spacer()

                        Button(action: {
                            showCreateTripView = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundStyle(Color(red: 57/255, green: 133/255, blue: 72/255))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    if tripPlanViewModel.tripPlans.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "airplane.departure")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)

                            Text("No trips found.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Button{
                                showCreateTripView = true
                            }label: {
                                HStack{
                                    Image(systemName: "plus")
                                    Text("Create Your First Trip")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(red: 57/255, green: 133/255, blue: 72/255))
                        }
                        .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack {
                                ForEach(tripPlanViewModel.tripPlans, id: \.id) { trip in
                                    NavigationLink(destination: TripPlanDetailView(group: group, city: city, tripPlan: trip, tripViewModel: TripPlanViewModel())) {
                                        TripCardView(trip: trip)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
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
        HStack{
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 57/255, green: 133/255, blue: 72/255))
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(trip.tripName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(trip.cityName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
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
