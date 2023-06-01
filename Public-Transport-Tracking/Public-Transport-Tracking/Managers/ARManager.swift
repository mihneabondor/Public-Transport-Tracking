import ARKit_CoreLocation
import CoreLocation
import UIKit
import SwiftUI
import Foundation
import MapKit

class ARManager: UIViewController, ObservableObject {
    var sceneLocationView = SceneLocationView()
    var locationManager : CLLocationManager?
    var locationStatus: CLAuthorizationStatus?
    var lastLocation: CLLocation?
    var region : MKCoordinateRegion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
        sceneLocationView.orientToTrueNorth = true
        sceneLocationView.scalesLargeContentImage = false
        locationManager?.requestLocation()
    }
}

extension ARManager : CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        sceneLocationView.removeAllNodes()
        Task {
            let stations = try? await RequestManager().getStops()
            for station in stations ?? [] {
                let stationLocation = CLLocation(latitude: station.lat ?? 0, longitude: station.long ?? 0)
                if location.distance(from: stationLocation) < 100 {
                    let coordinate = CLLocationCoordinate2D(latitude: station.lat ?? 0, longitude: station.long ?? 0)
                    let location = CLLocation(coordinate: coordinate, altitude: location.altitude)
                    
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
                    label.text = station.stopName ?? "Station"
                    label.textColor = .black
                    label.textAlignment = .center
                    label.backgroundColor = .white
                    label.layer.masksToBounds = true
                    label.layer.cornerRadius = 20
                    
                    let annotationNode = LocationAnnotationNode(location: location, view: label)
                    sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                }
            }
        }
    }
}

struct ARView : UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARManager {
        let vc = ARManager()
        return vc
    }
    func updateUIViewController(_ uiViewController: ARManager, context: Context) {}
    
    typealias UIViewControllerType = ARManager
}
