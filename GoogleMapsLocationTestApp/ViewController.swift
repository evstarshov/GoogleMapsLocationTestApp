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
    private let locationObject = LocationObject()
    private var beginBackgroundTask: UIBackgroundTaskIdentifier?
    private var coordinate: CLLocationCoordinate2D?
    private var manualMarker: GMSMarker?
    private var locationManager: CLLocationManager?
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    private var locationsArr = [Location]()
    private var cllocationCoordinates = [CLLocation]()
    private var locationsDB: Results<Location>?
    private var markers = [GMSMarker]()
    private var isTracking: Bool = false

    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
        print("Realm file is here: \(Realm.Configuration.defaultConfiguration.fileURL!)")
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
        cllocationCoordinates.removeAll()
        route?.map = mapView
        locationManager?.startUpdatingLocation()
        isTracking = true
    }
    
    @IBAction func stopTrackButtonTapped() {
        markers.forEach { $0.map = nil }
        database.deleteAll()
        database.saveToRealm(cllocationCoordinates)
        route?.map = nil
        cllocationCoordinates.removeAll()
        locationManager?.stopUpdatingLocation()
        isTracking = false
        
    }
    
    @IBAction func lastRouteButtonTapped() {
        guard isTracking == false else { showAlert()
            return
        }
        cllocationCoordinates.removeAll()
        loadRoute(database.getPersistedRoutes(), index: 0)
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        cllocationCoordinates.forEach { coordinate in
            routePath?.add(coordinate.coordinate)
        }
        route?.path = routePath
        route?.map = mapView
        let position = GMSCameraPosition.camera(withTarget: cllocationCoordinates.middle?.coordinate ?? CLLocationCoordinate2D(latitude: 55.7522, longitude: 37.6156), zoom: 12)
        mapView.animate(to: position)
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
        markers.append(marker)
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
    
    private func loadRoute(_ routesArray: [LocationObject], index: Int = 0) {
        let currentRoute = routesArray[index]
        currentRoute.coordinates.forEach { coordinate in
            cllocationCoordinates.append(coordinate.clLocation)
        }
    }
    
    // ----- Alerts and notifications
    
    private func showAlert() {
        let alertVC = UIAlertController(title: "Error", message: "Tracking is on. Disabling tracking", preferredStyle: .alert)
        let alertItem = UIAlertAction(title: "Ok", style: .cancel) { [weak self] _ in
            self?.database.deleteAll()
            self?.database.saveToRealm(self!.cllocationCoordinates)
            self?.route?.map = nil
            self?.cllocationCoordinates.removeAll()
            self?.locationManager?.stopUpdatingLocation()
            self?.isTracking = false
        }
        alertVC.addAction(alertItem)
        present(alertVC, animated: true)
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
        route = GMSPolyline()
        routePath = GMSMutablePath()
        routePath?.add(location.coordinate)
        route?.path = routePath
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15)
        coordinate = location.coordinate
        mapView.animate(to: position)
        cllocationCoordinates.append(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}


