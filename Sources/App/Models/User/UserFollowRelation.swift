//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/2.
//

import Fluent
import Vapor

final class UserFollowRelation: Model {
    
    static var schema: String = "follow_relation"
    
    @ID
    var id: UUID?
    
    @Parent(key: "from_user_id")
    var fromUser: User
    
    @Parent(key: "to_user_id")
    var toUser: User
    
    init() {}
    
    init(id: UUID? = nil, fromUser: User, toUser: User) throws {
        self.id = id
        self.$fromUser.id = try fromUser.requireID()
        self.$toUser.id = try toUser.requireID()
    }
    
}
