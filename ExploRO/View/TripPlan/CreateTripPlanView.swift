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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text("Create New Trip")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                // Trip Name
                VStack(alignment: .leading, spacing: 6) {
                    Text("Trip Name")
                        .font(.headline)
                    TextField("e.g. Sibiu Trip", text: $tripName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

                // Group Selection
                VStack(alignment: .leading, spacing: 6) {
                    Text("Traveling With")
                        .font(.headline)
                    if let fixedGroup = group {
                        Text(fixedGroup.groupName)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    } else if groupViewModel.groups.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Menu {
                            ForEach(groupViewModel.groups, id: \.id) { g in
                                Button {
                                    selectedGroup = g
                                } label: {
                                    Text(g.groupName)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedGroup?.groupName ?? "Select group")
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                }

                // City Selection
                VStack(alignment: .leading, spacing: 6) {
                    Text("Destination")
                        .font(.headline)
                    if let fixedCity = city {
                        Text(fixedCity.cityName)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    } else if cityViewModel.cities.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Menu {
                            ForEach(cityViewModel.cities, id: \.id) { c in
                                Button {
                                    selectedCity = c
                                } label: {
                                    Text(c.cityName)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedCity?.cityName ?? "Select city")
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                }

                // Dates
                VStack(alignment: .leading, spacing: 6) {
                    Text("Dates")
                        .font(.headline)

                    DatePicker("Start", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    DatePicker("End", selection: $endDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

                // Create Button
                Button(action: {
                    Task {
                        if let g = group { selectedGroup = g }
                        if let c = city { selectedCity = c }

                        await tripViewModel.createTripPlan(
                            user: authViewModel.user,
                            name: tripName,
                            startDate: startDate,
                            endDate: endDate,
                            selectedGroupId: selectedGroup?.id ?? 0,
                            selectedCityId: selectedCity?.id ?? 0,
                            baseGroupId: group?.id ?? 0,
                            baseCityId: city?.id ?? 0
                        )
                    }
                }) {
                    Text("Create Trip")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 57/255, green: 133/255, blue: 72/255))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await groupViewModel.fetchGroupsByUserId(user: authViewModel.user)
                await cityViewModel.fetchAllCities(user: authViewModel.user)
            }
        }
        .alert(tripViewModel.errorMessage ?? "Unknown error", isPresented: $tripViewModel.showAlert) {
            Button("OK") {
                if tripViewModel.errorMessage == "Trip plan created successfully" {
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
