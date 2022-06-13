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
    @objc dynamic var imageData: String = ""
    
    convenience init(login: String, password: String, imageData: String) {
        self.init()
        self.login = login
        self.password = password
        self.imageData = imageData
    }

}


final class UserObject: Object {
    let users = List<User>()
}
