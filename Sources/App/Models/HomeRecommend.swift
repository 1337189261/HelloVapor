//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/3/5.
//

import Vapor

struct HomeRecommend: Content {
    var playlists: [Playlist.Public]
    var songs: [Song.Public]
}
