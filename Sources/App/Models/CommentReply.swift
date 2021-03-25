//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/1.
//

import Vapor
import Fluent

final class CommentReply: PublicTransformable {
    typealias PublicType = Public
    
    static var schema: String = "comment_replies"
    
    @ID
    var id: UUID?
    
    @Parent(key: "comment_id")
    var parentComment: Comment
    
    @Field(key: "content")
    var content: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "like_count")
    var likeCount: Int
    
    @Timestamp(key: "created_at", on: .none)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    // enable soft delete
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() {
        createdAt = Date()
    }
    
    struct Public: PublicTypeProtocol {
        var id: UUID?
        var parentCommentId: UUID
        var content: String
        var user: User.Public
        var likeCount: Int
        var time: Int
        
        init(_ privateValue: CommentReply) {
            let commentReply = privateValue
            self.id = commentReply.id
            self.parentCommentId = commentReply.$parentComment.id
            self.content = commentReply.content
            self.user = commentReply.user.convertToPublic()
            self.likeCount = commentReply.likeCount
            self.time = Int(commentReply.createdAt!.timeIntervalSince1970 * 1000)
        }
        
    }
}
