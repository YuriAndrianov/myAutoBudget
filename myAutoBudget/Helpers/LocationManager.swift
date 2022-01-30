//
//  LocationManager.swift
//  myAutoBudget
//
//  Created by MacBook on 20.11.2021.
//

import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    let manager = CLLocationManager()
    var completion: ((CLLocation) -> Void)?
    
    func getUserLocation(completion: @escaping ((CLLocation) -> Void)) {
        self.completion = completion
        
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    func findLocationsUsingMapKit(with query: String, mapView: MKMapView, completion: @escaping (([Location]) -> Void)) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let response = response, error == nil else {
                completion([])
                return
            }
            
            let matchingItems = response.mapItems
            
            var locations = [Location]()
            
            for item in matchingItems {
                let title = (item.name ?? "") + ", " + (item.placemark.title ?? "")
                let coordinates = item.placemark.coordinate
                
                let newLocation = Location(title: title , coordinates: coordinates)
                
                locations.append(newLocation)
            }
            
            completion(locations)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        completion?(location)
        manager.stopUpdatingLocation()
    }
    
}
