//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/1.
//

import Vapor
import Fluent

final class Comment: Model, Content {
    static var schema: String = "comments"
    
    @ID
    var id: UUID?
    
    @Parent(key: "song_id")
    var songId: Song
    
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
    
    @Field(key: "reply_count")
    var replyCount: Int
    
    @Field(key: "like_count")
    var likeCount: Int
    
    @Children(for: \.$comment)
    var replies: [CommentReply]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    // enable soft delete
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
}


