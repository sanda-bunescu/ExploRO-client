import SwiftUI
import FirebaseAuth

struct CityOverviewView: View {
    @StateObject private var userCityViewModel = UserCityViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @State private var isAddingCity = false
    var body: some View {
        
        VStack {
            HStack {
                Text("Your Cities")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    isAddingCity = true  // Show sheet when + is tapped
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(userCityViewModel.cities, id: \.cityName) { city in
                        NavigationLink{
                            CityView(userCityViewModel: userCityViewModel, city: city, isFavorite: true)
                        }label: {
                            VStack {
                                AsyncImage(url: URL(string: city.imageUrl ?? "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                Text(city.cityName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.top, 5)
                            }
                            .frame(width: 160, height: 140)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(radius: 5)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 160)
        }
        .padding(.top)
        .sheet(isPresented: $isAddingCity) {
            AddCityView(userCityViewModel: userCityViewModel)
        }
        .task {
            await userCityViewModel.fetchUserCities(user: authViewModel.user)
        }
    }
}

#Preview {
    CityOverviewView().environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
