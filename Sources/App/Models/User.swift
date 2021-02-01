//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/28.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "avatar")
    var avatar: String?
    
    @Children(for: \.$author)
    var songs: [Song]
    
    init() {}
    
    init(id: UUID? = nil, username: String, password: String, email: String, avatar: String? = nil) {
        self.username = username
        self.password = password
        self.email = email
        self.avatar = avatar
    }
    
    final class Public: Content {
        var id: UUID?
        var username: String
        var avatar: String?
        
        init(id: UUID?, username: String, avatar: String?) {
            self.id = id
            self.username = username
            self.avatar = avatar
        }
    }
}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, username: username, avatar: avatar)
    }
}

extension EventLoopFuture where Value: User {
    func convertToPublic() -> EventLoopFuture<User.Public> {
        return self.map { user in
            return user.convertToPublic()
        }
    }
}

extension EventLoopFuture where Value: Collection, Value.Element == User {
    func convertToPublic() -> EventLoopFuture<[User.Public]> {
        map { $0.map { $0.convertToPublic() }}
    }
}

extension Collection where Element: User {
    func convertToPublic() -> [User.Public] {
        return self.map { $0.convertToPublic() }
    }
}

extension EventLoopFuture where Value == Array<User> {
    func convertToPublic() -> EventLoopFuture<[User.Public]> {
        return self.map { $0.convertToPublic() }
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

extension User: ModelSessionAuthenticatable {}
extension User: ModelCredentialsAuthenticatable {}

extension User: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(6...))
        validations.add("email", as: String.self, is: .email)
    }
}
