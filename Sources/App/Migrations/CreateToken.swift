//
//  CreateTokens.swift
//  App
//
//  Created by chenhaoyu.1999 on 2021/1/31.
//

import Fluent

struct CreateToken: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema("tokens")
      .id()
      .field("value", .string, .required)
      .field("userID", .uuid, .required, .references("users", "id", onDelete: .cascade))
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema("tokens").delete()
  }
}
