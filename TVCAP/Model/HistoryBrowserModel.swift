//
//  HistoryBrowserModel.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 13/11/2023.
//

import Foundation
import UIKit

struct HistoryBrowserModel: Codable {
    let favicon: Data
    let title: String
    let url: String
    let dateTime: String
    
    init(url: String, dateTime: String) {
        self.url = url
        self.dateTime = dateTime
        
        let URLFavicon = URL(string: FavIcon(url)[.s])!
        let data = try? Data(contentsOf: URLFavicon)
        
        self.favicon = data!
        
        let URL = URL(string: url)!
        if let content = try? String(contentsOf: URL, encoding: .utf8) {
            if let range = content.range(of: "<title>.*?</title>", options: .regularExpression, range: nil, locale: nil) {
                let title = content[range].replacingOccurrences(of: "</?title>", with: "", options: .regularExpression, range: nil)
                print(title) // prints "ios - Get Title when input URL on UITextField on swift 4 - Stack Overflow"
                self.title = title
            } else {
                self.title = ""
            }
        } else {
            self.title = ""
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
