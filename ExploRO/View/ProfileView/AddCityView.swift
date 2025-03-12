import SwiftUI

struct AddCityView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CityViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @ObservedObject var userCityViewModel: UserCityViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Select a City")
                    .font(.title)
                    .bold()
                    .padding()
                
                ScrollView {
                    VStack {
                        ForEach(viewModel.cities, id: \.cityName) { city in
                            
                            NavigationLink{
                                CityView(userCityViewModel: userCityViewModel, city: city, isFavorite: false)
                            }label: {
                                HStack {
                                    AsyncImage(url: URL(string: city.imageUrl ?? "")) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .frame(width: 140, height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    VStack(alignment: .leading) {
                                        Text(city.cityName)
                                            .font(.title2)
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 2)
                                )
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
            .task {
                await viewModel.fetchAllCities(user: authViewModel.user)
            }
        }
        .alert(userCityViewModel.errorMessage ?? "An unexpected error occurred", isPresented: $userCityViewModel.showAlert) {
            Button("Ok"){
            }
        }
    }
    
}

#Preview {
    AddCityView(userCityViewModel: UserCityViewModel()).environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
