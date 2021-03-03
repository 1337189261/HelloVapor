//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/25.
//

import Foundation

extension String {
    var songUrl: String {
        "http://localhost:8080/api/songs/file/" + self + (hasSuffix("mp3") ? "" : ".mp3")
    }
    
    var imgUrl: String {
        "http://localhost:8080/api/images/" + self
    }
}
