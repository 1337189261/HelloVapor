//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/25.
//

import Fluent

struct CreateArtist: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Artist.schema)
            .id()
            .field("nickname", .string)
            .field("avatar_url", .string)
            .field("schema", .string)
            .field("created_at", .date)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Artist.schema).delete()
    }
}
