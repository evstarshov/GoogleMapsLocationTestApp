//
//  ViewController.swift
//  GoogleMapsLocationTestApp
//
//  Created by Евгений Старшов on 13.05.2022.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addMarkerButton: UIButton!
    
    
    // MARK: Properties
    
    private var coordinate: CLLocationCoordinate2D?
    private var manualMarker: GMSMarker?
    private var locationManager: CLLocationManager?
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
        setMapViewConstraints()
    }
    
    // MARK: IBActions
    
    @IBAction func currentLocation(_ sender: Any) {
        locationManager?.requestLocation()
    }
    
    @IBAction func addMarker(sender: UIButton!) {
        manualMarker == nil ? addMarker() : removeMarker()
    }
    
    @IBAction func updateLocation(_ sender: Any) {
        locationManager?.startUpdatingLocation()
    }
    
    // MARK: Private methods
    
    private func setMapViewConstraints() {
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.mapView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.mapView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        self.mapView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.mapView.addSubview(addMarkerButton)
        self.addMarkerButton.translatesAutoresizingMaskIntoConstraints = false
        self.addMarkerButton.backgroundColor = .systemBlue
        self.addMarkerButton.rightAnchor.constraint(equalTo: self.mapView.rightAnchor).isActive = true
        self.addMarkerButton.leftAnchor.constraint(equalTo: self.mapView.leftAnchor).isActive = true
        self.addMarkerButton.bottomAnchor.constraint(equalTo: self.mapView.bottomAnchor).isActive = true
    }
    
    private func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinate ?? CLLocationCoordinate2D(latitude: 55.7522, longitude: 37.6156), zoom: 5)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
    }
    
    private func addMarker() {
        print("Placing marker")
        let marker = GMSMarker(position: coordinate ?? CLLocationCoordinate2D(latitude: 55.7522, longitude: 37.6156))
        marker.map = mapView
        self.manualMarker = marker
    }
    
    private func removeMarker() {
        print("removing marker")
        manualMarker?.map = nil
        manualMarker = nil
    }
    
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestWhenInUseAuthorization()
    }
}

// MARK: Extensions for ViewController

extension ViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print(coordinate)
        if let manualMarker = manualMarker {
            manualMarker.position = coordinate
        } else {
            let marker = GMSMarker(position: coordinate)
            marker.map = mapView
            self.manualMarker = marker
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.first)
        coordinate = CLLocationCoordinate2D(latitude: locations.last?.coordinate.latitude ?? 55.7522, longitude: locations.last?.coordinate.longitude ?? 37.6156)
        addMarker()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}


