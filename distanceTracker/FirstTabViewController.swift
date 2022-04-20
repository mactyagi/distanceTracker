//
//  FirstTabViewController.swift
//  distanceTracker
//
//  Created by manukant tyagi on 19/04/22.
//

import UIKit
import MapKit
import CoreLocation
class FirstTabViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackingButton:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        trackingButton.layer.cornerRadius = 10
        LocationManager.shared.delegate = self
        self.trackingButton.setTitle("Start Tracking", for: .normal)
    }
    
    @IBAction func startTrackingButtonPressed(){
        if trackingButton.titleLabel?.text == "Start Tracking"{
                self.mapView.userTrackingMode = .follow
            self.trackingButton.setTitle("Stop Tracking", for: .normal)
            LocationManager.shared.getUserLocation { location in
                if let location = location {
                    self.mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)), animated: true)
                    LocationManager.shared.startTracking { (distance) in
                        if distance == nil {
                            self.trackingButton.setTitle("Start Tracking", for: .normal)
                            self.promptForAuthorization()
                        }else{
                            self.trackingButton.setTitle(distance, for: .normal)
                        }
                        
                    }
                }else{
                    self.trackingButton.setTitle("Start Tracking", for: .normal)
                }
            }
                
        }else{
            self.trackingButton.setTitle("Start Tracking", for: .normal)
            LocationManager.shared.stopTracking()
        }
    }
    
    @IBAction func getLocationButtonPressed(sender: UIButton){
        LocationManager.shared.getUserLocation { [weak self](location) in
            DispatchQueue.main.async {
                guard let location = location else {
                    self?.promptForAuthorization()
                    return
                }
                self?.mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)), animated: true)
            }
        }
        
    }
    
    
    //MARK: - functions
    private func promptForAuthorization() {
        let alert = UIAlertController(title: "Location access is needed to get your current location", message: "Please allow location access", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        alert.preferredAction = settingsAction
        present(alert, animated: true, completion: nil)
    }
    
}
extension FirstTabViewController: LocationManagerDelegate{
    func callAlert() {
        promptForAuthorization()
    }
    

}
