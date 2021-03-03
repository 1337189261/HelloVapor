//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/25.
//

import Fluent

class CreateUserArtistFollowRelation: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(UserArtistFollowRelation.schema)
            .id()
            .field("user_id", .uuid, .required)
            .field("artist_id", .uuid, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(UserArtistFollowRelation.schema)
            .delete()
    }
}
