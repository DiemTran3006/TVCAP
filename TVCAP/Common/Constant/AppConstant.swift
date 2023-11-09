//
//  AppConstant.swift
//  MangaSocial
//
//  Created by Quang Nguyễn Như on 24/07/2023.
//

import UIKit

struct AppConstant {
    
    static var locale: String {
        get { UserDefaults.standard.value(forKey: "locale-setting") as? String ?? "en-us" }
        set { UserDefaults.standard.setValue(newValue, forKey: "locale-setting") }
    }
    static var modelName: String?
    static var accessToken: String? {
        get { UserDefaults.standard.value(forKey: "access-token") as? String }
        
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "access-token")
                UserDefaults.standard.synchronize()
            } else {
                UserDefaults.standard.setValue(newValue, forKey: "access-token")
            }
        }
    }
//    static var IPAddress: String? {
//        get { UserDefaults.standard.value(forKey: "IPAddress") as? String }
//        set {
//            if newValue == nil {
//                UserDefaults.standard.removeObject(forKey: "IPAddress")
//                UserDefaults.standard.synchronize()
//            } else {
//                UserDefaults.standard.setValue(newValue, forKey: "IPAddress")
//            }
//        }
//    }
    
    static var userId: Int? {
        get { UserDefaults.standard.value(forKey: "userId") as? Int }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "userId")
                UserDefaults.standard.synchronize()
            } else {
                UserDefaults.standard.setValue(newValue, forKey: "userId")
            }
        }
    }
    static var linkAvatar: String? {
        get { UserDefaults.standard.value(forKey: "linkAvatar") as? String }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "linkAvatar")
                UserDefaults.standard.synchronize()
            } else {
                UserDefaults.standard.setValue(newValue, forKey: "linkAvatar")
            }
        }
    }
}
//extension AppConstant {
//    
//    static func saveIp(model: IPAddress) {
//        IPAddress = model.ip
//    }
//    
//    static func logout() {
//        userId = nil
//    }
//    static func saveUser(model: LoginModel) {
//        userId = model.id_user
//        linkAvatar = model.link_avatar
//    }
//  
//}

extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }
    
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}
