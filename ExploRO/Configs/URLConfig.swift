import Foundation

enum RunningDevice {
    case simulator
    case device
    // case production // Commented out, so remove from switch too
}

struct AppConfig {
    static let current: RunningDevice = .device

    static var baseURL: String {
        switch current {
        case .simulator:
            return "http://localhost:3000"
        case .device:
            return "http://Sandas-MacBook-Pro.local:3000"
        }
    }

    static var landmarkBaseURL: String {
        switch current {
        case .simulator:
            return "http://localhost:8000"
        case .device:
            return "http://Sandas-MacBook-Pro.local:8000"
        }
    }
}
