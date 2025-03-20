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
            ScrollView {
                VStack(spacing: 15) {
                    
                    if let groupName = group?.groupName {
                        VStack{
                            Text("Trips for Group: \(groupName)")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        }.padding(.horizontal)
                    }
                    
                    ForEach(tripPlanViewModel.tripPlans, id: \.id) { trip in
                        VStack(spacing: 15) {
                            HStack {
                                VStack(alignment: .leading){
                                    Text(trip.tripName)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    Text(trip.cityName)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                
                                NavigationLink(destination: TripPlanDetailView(group: group, city: city, tripPlan: trip, tripViewModel: TripPlanViewModel())) {
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
                                Spacer()
                                
                                VStack(alignment: .trailing){
                                    Text("From \(trip.startDate, style: .date)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("To \(trip.endDate, style: .date)")
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
                    if let group = group {
                        CreateTripPlanView(group: group,
                                           city: city, tripViewModel: tripPlanViewModel)
                    } else if let city = city {
                        CreateTripPlanView(group: group,
                                           city: city, tripViewModel: tripPlanViewModel)
                    } else{
                        CreateTripPlanView(group: group,
                                           city: city, tripViewModel: tripPlanViewModel)
                    }
                }
            }
            .onAppear {
                Task {
                    if let group = group {
                        // Fetch trips for the group
                        await tripPlanViewModel.fetchTripPlansByGroupId(user: authViewModel.user, groupId: group.id)
                    } else if let city = city {
                        // Fetch trips for the city
                        await tripPlanViewModel.fetchTripPlansByCityAndUser(user: authViewModel.user, cityId: city.id)
                    } else{
                        // Fetch trips for the user
                        await tripPlanViewModel.fetchTripPlansByUserId(user: authViewModel.user )
                    }
                }
            }
        }
    }
}

#Preview {
    TripPlanListView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
