//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/28.
//

import Fluent
import Vapor

final class User: Model, PublicTransformable {
    
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
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Siblings(through: UserFollowRelation.self
              , from: \.$toUser, to: \.$fromUser)
    var followers: [User]
    
    @Siblings(through: UserFollowRelation.self, from: \.$fromUser, to: \.$toUser)
    var followees: [User]
    
    @Siblings(through: PlaylistFollowRelation.self, from: \.$user, to: \.$playlist)
    var followedPlaylist: [Playlist]
    
    @OptionalField(key: "netease_id")
    var neteaseID: Int?
    
    init() { }
    
    init(id: UUID? = nil, username: String, hashedPassword: String, email: String, avatar: String? = nil, neteaseID: Int? = nil) {
        self.username = username
        self.hashedPassword = hashedPassword
        self.email = email
        let profile = UserProfile()
        profile.avatarUrl = avatar ?? ""
        profile.backgroundAvatarUrl = ""
        profile.schema = ""
        profile.nickname = username
        self.profile = profile
        self.neteaseID = neteaseID
    }
    
    final class Public: Content {
        var id: UUID?
        var username: String?
        var avatarUrl: String?
        var backgroundAvatarUrl:String?
        var schema: String?
        var nickname: String?
        var followCount: Int?
        var followerCount: Int?
        
        init(_ user: User) {
            self.id = user.id
            self.avatarUrl = user.profile.avatarUrl
            self.backgroundAvatarUrl = user.profile.backgroundAvatarUrl
            self.schema = user.profile.schema
            self.nickname = user.profile.nickname
            self.followCount = user.profile.followCount
            self.followerCount = user.profile.followerCount
        }
    }
}

extension User {
    func convertToPublic() -> User.Public {
        Public(self)
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
        return next.create(model, on: db)
    }
}
