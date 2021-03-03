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
  case wrongUsernameOrPassword
}

extension UserError: AbortError {
  var description: String {
    reason
  }

  var status: HTTPResponseStatus {
    switch self {
    case .usernameTaken: return .conflict
    case .wrongUsernameOrPassword: return .unauthorized
    }
  }

  var reason: String {
    switch self {
    case .usernameTaken: return "该用户名已被注册"
    case .wrongUsernameOrPassword: return "用户名或者密码错误"
    }
  }
}
