//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/30.
//

import Vapor
import Fluent

struct PlaylistController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let playlistsRoute = routes.grouped("api", "playlist")
        playlistsRoute.get("top", use: getTopHandler(_:))
        playlistsRoute.get("sample", use: getSampleHandler(_:))
    }
    
    func getTopHandler(_ req: Request) throws -> EventLoopFuture<[Playlist.Public]> {
        Playlist.query(on: req.db).with(\.$songs){ song in
            song.with(\.$artist)
        }.with(\.$creator).range(..<10).all().convertToPublic()
    }
    
    func getSampleHandler(_ req: Request) throws -> EventLoopFuture<Playlist.Public> {
        Playlist.query(on: req.db).with(\.$songs){ song in
            song.with(\.$artist)
        }
        .with(\.$creator)
        .first()
        .unwrap(or: Abort(.notFound))
        .convertToPublic()
    }
}
