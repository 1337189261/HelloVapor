//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/28.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
      database.schema("users")
        .id()
        .field("username", .string, .required)
        .field("password", .string, .required)
        .field("email", .string, .required)
        .field("avatar", .string)
        .unique(on: "username", "email")
        .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
      database.schema("users").delete()
    }
  }

