//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/2.
//

import Vapor
import Fluent

final class UserProfile: Fields {
    @Field(key: "avatar_url")
    var avatarUrl: String
    
    @Field(key: "background_avatar_url")
    var backgroundAvatarUrl: String
    
    @Field(key: "schema")
    var schema: String
    
    @Field(key: "nickname")
    var nickname: String
    
    @Field(key: "follow_count")
    var followCount: Int
    
    @Field(key: "follower_count")
    var followerCount: Int
}
