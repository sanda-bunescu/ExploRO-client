import Foundation
import CoreLocation

struct LocationData: Codable {
    let locality: String
    let country: String
}
final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var locationDescription: LocationData = LocationData(locality: "", country: "")
    
    private var manager = CLLocationManager()
    private var lastGeocodeDate: Date = .distantPast

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        checkLocationAuthorization()
    }

    func checkLocationAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationDescription = LocationData(locality: "Unknown location", country: "")
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        @unknown default:
            locationDescription = LocationData(locality: "Unknown location", country: "")
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastKnownLocation = location.coordinate

        let now = Date()
        guard now.timeIntervalSince(lastGeocodeDate) > 10 else { return }
        lastGeocodeDate = now

        lookUpCurrentLocation { placemark in
            if let placemark = placemark {
                self.locationDescription = LocationData(locality: placemark.locality ?? "", country: placemark.country ?? "")
            } else {
                self.locationDescription = LocationData(locality: "Unknown location", country: "")
            }
        }
    }

    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void) {
        guard let lastLocation = manager.location else {
            completionHandler(nil)
            return
        }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(lastLocation) { placemarks, error in
            if error == nil {
                completionHandler(placemarks?.first)
            } else {
                completionHandler(nil)
            }
        }
    }
}
