//
//  Location.swift
//  GoogleMapsLocationTestApp
//
//  Created by Евгений Старшов on 17.05.2022.
//

import Foundation
import Realm
import RealmSwift
import CoreLocation

final class Location: Object, Codable {
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    
    var clLocation: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }

    required convenience init? (clLocation: CLLocationCoordinate2D) {
        self.init()
        self.longitude = clLocation.longitude
        self.latitude = clLocation.latitude
    }

}


final class LocationObject: Object {
    let coordinates = List<Location>()
}
