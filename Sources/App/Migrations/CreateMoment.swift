//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/3/22.
//

import Fluent

struct CreateMoment: Migration {
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Moment.schema).delete()
    }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Moment.schema)
            .id()
            .field("content", .string, .required)
            .field("user_id", .uuid, .required)
            .field("like_count", .int, .sql(.default(0)))
            .field("post_count", .int, .sql(.default(0)))
            .field("comment_count", .int, .sql(.default(0)))
            .field("images", .array(of: .string))
            .field("location", .string)
            .field("created_at", .date)
            .field("updated_at", .date)
            .field("deleted_at", .date)
            .create()
    }
}

