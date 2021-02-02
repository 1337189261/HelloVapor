//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/2.
//

import Fluent

struct CreateCommentReply: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(CommentReply.schema)
            .id()
            .field("comment_id", .uuid, .required)
            .field("content", .string, .required)
            .field("user_id", .uuid, .required)
            .field("username", .string, .required)
            .field("avatar_url", .string, .required)
            .field("user_schema", .string, .required)
            .field("like_count", .int, .sql(.default(0)))
            .field("reply_user_id", .uuid, .required)
            .field("reply_user_name", .string, .required)
            .field("reply_user_schema", .string, .required)
            .field("created_at", .date)
            .field("updated_at", .date)
            .field("delete_at", .date)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(CommentReply.schema).delete()
    }
}
