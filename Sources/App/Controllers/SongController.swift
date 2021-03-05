//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/29.
//

import Vapor
import Fluent

struct SongController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let songsRoute = routes.grouped("api","songs")
        songsRoute.get("all", use: getAllHandler(_:))
        songsRoute.get(":songid", use: getHandler(_:))
        songsRoute.get(":songid", "author", use: getAuthorHandler(_:))
        songsRoute.get("search", use: searchHandler(_:))
        
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = songsRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.delete(":songid", use: deleteHandler)
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<Song.Public> {
        Song.find(req.parameters.get("songid"), on: req.db)
            .map({ (song) -> Song? in
                try? song?.$artist.load(on: req.db).wait()
                return song
            })
            .unwrap(or: Abort(.notFound))
            .convertToPublic()
    }
    
    func getAuthorHandler(_ req: Request) throws -> EventLoopFuture<Artist> {
        Song.find(req.parameters.get("songid"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (song) in
                song.$artist.get(on: req.db)
            }
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Song.Public]> {
        Song.query(on: req.db).with(\.$artist).all().convertToPublic()
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Song.find(req.parameters.get("songid"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (user) in
                user.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Song.Public]> {
            guard let searchTerm = req.query[String.self, at: "term"] else {
                throw Abort(.badRequest)
            }
            
            return Song.query(on: req.db).filter(\.$name == searchTerm)
                .all()
                .convertToPublic()
    }
    
}
