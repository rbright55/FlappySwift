//
//  Keys.swift
//  FlappyBird
//
//  Created by Mac on 8/8/18.
//  Copyright © 2018 Fullstack.io. All rights reserved.
//

import Foundation

enum Keys: String {
    case sdlAppID = "sdl-app-id"
    case sdlAppName = "sdl-app-name"
    
    var value: String {
        return Keys.keyDict[rawValue] as? String ?? ""
    }
    
    private static let keyDict: NSDictionary = {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) else { return [:] }
        return dict
    }()
}
