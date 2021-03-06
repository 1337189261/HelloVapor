//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/29.
//

import Fluent

struct CreateSong: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Song.schema)
            .id()
            .field("artist_id", .uuid, .required, .references("artists", "id"))
            .field("filename", .string, .required)
            .field("name", .string, .required)
            .field("duration", .int, .required)
            .field("lyric_name", .string)
            .field("created_at", .date)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Song.schema).delete()
    }
}
