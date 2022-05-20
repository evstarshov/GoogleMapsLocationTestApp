//
//  User.swift
//  GoogleMapsLocationTestApp
//
//  Created by Евгений Старшов on 20.05.2022.
//

import Foundation
import Realm
import RealmSwift

final class User: Object, Codable {
    @objc dynamic var login: String = ""
    @objc dynamic var password: String = ""
}
