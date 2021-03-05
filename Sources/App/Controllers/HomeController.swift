//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/3/5.
//

import Vapor

struct HomeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let homeGroup = routes.grouped("api", "home")
        homeGroup.get("recommend", use: recommendHandler(_:))
    }
    
    func recommendHandler(_ req: Request) throws -> EventLoopFuture<HomeRecommend> {
        let songs = Song.query(with: req).all().convertToPublic()
        let playlists = Playlist.query(with: req).all().convertToPublic()
        return songs.and(playlists).map { (songs, playlists) -> (HomeRecommend) in
            HomeRecommend(playlists: playlists, songs: songs)
        }
    }
}
