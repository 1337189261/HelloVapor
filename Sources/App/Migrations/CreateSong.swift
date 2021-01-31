//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/29.
//

import Fluent

struct CreateSong: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("songs")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("name", .string, .required)
            .field("duration", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("songs").delete()
    }
}
