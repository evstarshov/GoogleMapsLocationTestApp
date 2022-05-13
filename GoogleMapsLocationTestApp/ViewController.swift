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
    
    private let coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapViewConstraints()
    }
    
    // MARK: IBActions
    
    @IBAction func goTo(_ sender: Any) {
        mapView.animate(toLocation: coordinate)
    }
    
    @IBAction func addMarker(sender: UIButton!) {
        print("Placing marker")
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
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
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
    }
}

