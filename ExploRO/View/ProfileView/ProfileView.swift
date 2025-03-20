

import SwiftUI
import FirebaseAuth
import CoreLocation

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @StateObject private var locationManager = LocationManager()
    @State private var showingSheet = false
    
    @ObservedObject var weatherViewModel = WeatherViewModel()
    
    private let weatherService = WeatherService()
    var body: some View {
        NavigationStack{
            ScrollView {
                let user = authViewModel.user
                VStack(alignment: .leading){
                    HStack{
                        Text("Hi, \(user?.displayName ?? "displayName")!")
                            .font(.title)
                        Spacer()
                        WeatherView(weatherViewModel: weatherViewModel, location: locationManager.locationDescription.locality)
                    }
                    // Display User Location
                    if locationManager.lastKnownLocation != nil {
                        Text("\(locationManager.locationDescription.locality), \(locationManager.locationDescription.country)")
                            .font(.system(size: 18))
                        
                    } else {
                        Button("Get location") {
                            locationManager.checkLocationAuthorization()
                        }
                    }
                }
                
                ExploreSurroundingsButtonView()
                
                ViewItinerariesView()
                
                CityOverviewView()
                
                Button("LogOut", action: {
                    // here i need to jump on AuthView
                    authViewModel.signOut()
                    
                })
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding()
                Button("Delete account", action: {
                    showingSheet.toggle()
                })
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding()
                .sheet(isPresented: $showingSheet){
                    ReauthenticateUserSheetView()
                }
                
                
                NavigationLink(destination: GroupListView()) {
                    Text("Go to Groups")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding()
                }
                
                NavigationLink(destination: TripPlanListView()) {
                    Text("Go to TripPlans")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding()
                }
                
            }
            .padding()
        }
    }
}

#Preview {
    ProfileView().environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
