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
    isLinux ? "http://193.123.246.233:80/" : "http://localhost:8080/"
}()

extension String {
    var songUrl: String {
         baseUrl + "api/songs/file/" + self + (hasSuffix("mp3") ? "" : ".mp3")
    }
    
    var imgUrl: String {
        baseUrl + "api/images/" + self
    }
}
