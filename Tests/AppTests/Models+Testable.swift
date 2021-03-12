//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/2.
//

@testable import App
import Fluent
import Vapor

extension User {
    
    static var realPasswordDict = [String: String]()
    
    var realPassword: String {
        get {
            Self.realPasswordDict[self.username]!
        }
        set {
            Self.realPasswordDict[self.username] = newValue
        }
    }
    
    static func create(name: String, username: String, password: String, email:String, on database: Database) throws -> User {
        let hashedPassword = try Bcrypt.hash(password)
        let user = User(username: username, hashedPassword: hashedPassword, email: email, avatar: nil)
        try user.save(on: database).wait()
        user.realPassword = password
        return user
    }
    
    static func createOne() throws -> User {
        try create(name: "xsjtest", username: "xsj", password: "xsjpassword", email: "xsj@xsj.com", on: app.db)
    }
    
    static func createAnother() throws -> User {
        try create(name: "chytest", username: "chy", password: "chypassword", email: "chy@chy.com", on: app.db)
    }
    
    func login(completion: (Token) throws -> Void) throws {
        try app.test(.POST, usersURI + "login", beforeRequest: { req in
            req.headers.basicAuthorization = BasicAuthorization(username: self.username, password: realPassword)
        }) { (response) in
            let token = try response.content.decode(Token.self)
            try completion(token)
        }
    }
}
