//
//  RealmDB.swift
//  GoogleMapsLocationTestApp
//
//  Created by Евгений Старшов on 17.05.2022.
//

import Foundation
import Realm
import RealmSwift
import CoreLocation

final class RealmDB {
    
    init() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: 7)
    }
    
    public func save(_ items: [Location]) {
        let realm = try! Realm()
        do {
            try! realm.write {
                realm.add(items)
            }
        }
    }
    
    public func load() -> Results<Location> {
        let realm = try! Realm()
        let locations: Results<Location> = realm.objects(Location.self)
        return locations
    }
    
    func delete(_ items: [Location]) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(items)
        }
    }
}
