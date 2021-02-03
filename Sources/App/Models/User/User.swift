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
    var hashedPassword: String
    
    @Field(key: "email")
    var email: String
    
    @Group(key: "profile")
    var profile: UserProfile
    
    // Query Property
    @Children(for: \.$author)
    var createdSongs: [Song]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Siblings(through: FollowRelation.self
              , from: \.$toUser, to: \.$fromUser)
    var followers: [User]
    
    @Siblings(through: FollowRelation.self, from: \.$fromUser, to: \.$toUser)
    var followees: [User]
    
    init() { }
    
    init(id: UUID? = nil, username: String, hashedPassword: String, email: String, avatar: String? = nil) {
        self.username = username
        self.hashedPassword = hashedPassword
        self.email = email
        let profile = UserProfile()
        profile.avatarUrl = ""
        profile.backgroundAvatarUrl = ""
        profile.schema = ""
        profile.nickname = username
        self.profile = profile
    }
    
    final class Public: Content {
        var id: UUID?
        var username: String
        var avatar: String
        
        init(id: UUID?, username: String, avatar: String) {
            self.id = id
            self.username = username
            self.avatar = avatar
        }
    }
}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, username: username, avatar: "")
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
    static let passwordHashKey = \User.$hashedPassword
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.hashedPassword)
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

struct UserMiddleware: ModelMiddleware {
    func create(model: User, on db: Database, next: AnyModelResponder) -> EventLoopFuture<Void> {
//        model.schema = "mcm://user/" + model.username
        return next.create(model, on: db)
    }
}
