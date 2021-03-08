//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/1.
//

import Vapor
import Fluent

final class CommentReply: Model, PublicTransformable {
    
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
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    // enable soft delete
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    struct Public: Content {
        var id: UUID?
        var parentCommentId: UUID
        var content: String
        var user: User.Public
        var likeCount: Int
        
        init(_ commentReply: CommentReply) {
            self.id = commentReply.id
            self.parentCommentId = commentReply.$parentComment.id
            self.content = commentReply.content
            self.user = commentReply.user.convertToPublic()
            self.likeCount = commentReply.likeCount
        }
    }
    
    func convertToPublic() -> Public {
        Public(self)
    }
}
