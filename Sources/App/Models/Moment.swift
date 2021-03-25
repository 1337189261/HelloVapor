//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/3/22.
//

import Vapor
import Fluent

final class Moment: PublicTransformable, QueryableModel {
    static func query(with req: Request) -> QueryBuilder<Moment> {
        Moment.query(on: req.db).with(\.$user)
    }
    
    
    typealias PublicType = Public
    
    static var schema = "moments"
    
    @ID
    var id: UUID?
    
    @Field(key: "content")
    var content: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "like_count")
    var likeCount: Int
    
    @Field(key: "post_count")
    var postCount: Int
    
    @Field(key: "comment_count")
    var commentCount: Int
    
    @Field(key: "images")
    var images: [String]
    
    @Field(key: "location")
    var location: String?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() { }
    
    init(content: String, userId: UUID, images: [String] = [], location: String? = nil) {
        self.content = content
        self.$user.id = userId
        self.images = images
        self.location = location
    }
    
    struct Public: PublicTypeProtocol {
        let id: UUID?
        let content: String?
        let user: User.Public?
        let likeCount: Int?
        let postCount: Int?
        let commentCount: Int?
        let images: [String]?
        let location: String?
        let createAt: Double?
        
        init(_ privateValue: Moment) {
            let moment = privateValue
            self.id = moment.id
            self.content = moment.content
            self.user = moment.user.convertToPublic()
            self.likeCount = moment.likeCount
            self.postCount = moment.postCount
            self.commentCount = moment.commentCount
            self.images = moment.images
            self.location = moment.location
            self.createAt = privateValue.createdAt?.timeIntervalSince1970
        }
        
    }
}
