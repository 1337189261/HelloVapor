//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/25.
//

import Fluent

struct CreatePlaylistFollowRelation: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(PlaylistFollowRelation.schema)
            .id()
            .field("playlist_id", .uuid, .required)
            .field("user_id", .uuid, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(PlaylistFollowRelation.schema)
            .delete()
    }
}
