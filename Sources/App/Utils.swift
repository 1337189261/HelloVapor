//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/25.
//

import Foundation

var isLinux: Bool {
    #if os(Linux)
        return true
    #else
        return false
    #endif
}

let baseUrl: String = {
    isLinux ? "http://13.88.217.75:80/" : "http://localhost:8080/"
}()

extension String {
    var songUrl: String {
         baseUrl + "api/songs/file/" + self + (hasSuffix("mp3") ? "" : ".mp3")
    }
    
    var imgUrl: String {
        baseUrl + "api/images/" + self
    }
}

import Fluent
import Vapor

protocol QueryableModel: Model {
    static func query(with req: Request) -> QueryBuilder<Self>
}
