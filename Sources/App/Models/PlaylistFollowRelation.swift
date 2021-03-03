//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/21.
//

import Fluent
import Vapor

final class PlaylistFollowRelation: Model {
    
    static var schema: String = "playlist_follow_relation"
    
    @ID
    var id: UUID?
    
    @Parent(key: "playlist_id")
    var playlist: Playlist
    
    @Parent(key: "user_id")
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, playlist: Playlist, user: User) throws {
        self.id = id
        self.$playlist.id = try playlist.requireID()
        self.$user.id = try user.requireID()
    }
}
