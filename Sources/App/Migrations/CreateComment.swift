//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/2.
//

import Fluent

struct CreateComment: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Comment.schema)
            .id()
            .field("song_id", .uuid, .required)
            .field("content", .string, .required)
            .field("user_id", .uuid, .required)
            .field("like_count", .int, .sql(.default(0)))
            .field("created_at", .date)
            .field("updated_at", .date)
            .field("deleted_at", .date)
            .field("netease_comment_id", .int)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Comment.schema).delete()
    }
}
