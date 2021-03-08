//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/3/7.
//

import Vapor
import Fluent

struct CommentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let commentsRoute = routes.grouped("api", "comments")
        commentsRoute.get(":songid", use: getCommentsHandler(_:))
    }
    
    func getCommentsHandler(_ req: Request) throws -> EventLoopFuture<[Comment.Public]>{
        Song.find(req.parameters.get("songid"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { song in
                song.$comments.query(on: req.db).with(\.$user).with(\.$replies).all().convertToPublic()
            }
    }
}
