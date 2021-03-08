//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/1.
//

import Vapor
import Fluent

final class Comment: Model, PublicTransformable {
    static var schema: String = "comments"
    
    @ID
    var id: UUID?
    
    @Parent(key: "song_id")
    var song: Song
    
    @Field(key: "content")
    var content: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "reply_count")
    var replyCount: Int
    
    @Field(key: "like_count")
    var likeCount: Int
    
    @Children(for: \.$parentComment)
    var replies: [CommentReply]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    // enable soft delete
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    struct Public: Content {
        var id: UUID?
        var content: String
        var user: User.Public
        var replyCount: Int
        var likeCount: Int
        var replies: [CommentReply.Public]
        
        init(_ comment: Comment) {
            self.id = comment.id
            self.content = comment.content
            self.user = comment.user.convertToPublic()
            self.replyCount = comment.replyCount
            self.likeCount = comment.likeCount
            self.replies = comment.replies.convertToPublic()
        }
    }
    
    func convertToPublic() -> Public {
        Public(self)
    }
    
}


