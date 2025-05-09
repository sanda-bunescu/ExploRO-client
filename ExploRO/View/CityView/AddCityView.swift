import SwiftUI

struct AddCityView: View {
    @StateObject private var viewModel = CityViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @ObservedObject var userCityViewModel: UserCityViewModel
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 150))
    ]
    var body: some View {
        NavigationStack {
            VStack {
                Text("Select a City")
                    .font(.title)
                    .bold()
                
                ScrollView {
                    LazyVGrid(columns: adaptiveColumn, spacing: 20) {
                        ForEach(viewModel.cities, id: \.cityName) { city in
                            
                            NavigationLink{
                                CityView(userCityViewModel: userCityViewModel, city: city, isFavorite: false)
                            }label: {
                                VStack(alignment: .leading) {
                                    AsyncImage(url: URL(string: city.imageUrl ?? "")) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 170, height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                    } placeholder: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 170, height: 200)
                                            
                                            Image(systemName: "photo")
                                                .font(.system(size: 40))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        
                                    }
                                    Text(city.cityName)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .padding(.top, 5)
                                        .padding(.bottom, 10)
                                        .padding(.leading, 10)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    print("Adding city")
                                } label: {
                                    Label("Add", systemImage: "plus.circle.fill")
                                }
                                .tint(.green)
                                
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .onAppear {
                Task{
                    await viewModel.fetchCitiesNotSavedByUser(user: authViewModel.user)
                }
            }
        }
    }
    
}

#Preview {
    AddCityView(userCityViewModel: UserCityViewModel()).environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
