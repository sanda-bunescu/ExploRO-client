import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    
    private let weatherService = WeatherService()
    private var cancellable: AnyCancellable?
    @Published var weather: WeatherResponse?
    
    func fetchWeather(city: String) {
        cancellable = weatherService.getWeather(for: city)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { weather in
                self.weather = weather
            })
    }
}

class WeatherService {
    
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    func getWeather(for city: String) -> AnyPublisher<WeatherResponse, Error> {
        guard let weatherKey = Bundle.main.infoDictionary?["OPEN_WEATHER"] as? String else {
            fatalError("Missing OpenWeather API key in Info.plist")
        }
        guard let url = URL(string: "\(baseURL)?q=\(city)&appid=\(weatherKey)&units=metric") else {
            fatalError("Invalid URL")
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
}


func weatherIcon(for description: String) -> String {
    switch description.lowercased() {
        case "clear sky": return "sun.max.fill"
            
        case "few clouds": return "cloud.sun.fill"
        case "scattered clouds": return "cloud.fill"
        case "broken clouds": return "smoke.fill"
        case "overcast clouds": return "cloud.fill"

        case "shower rain", "light rain": return "cloud.drizzle.fill"
        case "moderate rain", "rain": return "cloud.rain.fill"
        case "heavy intensity rain", "very heavy rain", "extreme rain": return "cloud.heavyrain.fill"
        case "freezing rain": return "thermometer.snowflake"

        case "thunderstorm", "thunderstorm with light rain", "thunderstorm with rain": return "cloud.bolt.fill"
        case "thunderstorm with heavy rain": return "cloud.bolt.rain.fill"
        case "ragged thunderstorm": return "cloud.bolt.fill"

        case "snow", "light snow": return "snowflake"
        case "heavy snow": return "cloud.snow.fill"
        case "sleet", "light shower sleet", "shower sleet": return "cloud.sleet.fill"

        case "light rain and snow", "rain and snow": return "cloud.snow.fill"
        case "light shower snow", "shower snow", "heavy shower snow": return "cloud.snow.fill"

        case "mist", "haze", "fog": return "cloud.fog.fill"
        case "sand", "dust", "volcanic ash": return "aqi.low"
        case "tornado": return "tornado"
        case "squalls": return "wind"

        default: return "questionmark.circle.fill"
    }
}

