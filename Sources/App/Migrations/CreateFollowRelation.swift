//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/2.
//

import Fluent

struct CreateFollowRelation: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(FollowRelation.schema)
            .id()
            .field("from_user_id", .uuid, .required)
            .field("to_user_id", .uuid, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(FollowRelation.schema).delete()
    }
}
