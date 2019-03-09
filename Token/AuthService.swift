//
//  AuthService.swift
//  Spotify-Demo
//
//  Created by JOY JOSE on 01/03/19.
//  Copyright © 2019 Riverswave Technologies, India. All rights reserved.
//


import Foundation
import UIKit
class AuthService{
    
    
    let defaults = UserDefaults.standard
    
    static let instance = AuthService()
    
    var isLoggedIn: Bool{
        get {
            return defaults.bool(forKey: UserDefaults.isLoggedIn)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.isLoggedIn)
        }
    }
    
    var tokenId: String? {
        get {
            return defaults.value(forKey: UserDefaults.tokenId) as? String
        } set {
            defaults.set(newValue, forKey: UserDefaults.tokenId)
        }
}
    var sessiontokenId: String? {
        get {
            return defaults.value(forKey: UserDefaults.sessiontokenId) as? String
        } set {
            defaults.set(newValue, forKey: UserDefaults.sessiontokenId)
        }
    }
    var sessionuserId: String? {
        get {
            return defaults.value(forKey: UserDefaults.sessionuserId) as? String
        } set {
            defaults.set(newValue, forKey: UserDefaults.sessionuserId)
        }
    }
}
