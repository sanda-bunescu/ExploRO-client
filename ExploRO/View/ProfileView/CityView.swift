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
    CityView(userCityViewModel: UserCityViewModel(), city: sampleCity, isFavorite: true)
}
