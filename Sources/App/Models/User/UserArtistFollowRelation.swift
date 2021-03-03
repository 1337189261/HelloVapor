//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/25.
//

import Fluent
import Vapor

final class UserArtistFollowRelation: Model {
    
    static var schema: String = "user_artist_follow_relation"
    
    @ID
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "artist_id")
    var artist: Artist
    
    init() {}
    
    init(id: UUID? = nil, user: User, artist: Artist) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.$artist.id = try artist.requireID()
    }
    
}
