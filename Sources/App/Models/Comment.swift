//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/1.
//

import Vapor
import Fluent

final class Comment: PublicTransformable {
    typealias PublicType = Public
    
    static var schema: String = "comments"
    
    @ID
    var id: UUID?
    
    @Parent(key: "song_id")
    var song: Song
    
    @Field(key: "content")
    var content: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "like_count")
    var likeCount: Int
    
    @Children(for: \.$parentComment)
    var replies: [CommentReply]
    
    @Timestamp(key: "created_at", on: .none)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    // enable soft delete
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    @Field(key: "netease_comment_id")
    var neteaseCommentId: Int
    
    init() {
        self.createdAt = Date()
    }
    
    struct Public: PublicTypeProtocol {
        var id: UUID?
        var content: String
        var user: User.Public
        var likeCount: Int
        var replies: [CommentReply.Public]
        var time: Int
        
        init(_ privateValue: Comment) {
            let comment = privateValue
            self.id = comment.id
            self.content = comment.content
            self.user = comment.user.convertToPublic()
            self.likeCount = comment.likeCount
            self.replies = comment.replies.convertToPublic()
            self.time = Int(comment.createdAt!.timeIntervalSince1970 * 1000)
        }
    }
    
}
