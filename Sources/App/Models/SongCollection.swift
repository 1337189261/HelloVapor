//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/30.
//

import Vapor
import Fluent

final class SongCollection: Model, Content {
    static let schema: String = "song_collections"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String?
    
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
