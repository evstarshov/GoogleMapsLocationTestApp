//
//  ViewController.swift
//  GoogleMapsLocationTestApp
//
//  Created by Евгений Старшов on 13.05.2022.
//

import UIKit
import GoogleMaps
import Realm
import RealmSwift

class ViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addMarkerButton: UIButton!
    @IBOutlet weak var beginTrackButton: UIButton!
    @IBOutlet weak var stopTrackButton: UIButton!
    
    
    // MARK: Properties
    
    private let database = RealmDB()
    private var beginBackgroundTask: UIBackgroundTaskIdentifier?
    private var coordinate: CLLocationCoordinate2D?
    private var manualMarker: GMSMarker?
    private var locationManager: CLLocationManager?
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    private var locationsDB = [Location]()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
    }
    
    // MARK: IBActions
    
    @IBAction func currentLocation(_ sender: Any) {
        locationManager?.requestLocation()
        configureMap()
    }
    
    @IBAction func addMarker(sender: UIButton!) {
        manualMarker == nil ? addMarker() : removeMarker()
    }
    
    @IBAction func beginTrackButtonTapped() {
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
        locationManager?.startUpdatingLocation()
    }
    
    @IBAction func stopTrackButtonTapped() {
        database.save(locationsDB)
        route?.map = nil
        locationManager?.stopUpdatingLocation()
    }
    
    // MARK: Private methods
    
    // ----- Map methods
    
    private func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinate ?? CLLocationCoordinate2D(latitude: 55.7522, longitude: 37.6156), zoom: 12)
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
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.requestWhenInUseAuthorization()
    }
    
    private func configureBackGroundMode() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
        
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
        }
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
        guard let location = locations.last else { return }
        routePath?.add(location.coordinate)
        route?.path = routePath
        print(locations.last)
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15)
        coordinate = location.coordinate
        mapView.animate(to: position)
        let latLocation = Location(clLocation: location)
        addMarker()
        locationsDB.append(latLocation!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}


