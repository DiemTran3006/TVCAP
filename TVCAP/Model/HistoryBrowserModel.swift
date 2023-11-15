//
//  HistoryBrowserModel.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 13/11/2023.
//

import Foundation
import UIKit
import RealmSwift

class HistoryBrowserModel: Object {
    @Persisted var id: String
    @Persisted var favicon: Data
    @Persisted var title: String
    @Persisted var url: String
    @Persisted var dateTime: String

    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(url: String, dateTime: String) {
        self.init()
        self.id = UUID().uuidString
        self.url = url
        self.dateTime = dateTime

        guard let URLFavicon = URL(string: FavIcon(url)[.m]),
              let data = try? Data(contentsOf: URLFavicon),
              let URL = URL(string: url) else { return }

        self.favicon = data
        
        guard let content = try? String(contentsOf: URL, encoding: .utf8),
              let range = content.range(of: "<title>.*?</title>", options: .regularExpression, range: nil, locale: nil)
        else {
            self.title = ""
            return
        }
        let title = content[range].replacingOccurrences(of: "</?title>", with: "", options: .regularExpression, range: nil)
        print(title) // prints "ios - Get Title when input URL on UITextField on swift 4 - Stack Overflow"
        self.title = title
    }
    
    func isExistRealm() -> Bool? {
        let realm = try? Realm()
        guard let realm = realm else { return nil}
        let results = realm.objects(Self.self).filter(NSPredicate(format: "id == %@", self.id))
        if results.isEmpty {
            return false
        }
        return true
    }
    
    func toggleRealm() {
        if self.isExistRealm() == true {
            let realm = try? Realm()
            guard let realm = realm else { return }
            let results = realm.objects(Self.self).filter(NSPredicate(format: "id == %@", self.id))
            try? realm.write {
                realm.delete(results)
            }
        } else if self.isExistRealm() == false {
            let realm = try? Realm()
            guard let realm = realm else { return }
            try? realm.write {
                realm.add(self)
            }
        }
    }
}

struct FavIcon {
    enum Size: Int, CaseIterable { case s = 16, m = 32, l = 64, xl = 128, xxl = 256, xxxl = 512 }
    private let domain: String
    init(_ domain: String) { self.domain = domain }
    subscript(_ size: Size) -> String {
        "https://www.google.com/s2/favicons?sz=\(size.rawValue)&domain=\(domain)"
    }
}
