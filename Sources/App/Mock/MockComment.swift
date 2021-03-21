//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/3/7.
//

import Vapor
import Fluent

func mockComment(on db: Database) {
    let path = workingDirectory +  "Sources/App/Mock/CommentJson.json"
    db.logger.info(Logger.Message(stringLiteral: path))
    let data = try! Data(contentsOf: URL(fileURLWithPath: path))
    var commentResponse: NeteaseCommentResponse!
    measure("JSON Decode") {
        commentResponse = try! JSONDecoder().decode(NeteaseCommentResponse.self, from: data)
    }
    var allComments: Set<NeteaseComment> = []
    var neteaseUsers: [NeteaseUser] = []
    var users: [User] = []
    measure("Get Comments") {
        allComments = Set(commentResponse.hotComments + commentResponse.comments)
        neteaseUsers = allComments.map{ $0.user } + allComments.flatMap {$0.beReplied}.map{$0.user}
    }
    let sameHashedPassword = try! Bcrypt.hash("password")
    measure("Create User") {
        users = Set(neteaseUsers).map{(user: NeteaseUser) -> User in
            User(username: user.nickname, hashedPassword: sameHashedPassword, email: "1@1.com", avatar: user.avatarUrl, neteaseID: user.userId)
        }.compactMap {$0}
    }

    measure("User Save") {
        users.forEach {try? $0.save(on: db).wait()}

    }
    measure("Comments Save") {
        for neteaseComment in allComments where neteaseComment.beReplied.isEmpty {
            let comment = Comment()
            comment.$song.id = chengdu.id!
            comment.neteaseCommentId = neteaseComment.commentId
            comment.createdAt = Date(timeIntervalSince1970: Double(neteaseComment.time) / 1000)
            comment.content = neteaseComment.content
            let user = try! User.query(on: db).filter(\.$neteaseID == neteaseComment.user.userId).first().wait()
            comment.$user.id = user!.id!
            try! comment.save(on: db).wait()
        }
    }
    measure("Replies Save") {
        for neteaseComment in allComments where !neteaseComment.beReplied.isEmpty {
            let commentReply = CommentReply()
            commentReply.createdAt = Date(timeIntervalSince1970: Double(neteaseComment.time) / 1000)
            guard let parentComment = try! Comment.query(on: db).filter(\.$neteaseCommentId == neteaseComment.beReplied[0].beRepliedCommentId).first().wait() else {
                continue
            }
            commentReply.content = neteaseComment.content
            commentReply.$parentComment.id = parentComment.id!
            let user = try! User.query(on: db).filter(\.$neteaseID == neteaseComment.user.userId).first().wait()
            commentReply.$user.id = user!.id!
            try! commentReply.save(on: db).wait()
        }
    }
    
}
struct NeteaseUser: Codable, Equatable, Hashable {
    let userId: Int
    let nickname: String
    let avatarUrl: String
    static func == (lhs: Self, rhs:Self) -> Bool {
        lhs.userId == rhs.userId
    }
    
}
struct NeteaseComment: Codable, Equatable, Hashable {
    let user: NeteaseUser
    let content: String
    let commentId: Int
    let time: Int
    let beReplied: [NeteaseCommentBeReplied]
    static func == (lhs: NeteaseComment, rhs: NeteaseComment) -> Bool {
        lhs.commentId == rhs.commentId
    }
}

struct NeteaseCommentBeReplied: Codable, Equatable, Hashable {
    let user: NeteaseUser
    let content: String
    let beRepliedCommentId: Int
    static func == (lhs: NeteaseCommentBeReplied, rhs: NeteaseCommentBeReplied) -> Bool {
        lhs.beRepliedCommentId == rhs.beRepliedCommentId
    }
}

struct NeteaseCommentResponse: Codable {
    let hotComments: [NeteaseComment]
    let comments: [NeteaseComment]
}

func measure(_ message: String = "", _ closure: @escaping () -> Void) {
    if isLinux { closure(); return; }
    let startTime = Date()
    closure()
    let endTime = Date()
    print(message + " TimeInterval \(endTime.timeIntervalSince(startTime))")
}
