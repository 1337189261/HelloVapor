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
    let neteaseUsers = commentResponse.hotComments.map{ $0.user } + commentResponse.hotComments.flatMap {$0.beReplied}.map{$0.user}
    let users = Set(neteaseUsers).map{try! User(username: $0.nickname, hashedPassword: Bcrypt.hash("password"), email: "\($0.nickname)@cloudmusic.com", avatar: $0.avatarUrl)}
    users.forEach {try! $0.save(on: db).wait()}
    
    for neteaseComment in commentResponse.hotComments {
        if neteaseComment.beReplied.isEmpty {
            let comment = Comment()
            comment.$song.id = chengdu.id!
            comment.content = neteaseComment.content
            let user = try! User.query(on: db).filter(\.$username == neteaseComment.user.nickname).first().wait()
            comment.$user.id = user!.id!
            try! comment.save(on: db).wait()
        }
    }
    
}
struct NeteaseUser: Codable, Equatable, Hashable {
    let userId: Int
    let nickname: String
    let avatarUrl: String
    static func == (lhs: NeteaseUser, rhs: NeteaseUser) -> Bool {
        lhs.userId == rhs.userId
    }
    
}
struct NeteaseComment: Codable {
    let user: NeteaseUser
    let content: String
    let commentId: Int
    let beReplied: [NeteaseCommentBeReplied]
}

struct NeteaseCommentBeReplied: Codable {
    let user: NeteaseUser
    let content: String
    let beRepliedCommentId: Int
}

struct NeteaseCommentResponse: Codable {
    let hotComments: [NeteaseComment]
}
