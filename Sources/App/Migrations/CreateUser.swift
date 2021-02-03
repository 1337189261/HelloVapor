//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/28.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
        .id()
        .field("username", .string, .required)
        .field("password", .string, .required)
        .field("email", .string, .required)
        .field("profile_avatar_url", .string, .required)
        .field("profile_schema", .string, .required)
        .field("profile_background_avatar_url", .string, .required)
        .field("profile_nickname", .string, .required)
        .field("profile_follow_count", .int, .sql(.default(0)))
        .field("profile_follower_count", .int, .sql(.default(0)))
        .field("created_at", .date)
        .unique(on: "username", "email")
        .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
      database.schema(User.schema).delete()
    }
  }

