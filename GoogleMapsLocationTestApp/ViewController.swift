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
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapViewConstraints()
        //configureMap()
    }
    
    // MARK: IBActions
    
    @IBAction func goTo(_ sender: Any) {
        configureMap()
    }
    
    // MARK: Private methods
    
    private func setMapViewConstraints() {
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.mapView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.mapView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        self.mapView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func configureMap() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        mapView.camera = camera
    }


}

