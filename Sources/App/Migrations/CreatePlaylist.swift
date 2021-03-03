//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/30.
//
import Fluent

struct CreatePlaylist: Migration {
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Playlist.schema).delete()
    }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Playlist.schema)
            .id()
            .field("creator_id", .uuid, .required, .references("users", "id"))
            .field("name", .string, .required)
            .field("avatar_url", .string, .required)
            .field("created_at", .date)
            .create()
    }
}
