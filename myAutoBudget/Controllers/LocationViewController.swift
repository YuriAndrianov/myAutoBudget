//
//  LocationViewController.swift
//  myAutoBudget
//
//  Created by MacBook on 20.11.2021.
//

import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController {
    
    weak var delegate: LocationViewControllerDelegate?
   
    let mapView = MKMapView()
    let pin = MKMarkerAnnotationView()
    let latitude = 0.0
    let longitude = 0.0

    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .label
        return label
    }()
    
    let field: UITextField = {
        let field = UITextField()
        field.placeholder = "Поиск по карте"
        field.layer.cornerRadius = 9
        field.backgroundColor = .tertiarySystemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        field.leftViewMode = .always
        return field
    }()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.backgroundColor = .secondarySystemBackground
        return table
    }()
    
    let locateButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: "location.north"), for: .normal)
        return button
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "done"), for: .normal)
        return button
    }()
    
    var locations = [Location]()
    var previousLocation: CLLocation?
    var editingAllowed = false
    var onlyMap = false
    var placeString: String? = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
        if !editingAllowed {
            getUserCurrentLocation()
        } else {
            showLocationFromLabelText()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    private func configureView() {
        view.backgroundColor = .secondarySystemBackground
        
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.addSubview(pin)
        mapView.addSubview(label)
        
        if onlyMap == false {
            view.addSubview(field)
            field.delegate = self
            
            view.addSubview(tableView)
            tableView.delegate = self
            tableView.dataSource = self
            
            view.addSubview(doneButton)
            doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
            
            mapView.addSubview(locateButton)
            locateButton.addTarget(self, action: #selector(locateButtonTapped(_:)), for: .touchUpInside)
        }
        
        let closeButton = StyleSheet().createCloseButton(on: view)
        closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
    }
    
    private func layoutViews() {
        
        if onlyMap == false {
            mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 2)
            pin.center = mapView.center
            
            field.frame = CGRect(x: 10,
                                 y: mapView.frame.maxY + 10,
                                 width: view.frame.size.width - 70,
                                 height: 40)
            
            locateButton.frame = CGRect(x: mapView.frame.width - 49,
                                       y: mapView.frame.height - 55,
                                       width: 40,
                                       height: 40)
            
            doneButton.frame = CGRect(x: view.frame.size.width - 55, y: mapView.frame.maxY + 5, width: 50, height: 50)
            
            let tableY = field.frame.origin.y + field.frame.size.height + 5
            tableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height - tableY)
        } else {
            mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            pin.center = mapView.center
        }
        
        label.sizeToFit()
        label.frame = CGRect(x: 10,
                             y: 60,
                             width: mapView.frame.size.width - 20,
                             height: 60)
        
    }
    
    private func getUserCurrentLocation() {
        LocationManager.shared.getUserLocation { [weak self] location in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: location.coordinate,
                                                span: span)
                self.mapView.setRegion(region, animated: true)
                self.previousLocation = location
                self.updateLocationLabel(location)
            }
        }
    }
    
    private func showLocationFromLabelText() {
        LocationManager.shared.findLocationsUsingMapKit(with: label.text!, mapView: mapView) { [weak self] locations in
            
            guard let self = self else { return }
            guard let location = locations.first else { return }
            guard let coordinate = location.coordinates else { return }
            
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: coordinate,
                                            span: span)
            self.mapView.setRegion(region, animated: true)
            self.previousLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func updateLocationLabel(_ center: CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(center) { [weak self] placemarks, error in
            guard let self = self else { return }
            guard let placemark = placemarks?.first, error == nil else { return }
            
            var labelText = ""
            
            if let city = placemark.locality {
                labelText += city
            }
            
            if let place = placemark.name {
                labelText += ", " + place
            }
//
//            if let street = placemark.thoroughfare {
//                labelText += ", \(street)"
//            }
//
//            if let number = placemark.subThoroughfare {
//                labelText += ", \(number)"
//            }
            
            self.label.text = labelText
            
            if let locationCoordinatesText = placemark.location?.coordinate {
                self.placeString = self.label.text! + " \n\(locationCoordinatesText.latitude) \(locationCoordinatesText.longitude)"
            }
        }
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        dismiss(animated: true)
    }
    
    @objc private func locateButtonTapped(_ sender: UIButton) {
        getUserCurrentLocation()
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        guard let text = placeString else { return }
        delegate?.updateLocationString(with: text)
        dismiss(animated: true)
    }

}

extension LocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        field.resignFirstResponder()
        if let text = field.text, !text.isEmpty {
            LocationManager.shared.findLocationsUsingMapKit(with: text, mapView: mapView) { [weak self] locations in
                DispatchQueue.main.async {
                    self?.locations = locations
                    self?.tableView.reloadData()
                }
            }
        }
        return true
    }

}

extension LocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = locations[indexPath.row].title
        content.textProperties.numberOfLines = 0
        cell.contentConfiguration = content
        cell.backgroundColor = .secondarySystemBackground
        cell.contentView.backgroundColor = .secondarySystemBackground
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let coordinate = locations[indexPath.row].coordinates else { return }

        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate,
                                        span: span)
        mapView.setRegion(region, animated: true)
    }
    
}

extension LocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)

        guard let previousLocation = previousLocation else { return }

        guard center.distance(from: previousLocation) > 20 else { return }
        self.previousLocation = center
        
        updateLocationLabel(center)
    }
    
}
