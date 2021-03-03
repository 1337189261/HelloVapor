//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/25.
//

import Foundation
import Fluent

struct CreatePlaylistSongRelation: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(PlaylistSongRelation.schema)
            .id()
            .field("playlist_id", .uuid, .required)
            .field("song_id", .uuid, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(PlaylistSongRelation.schema)
            .delete()
    }
}
