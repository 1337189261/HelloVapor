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
    
    @Field(key: "lyric_name")
    var lyric_name: String?
    
    @Siblings(through: PlaylistSongRelation.self, from: \.$song, to: \.$playlist)
    var playlists: [Playlist]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    static let id3TagEditor = ID3TagEditor()
    
    init(id: UUID? = nil, authorId: User.IDValue, filename: String, name: String, duration: Int, lyricName: String? = nil) {
        self.id = id
        self.$artist.id = authorId
        self.filename = filename
        self.name = name
        self.lyric_name = lyricName
        self.duration = duration
    }
    
    static func query(with req: Request)-> QueryBuilder<Song> {
        Song.query(on: req.db).with(\.$artist)
    }
    
    struct Public: Content {
        var id: UUID?
        var artist: Artist?
        var songUrl: String
        var name: String
        var duration: Int
        var lyricName: String?
        var imgUrl: String
        
        init(_ song: Song) {
            self.id = song.id
            if let artist = song.$artist.value {
                self.artist = artist
            }
            self.songUrl = song.filename.songUrl
            self.name = song.name
            self.duration = song.duration
            self.lyricName = song.lyric_name
            let index = song.filename.firstIndex(of: ".")
            if let index = index {
                self.imgUrl = String(song.filename.prefix(upTo: index) + ".jpg").imgUrl
            } else {
                self.imgUrl = (song.filename + ".jpg").imgUrl
            }
        }
    }
    
    func convertToPublic() -> Public {
        Public(self)
    }
}
