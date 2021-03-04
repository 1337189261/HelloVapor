//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/29.
//

import Fluent
import Vapor
import ID3TagEditor

final class Song: Model, PublicTransformable {
    
    static let schema = "songs"
    
    @ID
    var id: UUID?
    
    @Parent(key: "artist_id")
    var artist: Artist
    
    @Field(key: "filename")
    var filename: String
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "duration")
    var duration: Int
    
    @Field(key: "lyric_url")
    var lyricUrl: String?
    
    @Siblings(through: PlaylistSongRelation.self, from: \.$song, to: \.$playlist)
    var playlists: [Playlist]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    static let id3TagEditor = ID3TagEditor()
    
    init(id: UUID? = nil, authorId: User.IDValue, filename: String, name: String, duration: Int, lyricUrl: String? = nil) {
        self.id = id
        self.$artist.id = authorId
        self.filename = filename
        self.name = name
        self.lyricUrl = lyricUrl
        self.duration = duration
    }
    
    struct Public: Content {
        var id: UUID?
        var artist: Artist?
        var songUrl: String
        var name: String
        var duration: Int
        var lyricUrl: String?
        
        init(_ song: Song) {
            self.id = song.id
            if let artist = song.$artist.value {
                self.artist = artist
            }
            self.songUrl = song.filename.songUrl
            self.name = song.name
            self.duration = song.duration
            self.lyricUrl = song.lyricUrl
        }
    }
    
    func convertToPublic() -> Public {
        Public(self)
    }
}
