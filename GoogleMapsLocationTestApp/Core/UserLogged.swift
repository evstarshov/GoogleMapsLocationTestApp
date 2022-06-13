//
//  UserLogged.swift
//  GoogleMapsLocationTestApp
//
//  Created by Евгений Старшов on 08.06.2022.
//

import Foundation

final class UserIsLoggedIn {
    static let shared = UserIsLoggedIn()
    var userLogin: String?
    var userAvatar: String?
}
