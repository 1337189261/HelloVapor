//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/29.
//

import Fluent
import Vapor

final class Song: Model, Content {
    
    static let schema = "songs"
    
    @ID
    var id: UUID?
    
    @Parent(key: "user_id")
    var author: User
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "duration")
    var duration: String
    
    init() { }
    
    init(id: UUID? = nil, authorId: User.IDValue, name: String, duration: String) {
        self.id = id
        self.$author.id = authorId
        self.name = name
        self.duration = duration
    }
}
