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
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = commentsRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.post(use: createComment(_:))
    }
    
    func getCommentsHandler(_ req: Request) throws -> EventLoopFuture<[Comment.Public]> {
        Song.find(req.parameters.get("songid"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { song in
                song.$comments.query(on: req.db).with(\.$user).with(\.$replies) {
                    $0.with(\.$user)
                }.all().convertToPublic()
            }
    }
    
    func createComment(_ req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        guard let songID = try? req.query.get(UUID.self, at: "songId"), let content = try? req.query.get(String.self, at: "content") else {
            return req.eventLoop.future(.badRequest)
        }
        let user = try req.auth.require(User.self)
        if let commentID = try? req.query.get(UUID.self, at: "commentId") {
            let commentReply = CommentReply()
            commentReply.$parentComment.id = commentID
            commentReply.$user.id = try user.requireID()
            commentReply.content = content
            return commentReply.save(on: req.db).transform(to: .ok)
        } else {
            let comment = Comment()
            comment.content = content
            comment.$song.id = songID
            comment.$user.id = try user.requireID()
            return comment.save(on: req.db).transform(to: .ok)
        }
    }
}
