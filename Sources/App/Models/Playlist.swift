//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/30.
//

import Vapor
import Fluent

final class Playlist: PublicTransformable {
    static let schema: String = "playlists"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String?
    
    @Field(key: "avatar_url")
    var avatarUrl: String
    
    @Parent(key: "creator_id")
    var creator: User
    
    @Siblings(through: PlaylistSongRelation.self, from: \.$playlist, to: \.$song)
    var songs: [Song]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    var followerCount: Int?
    
    @Siblings(through: PlaylistFollowRelation.self, from: \.$playlist, to: \.$user)
    var followers: [User]
    
    init() {}
    
    init(id: UUID? = nil, creatorId: User.IDValue, name: String, avatarUrl: String) {
        self.id = id
        self.$creator.id = creatorId
        self.name = name
        self.avatarUrl = avatarUrl
    }
    
    func fetchFollowerCount(on db: Database) throws {
        followerCount = try Playlist
            .find(self.id, on: db)
            .unwrap(or: Abort(.notFound))
            .flatMap({ (playlist) in
                playlist.$followers.query(on: db).count()
            }).wait()
    }
    
    static func query(with req: Request)-> QueryBuilder<Playlist> {
        Playlist.query(on: req.db).with(\.$songs){ song in
            song.with(\.$artist)
        }
        .with(\.$creator)
    }
    
    struct Public: PublicTypeProtocol {
        var id: UUID?
        var name: String?
        var avatarUrl: String?
        var songs: [Song.Public]?
        var followerCount: Int?
        var creator: User.Public?
        
        init(_ privateValue: Playlist) {
            let playlist = privateValue
            self.id = playlist.id
            self.name = playlist.name
            self.avatarUrl = playlist.avatarUrl
            self.songs = playlist.songs.convertToPublic()
            self.followerCount = playlist.followerCount
            self.creator = playlist.creator.convertToPublic()
        }
    }
    
    func convertToPublic() -> Public {
        Public(self)
    }
}
