import SwiftUI

struct CreateTripPlanView: View {
    var group: GroupResponse?
    var city: CityResponse?
    @ObservedObject var tripViewModel: TripPlanViewModel
    @StateObject private var groupViewModel = GroupViewModel()
    @StateObject private var cityViewModel = CityViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @State private var tripName: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var selectedGroup: GroupResponse? = nil
    @State private var selectedCity: CityResponse? = nil
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 25) {
            Text("Create New Trip Plan")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(alignment: .leading) {
                Text("Enter Trip Name:")
                TextField("", text: $tripName)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).fill(Color(.systemGray6)))
            }
            
            if let group = group?.groupName {
                VStack {
                    Text("Traveling with: \(group)")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                }
                .padding(.horizontal)
            } else {
                HStack {
                    Text("Traveling with: ")
                        .font(.headline)
                    Spacer()
                    if groupViewModel.groups.isEmpty {
                        ProgressView()
                    } else {
                        Menu {
                            ForEach(groupViewModel.groups, id: \.id) { group in
                                Button {
                                    selectedGroup = group
                                } label: {
                                    Text(group.groupName)
                                }
                            }
                        } label: {
                            Text(selectedGroup?.groupName ?? "Select group")
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        }
                    }
                }
            }
            
            if let city = city?.cityName {                VStack {
                    Text("Destination: \(city)")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                }
                .padding(.horizontal)
            } else {
                HStack {
                    Text("Destination:")
                        .font(.headline)
                    Spacer()
                    if cityViewModel.cities.isEmpty {
                        ProgressView()
                    } else {
                        Menu {
                            ForEach(cityViewModel.cities, id: \.id) { city in
                                Button {
                                    selectedCity = city
                                } label: {
                                    Text(city.cityName)
                                }
                                
                            }
                        } label: {
                            Text(selectedCity?.cityName ?? "Select city")
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        }
                    }
                }
            }
            
            
            
            DatePicker("Start Date: ", selection: $startDate, displayedComponents: .date)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).fill(Color(.systemGray6)))
            
            
            DatePicker("End Date:", selection: $endDate, displayedComponents: .date)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).fill(Color(.systemGray6)))
            
            Button{
                Task {
                    if let city = city {
                            selectedCity = city
                        }
                    if let group = group {
                        selectedGroup = group
                    }
                    await tripViewModel.createTripPlan(user: authViewModel.user, name: tripName, startDate: startDate, endDate: endDate, selectedGroupId: selectedGroup?.id ?? 0, selectedCityId: selectedCity?.id ?? 0, baseGroupId: group?.id ?? 0, baseCityId: city?.id ?? 0)
                    
                }
            } label:{
                Text("Create")
            }
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .onAppear {
            Task{
                await groupViewModel.fetchGroupsByUserId(user: authViewModel.user)
                await cityViewModel.fetchAllCities(user: authViewModel.user)
            }
        }
        .alert(tripViewModel.errorMessage ?? "Unknown error", isPresented: $tripViewModel.showAlert) {
            Button("OK") {
                if tripViewModel.errorMessage == "Trip plan created successfully"{
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        CreateTripPlanView(tripViewModel: TripPlanViewModel())
            .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
    }
}
