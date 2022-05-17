//
//  Location.swift
//  GoogleMapsLocationTestApp
//
//  Created by Евгений Старшов on 17.05.2022.
//

import Foundation
import RealmSwift

final class Location: Object, Codable {
    @objc dynamic var longituge: Double = 0.0
    @objc dynamic var latitude: Double = 0.0
}

