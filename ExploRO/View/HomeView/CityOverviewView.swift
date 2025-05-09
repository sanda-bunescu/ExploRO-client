import SwiftUI
import FirebaseAuth

struct CityOverviewView: View {
    @StateObject private var userCityViewModel = UserCityViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    var body: some View {
        VStack {
            HStack {
                Text("Your Cities")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                
                Spacer()
                
                NavigationLink(destination: AddCityView(userCityViewModel: userCityViewModel)) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(userCityViewModel.cities, id: \.cityName) { city in
                        NavigationLink{
                            CityView(userCityViewModel: userCityViewModel, city: city, isFavorite: true)
                        }label: {
                            VStack(alignment: .leading) {
                                AsyncImage(url: URL(string: city.imageUrl ?? "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 160, height: 190)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                } placeholder: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 160, height: 190)
                                        
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                }
                                Text(city.cityName)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.top, 5)
                                    .padding(.leading, 10)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .onAppear {
            Task{
                await userCityViewModel.fetchUserCities(user: authViewModel.user)
            }
        }
        
    }
}

#Preview {
    CityOverviewView().environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
