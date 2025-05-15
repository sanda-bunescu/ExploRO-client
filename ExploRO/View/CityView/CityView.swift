import SwiftUI

struct CityView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @ObservedObject var userCityViewModel: UserCityViewModel
    @State private var isFavorite: Bool
    let displayTripPlansView: Bool
    let city: CityResponse
    init(userCityViewModel: UserCityViewModel, city: CityResponse, isFavorite: Bool) {
        self._isFavorite = State(initialValue: isFavorite)
        self.displayTripPlansView = isFavorite
        self.userCityViewModel = userCityViewModel
        self.city = city
    }
    var body: some View {
        ScrollView {
            GeometryReader { geo in
                let offset = geo.frame(in: .global).minY
                AsyncImage(url: URL(string: city.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width,
                               height: offset > 0 ? 300 + offset : 300)
                        .clipped()
                        .offset(y: offset > 0 ? -offset : 0)
                } placeholder: {
                    ZStack {
                        Color.gray.opacity(0.3)
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(width: UIScreen.main.bounds.width,
                           height: offset > 0 ? 300 + offset : 300)
                    .offset(y: offset > 0 ? -offset : 0)
                }
            }
            .frame(height: 300)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(city.cityName)
                        .font(.largeTitle.bold())
                    
                    Spacer()
                    
                    Button(action: {
                        isFavorite.toggle()
                        if isFavorite {
                            Task {
                                await userCityViewModel.addCityToUser(cityID: city.id, user: authViewModel.user)
                            }
                        } else {
                            Task {
                                await userCityViewModel.deleteUserCity(cityID: city.id, user: authViewModel.user)
                            }
                        }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .black)
                            .font(.system(size: 30))
                    }
                }
                Text(city.cityDescription)
                    .font(.title3)
                
                if displayTripPlansView {
                    NavigationLink(destination: {
                        TripPlanListView(city: city)
                    }, label: {
                            HStack {
                                Image(systemName: "map.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(.leading)

                                VStack(alignment: .leading) {
                                    Text("View Trip Plans")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("See your personalized itineraries")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.trailing)
                            }
                            .padding()
                            .background(LinearGradient(
                                gradient: Gradient(colors: [Color(red: 57/255, green: 133/255, blue: 72/255), Color(red: 175/255, green: 197/255, blue: 179/255)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .cornerRadius(15)
                        
                    })

                }
                
                CityAttractionsScrollableView(cityId: city.id)
            }
            .padding()
        }
        .ignoresSafeArea(edges: .top)
    }
}


#Preview {
    let sampleCity = CityResponse(
        id: 100,
        cityName: "Bucuresti",
        cityDescription: "Bucuresti, the capital of Romania",
        imageUrl: "/static/images/Bucuresti.png"
    )
    CityView(userCityViewModel: UserCityViewModel(), city: sampleCity, isFavorite: true).environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
