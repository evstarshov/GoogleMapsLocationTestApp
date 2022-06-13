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
    
    public func save<T: RealmSwiftObject>(_ items: [T]) {
        guard let realmDB = try? Realm() else { return }
        do {
            try! realmDB.write {
                realmDB.add(items)
            }
        }
    }
    
    public func saveCLLToRealm(_ coordinates: [CLLocationCoordinate2D]) {
        guard let realmDB = try? Realm() else { return }
        let locationObject = LocationObject()
        coordinates.forEach { coordinate in
            let location = Location()
            location.latitude = coordinate.latitude
            location.longitude = coordinate.longitude
            locationObject.coordinates.append(location)
        }
        do {
            try! realmDB.write {
                realmDB.add(locationObject)
            }
        }
    }
    
//
    
    public func loadUsers() -> Results<User> {
        let realmDB = try! Realm()
        let locations: Results<User> = realmDB.objects(User.self)
        return locations
    }
    
    public func findUser(named: String) -> User? {
        let realmDB = try! Realm()
        if let query = realmDB.objects(User.self).filter({ $0.login == named }).first {
            print("loading user")
            return query
            
        } else {
            return nil
        }
    }
    
//    let realm = try! Realm()
//    if let jim = realm.objects(Artist.self).filter("name == 'Jim'").first {
//       let myCities = jim.citiesOfInterest
//       let showResults = realm.objects(Show.self)
//                              .filter("city IN %@ AND !(ANY artistResponses.artist.name == 'Jim')", myCities)
//       for show in showResults {
//          print(show.name)
//       }
//    }
    
    public func delete(_ items: [LocationObject]) {
        guard let realmDB = try? Realm() else { return }
        try! realmDB.write {
            realmDB.delete(items)
        }
    }
    
    public func deleteAll() {
        guard let realmDB = try? Realm() else { return }
        try! realmDB.write {
            realmDB.deleteAll()
        }
    }

    func getPersistedRoutes() -> [LocationObject] {
        let realmDB = try! Realm()
        return Array(realmDB.objects(LocationObject.self))
    }
}
