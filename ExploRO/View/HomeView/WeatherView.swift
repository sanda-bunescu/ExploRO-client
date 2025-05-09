//
//  WeatherView.swift
//  ExploRO
//
//  Created by Sanda Bunescu on 18.02.2025.
//

import SwiftUI

struct WeatherView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    var location: String

    var body: some View {
        VStack{
            if let weather = weatherViewModel.weather {
                HStack {
                    Image(systemName: weatherIcon(for: weather.weather.first?.description ?? ""))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
//                    Text(weather.weather.first?.description ?? "")
                    VStack(alignment: .leading){
                        Text("Weather")
                        Text("\(weather.main.temp, specifier: "%.1f")°C")
                            .bold()
                    }
                }
            }
        }
        .onChange(of: location) {
            if !location.isEmpty {
                weatherViewModel.fetchWeather(city: location)
            }
        }
        .font(.system(size: 15))

    }
}


#Preview {
    WeatherView(weatherViewModel: WeatherViewModel(), location: "Anywhere")
}
