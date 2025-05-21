import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @StateObject private var locationManager = LocationManager()
    @State private var showingSheet = false
    @ObservedObject var weatherViewModel = WeatherViewModel()
    //private let weatherService = WeatherService()
    @State private var searchText = ""
    let maxStretchHeight = UIScreen.main.bounds.height / 2
    let baseHeight: CGFloat = 300
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                    Image("Mountain")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                        .overlay {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 4) {
                                                WeatherView(weatherViewModel: weatherViewModel, location: locationManager.locationDescription.locality)

                                                let locality = locationManager.locationDescription.locality
                                                let country = locationManager.locationDescription.country

                                                if !locality.isEmpty && !country.isEmpty {
                                                    Text("\(locality), \(country)")
                                                        .font(.caption)
                                                        .foregroundColor(.white.opacity(0.9))
                                                } else {
                                                    Button("Get location") {
                                                        locationManager.checkLocationAuthorization()
                                                    }
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                                }
                                            }
                                        }
                                        Spacer()
                                        Text("Hi, \(authViewModel.user?.displayName ?? "Traveler")!")
                                        Text("Start new adventure")
                                            .font(.title)
                                    }
                                    .padding()
                                    .foregroundStyle(.white)
                                }
                            }
                            .padding()
                            
                        }

                    VStack {
                        LandmarkRecognitionButtonView()
                        TripsView()
                        CityOverviewView()
                        GroupsScrollableView()
                    }
                    .padding()
            }
            .ignoresSafeArea(edges: .top)
            .background(Color(hex: "#E2F1E5").ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 25))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}


#Preview {
    HomeView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
