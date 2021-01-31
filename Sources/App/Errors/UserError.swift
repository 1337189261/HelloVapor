//
//  UserError.swift
//  UserError
//
//  Created by chenhaoyu.1999 on 2021/1/31.
//

import Fluent
import Vapor

enum UserError {
  case usernameTaken
}

extension UserError: AbortError {
  var description: String {
    reason
  }

  var status: HTTPResponseStatus {
    switch self {
    case .usernameTaken: return .conflict
    }
  }

  var reason: String {
    switch self {
    case .usernameTaken: return "Username already taken"
    }
  }
}
