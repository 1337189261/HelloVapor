//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/25.
//
import Vapor
import Fluent
final class Artist: Model, Content {
    static let schema = "artists"
    
    @ID
    var id: UUID?
    
    @Field(key: "nickname")
    var nickname: String
    
    @Field(key: "avatar_url")
    var avatarUrl: String
    
    @Field(key: "schema")
    var schema: String
    
    @Children(for: \.$artist)
    var createdSongs: [Song]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Siblings(through: UserArtistFollowRelation.self
              , from: \.$artist, to: \.$user)
    var followers: [User]
    
    init() { }
    
    init(id: UUID? = nil, nickname: String, avatarUrl: String? = nil) {
        self.nickname = nickname
        self.schema = ""
        self.avatarUrl = avatarUrl ?? ""
    }
}
