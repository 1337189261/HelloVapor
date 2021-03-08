//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/3/7.
//

import Vapor
import Fluent

func mockComment(on db: Database) {
    let path = "/Users/chy/Documents/Vapor/HelloVapor/Sources/App/Mock/CommentJson.json"
    let data = try! Data(contentsOf: URL(fileURLWithPath: path))
    let commentResponse = try! JSONDecoder().decode(NeteaseCommentResponse.self, from: data)
    let allComments = Set(commentResponse.hotComments + commentResponse.comments)
    let neteaseUsers = allComments.map{ $0.user } + allComments.flatMap {$0.beReplied}.map{$0.user}
    let users = Set(neteaseUsers).map{try! User(username: $0.nickname, hashedPassword: Bcrypt.hash("password"), email: "\(UUID().uuidString)@1.com", avatar: $0.avatarUrl, neteaseID: $0.userId)}
    
    users.forEach {try! $0.save(on: db).wait()}
    
    for neteaseComment in allComments where neteaseComment.beReplied.isEmpty {
        let comment = Comment()
        comment.$song.id = chengdu.id!
        comment.content = neteaseComment.content
        let user = try! User.query(on: db).filter(\.$neteaseID == neteaseComment.user.userId).first().wait()
        comment.$user.id = user!.id!
        try! comment.save(on: db).wait()
    }
    print(commentResponse.hotComments.filter {!$0.beReplied.isEmpty}.count)
    for neteaseComment in allComments where !neteaseComment.beReplied.isEmpty {
        let commentReply = CommentReply()
        guard let parentComment = try! Comment.query(on: db).filter(\.$content == neteaseComment.beReplied[0].content).first().wait() else {
            print("cannot find parent")
            continue
        }
        print("find parent")
        commentReply.content = neteaseComment.content
        commentReply.$parentComment.id = parentComment.id!
        let user = try! User.query(on: db).filter(\.$neteaseID == neteaseComment.user.userId).first().wait()
        commentReply.$user.id = user!.id!
        try! commentReply.save(on: db).wait()
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
