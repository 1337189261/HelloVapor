//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/29.
//

import Fluent
import Vapor

final class Song: Model, Content {
    
    static let schema = "songs"
    
    @ID
    var id: UUID?
    
    @Parent(key: "artist_id")
    var artist: Artist
    
    @Field(key: "song_url")
    var songUrl: String
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "lyric_url")
    var lyricUrl: String?
    
    @Siblings(through: PlaylistSongRelation.self, from: \.$song, to: \.$playlist)
    var playlists: [Playlist]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, authorId: User.IDValue, songUrl: String, name: String, lyricUrl: String? = nil) {
        self.id = id
        self.$artist.id = authorId
        self.songUrl = songUrl
        self.name = name
        self.lyricUrl = lyricUrl
    }
}
