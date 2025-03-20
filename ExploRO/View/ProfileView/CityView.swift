//
//  CityView.swift
//  ExploRO
//
//  Created by Sanda Bunescu on 22.02.2025.
//

import SwiftUI

struct CityView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @ObservedObject var userCityViewModel: UserCityViewModel
    @Environment(\.dismiss) private var dismiss
    let city: CityResponse
    let isFavorite: Bool
    @State private var showTripPlans = false
    
    var body: some View {
        GeometryReader{ geo in
            ScrollView{
                VStack{
                    Image("Intro")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geo.size.width)
                        .padding(.top)
                        .font(.caption)
                        .clipped()
                    VStack(alignment: .leading){
                        
                        Text("City Details")
                            .font(.title.bold())
                            .padding(.bottom, 5)
                        Text(city.cityDescription)
                            .font(.title3)
                    }
                    Button{
                        showTripPlans = true
                    }label: {
                        Text("View Trip Plans")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.top, 20)
                    .sheet(isPresented: $showTripPlans) {
                        TripPlanListView(city: city) // Assuming `TripPlanListView` is the view to display the plans
                    }
                }
            }
        }
        .navigationTitle(city.cityName)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isFavorite{
                    Button{
                        Task {
                            await userCityViewModel.deleteUserCity(cityID: city.id, user: authViewModel.user)
                            dismiss()
                        }
                    } label:{
                        Text("Delete")
                    }
                }else {
                    Button{
                        Task {
                            await userCityViewModel.addCityToUser(cityID: city.id, user: authViewModel.user)
                            dismiss()
                        }
                    } label:{
                        Text("Add")
                    }
                }
            }
        }
    }
    
}

#Preview {
    let sampleCity = CityResponse(
        id: 1,
        cityName: "Bucuresti",
        cityDescription: "Bucuresti, the capital of Romania",
        imageUrl: "/static/images/Bucuresti.png"
    )
    CityView(userCityViewModel: UserCityViewModel(), city: sampleCity, isFavorite: true).environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
