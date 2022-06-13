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
import RxSwift

class ViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addMarkerButton: UIButton!
    @IBOutlet weak var beginTrackButton: UIButton!
    @IBOutlet weak var stopTrackButton: UIButton!
    
    
    // MARK: Properties
    
    private let disposeBag = DisposeBag()
    private let database = RealmDB()
    private let locationManager = LocationManager.instance
    private var beginBackgroundTask: UIBackgroundTaskIdentifier?
    private var coordinates = [CLLocationCoordinate2D]()
    private var manualMarker: GMSMarker?
    private var avatarMarker: GMSMarker?
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    private var locationsDB = [LocationObject]()
    private var markers = [GMSMarker]()
    private var avatarMarkers = [GMSMarker]()
    private var isTracking: Bool = false
    var user: User?
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationsDB = database.getPersistedRoutes()
        user = database.findUser(named: UserIsLoggedIn.shared.userLogin ?? "eroor loading user")
        configureMap()
        configureLocationManager()
        print("Realm file is here: \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    // MARK: IBActions
    
    @IBAction func currentLocation(_ sender: Any) {
        locationManager.requestLocation()
        configureMap()
    }
    
    @IBAction func addMarker(sender: UIButton!) {
        manualMarker == nil ? addMarker() : removeMarker()
    }
    
    @IBAction func beginTrackButtonTapped() {
        coordinates.removeAll()
        route?.map = mapView
        locationManager.startUpdatingLocation()
        isTracking = true
    }
    
    @IBAction func stopTrackButtonTapped() {
        guard isTracking == true else { return }
        markers.forEach { $0.map = nil }
        route?.map = nil
        coordinates.removeAll()
        locationManager.stopUpdatingLocation()
        isTracking = false
    }
    
    @IBAction func lastRouteButtonTapped() {
        guard isTracking == false else { showAlert()
            return
        }
        coordinates.removeAll()
        loadRoute(database.getPersistedRoutes(), index: 0)
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        coordinates.forEach { coordinate in
            routePath?.add(coordinate)
        }
        route?.path = routePath
        route?.map = mapView
        let position = GMSCameraPosition.camera(withTarget: coordinates.middle ?? CLLocationCoordinate2D(latitude: 55.7522, longitude: 37.6156), zoom: 12)
        mapView.animate(to: position)
    }
    
    // MARK: Private methods
    
    // ----- Map methods
    
    private func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinates.last ?? CLLocationCoordinate2D(latitude: 55.7522, longitude: 37.6156), zoom: 12)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
    }
    
    private func configureLocationManager() {
        locationManager
            .location
            .asObservable()
            .subscribe { [weak self] location in
                print("Inside closure \(location)")
                guard let location = location.element?.last else { return }
                self?.routePath?.add(location.coordinate)
                self?.route?.path  = self?.routePath
                let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15)
                self?.avatarMarker == nil ? self?.addAvatarmarker(position: location.coordinate) : self?.removeAvatarMarker()
                self?.coordinates.append(location.coordinate)
                self?.mapView.animate(to: position)
                self?.database.saveCLLToRealm(self!.coordinates)
            }.disposed(by: disposeBag)
    }
    
    private func addMarker() {
        print("Placing marker")
        let marker = GMSMarker(position: coordinates.last ?? CLLocationCoordinate2D(latitude: 55.7522, longitude: 37.6156))
        marker.map = mapView
        self.manualMarker = marker
        markers.append(marker)
    }
    
    private func addAvatarmarker(position: CLLocationCoordinate2D) {
        let rect = CGRect(x: 0, y: 0, width: 50, height: 50)
        let view = UIView(frame: rect)
        let imageView = UIImageView(frame: rect)
        let imageString = user?.imageData.toImage()
        if user?.imageData == "camera" {
            imageView.image = UIImage(named: "camera")
        }
        else {
            imageView.image = imageString
        }
        view.addSubview(imageView)
        let marker = GMSMarker(position: position)
        marker.map = mapView
        marker.iconView = view
        self.avatarMarker = marker
        avatarMarkers.append(marker)
    }
    
    private func removeMarker() {
        print("removing marker")
        manualMarker?.map = nil
        manualMarker = nil
    }
    
    private func removeAvatarMarker() {
        print("removing marker")
        avatarMarker?.map = nil
        avatarMarker = nil
    }
    
    private func loadRoute(_ routesArray: [LocationObject], index: Int = 0) {
        let currentRoute = routesArray[index]
        currentRoute.coordinates.forEach { coordinate in
            coordinates.append(coordinate.clLocation)
        }
    }
    
    // ----- Alerts and notifications
    
    private func showAlert() {
        let alertVC = UIAlertController(title: "Error", message: "Tracking is on. Disabling tracking", preferredStyle: .alert)
        let alertItem = UIAlertAction(title: "Ok", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.database.delete(self.locationsDB)
            self.database.save(self.locationsDB)
            self.route?.map = nil
            self.coordinates.removeAll()
            self.locationManager.stopUpdatingLocation()
            self.isTracking = false
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

