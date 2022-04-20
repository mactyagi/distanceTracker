//
//  LocationManager.swift
//  distanceTracker
//
//  Created by manukant tyagi on 19/04/22.
//

import Foundation
import CoreLocation
import UserNotifications
protocol LocationManagerDelegate {
    func callAlert()
}

class LocationManager: NSObject, CLLocationManagerDelegate{
    static let shared = LocationManager()
    var delegate: LocationManagerDelegate?
    private var db: DBManager!
    private var isTracking = false
    private var manager : CLLocationManager?
    private var startDate: Date?
    private var startLocation: CLLocation?
    private var lastLocation: CLLocation?
    private var traveledDistance: Double = 0.0
    private var milestone = 50
    private var completion: ((CLLocation?) -> Void)?
    private var secondComp: ((String?) -> Void)?
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    
    init(manager: CLLocationManager = CLLocationManager()) {
        super.init()
        self.manager = manager
        self.manager?.requestAlwaysAuthorization()
        self.manager?.delegate = self
        self.db = DBManager()
    }
    
    
    public func getUserLocation(comp: @escaping ((CLLocation?) -> Void)) {
        if isTracking{
            comp(lastLocation)
            return
        }
        if CLLocationManager.locationServicesEnabled(){
            switch manager?.authorizationStatus {
            case .notDetermined, .restricted, .denied:
             comp(nil)
            case .authorizedAlways, .authorizedWhenInUse, .authorized:
                isTracking = false
                self.completion = comp
                manager?.startUpdatingLocation()
            default:
                comp(nil)
            }
            
            
        }else{
            comp(nil)
        }
        
    }
    
    public func stopTracking(){
        manager?.stopUpdatingLocation()
        let dateformat = DateFormatter()
        dateformat.dateFormat = "dd-mm-yyyy"
        if let startDate = startDate {
            let date = dateformat.string(from: startDate)
            dateformat.dateFormat = "h:mm a"
            let time = dateformat.string(from: startDate)
            db.insert(date: date, time: time, distance: String(traveledDistance))
        }
        isTracking = false
        milestone = 50
        startLocation = nil
        startDate = nil
        lastLocation = nil
        traveledDistance = 0
    }
    
    public func startTracking(comp: @escaping (String?) -> Void){
        if CLLocationManager.locationServicesEnabled(){
            switch manager?.authorizationStatus {
            case .notDetermined, .restricted, .denied:
             comp(nil)
            case .authorizedAlways, .authorizedWhenInUse, .authorized:
                isTracking = true
                self.secondComp = comp
                manager?.allowsBackgroundLocationUpdates = true
                manager?.showsBackgroundLocationIndicator = true
                manager?.desiredAccuracy = kCLLocationAccuracyBest
                manager?.startUpdatingLocation()
                manager?.startMonitoringSignificantLocationChanges()
                manager?.distanceFilter = 1
            default:
                comp(nil)
            }
            
        }else{
                comp(nil)
        }
        
    }
    
    private func sendNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = ""
        notificationContent.body = "\(milestone)M run has completed"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification",
                                            content: notificationContent,
                                            trigger: trigger)
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !isTracking{
            guard let location = locations.first else{
                return
            }
            manager.stopUpdatingLocation()
            completion?(location)
            
        }else{
            if startLocation == nil {
                        startDate = Date()
                        startLocation = locations.first
                        lastLocation = locations.first
                    } else if let location = locations.last {
                        traveledDistance += lastLocation?.distance(from: location) ?? 0
                        traveledDistance = traveledDistance.truncate(places: 2)
                        print("Traveled Distance:",  traveledDistance)
                        if traveledDistance >= Double(milestone){
                            sendNotification()
                            milestone += 50
                            
                        }
                        secondComp?(String(traveledDistance))
                        lastLocation = locations.last
                    }
                    
        }
       
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            delegate?.callAlert()
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        case .authorized:
            break
        @unknown default:
            break
        }
    }
}

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

