//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/1.
//

import Vapor
import Fluent

final class CommentReply: Model, Content {
    
    static var schema: String = "comment_replies"
    
    @ID
    var id: UUID?
    
    @Parent(key: "comment_id")
    var comment: Comment
    
    @Field(key: "content")
    var content: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "username")
    var userName: String
    
    @Field(key: "avatar_url")
    var avatarURL: String
    
    @Field(key: "user_schema")
    var userSchema: String
    
    @Field(key: "like_count")
    var likeCount: Int
    
    @OptionalParent(key: "reply_user_id")
    var replyUser: User?
    
    @Field(key: "reply_user_name")
    var replyUserName: String?
    
    @Field(key: "reply_user_schema")
    var replyUserSchema: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    // enable soft delete
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
}
