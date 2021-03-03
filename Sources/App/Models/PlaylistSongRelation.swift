//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/22.
//

import Fluent
import Vapor

final class PlaylistSongRelation: Model {
    
    static var schema: String = "playlist_song_relation"
    
    @ID
    var id: UUID?
    
    @Parent(key: "playlist_id")
    var playlist: Playlist
    
    @Parent(key: "song_id")
    var song: Song
    
    init() {}
    
    init(id: UUID? = nil, playlist: Playlist, song: Song) throws {
        self.id = id
        self.$playlist.id = try playlist.requireID()
        self.$song.id = try song.requireID()
    }
}
