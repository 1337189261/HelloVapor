//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/29.
//

import Fluent
import Vapor

struct SongController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let songsRoute = routes.grouped("api","songs")
        songsRoute.get("all", use: getAllHandler(_:))
        songsRoute.get(":songid", use: getHandler(_:))
        songsRoute.get(":songid", "author", use: getAuthorHandler(_:))
        songsRoute.get("search", use: searchHandler(_:))
        songsRoute.get("first", use: getFirstHandler(_:))
        songsRoute.get("sorted", use: sortedHandler(_:))
        
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = songsRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.post(use: createHandler)
        tokenAuthGroup.delete(":songid", use: deleteHandler)
        tokenAuthGroup.put(":songid", use: updateHandler)
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Song> {
        let songData = try req.content.decode(CreateSongData.self)
        let song = Song(authorId: songData.authorId, name: songData.name, duration: songData.duration)
        return song.save(on: req.db).map { song }
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<Song> {
        Song.find(req.parameters.get("songid"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getAuthorHandler(_ req: Request) throws -> EventLoopFuture<User> {
        Song.find(req.parameters.get("songid"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (song) in
                song.$author.get(on: req.db)
            }
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Song]> {
        Song.query(on: req.db).all()
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Song> {
        let updateSongData = try req.content.decode(CreateSongData.self)
        return Song.find(req.parameters.get("songid"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (song) in
                song.name = updateSongData.name
                song.$author.id = updateSongData.authorId
                song.duration = updateSongData.duration
                return song.save(on: req.db).map { song }
            }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Song.find(req.parameters.get("songid"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (user) in
                user.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Song]> {
            guard let searchTerm = req.query[String.self, at: "term"] else {
                throw Abort(.badRequest)
            }
            
            return Song.query(on: req.db).filter(\.$name == searchTerm)
                .all()
    }
    
    func getFirstHandler(_ req: Request) throws -> EventLoopFuture<Song> {
        Song.query(on: req.db).first().unwrap(or: Abort(.notFound))
    }
    func sortedHandler(_ req: Request) throws -> EventLoopFuture<[Song]> {
        Song.query(on: req.db)
            .sort(\.$name, .ascending)
            .all()
    }
    
}


struct CreateSongData: Content {
    let authorId: UUID
    let name: String
    let duration: String
}

