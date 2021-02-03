//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/2.
//

@testable import App
import XCTVapor

let usersURI = "/api/users/"
var app: Application!

final class UserTests: XCTestCase {
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testUserCanSignUp() throws {
        try defaultSignUp { (response) in
            XCTAssertNotNil(try? response.content.decode(Token.self))
        }
    }
    
    func testUserCannotSignUpTwice() throws {
        try defaultSignUp { (response) in
            XCTAssertNotNil(try? response.content.decode(Token.self))
        }
        
        try defaultSignUp { (response) in
            XCTAssertNil(try? response.content.decode(Token.self))
        }
    }
    
    func defaultSignUp(afterResponse: (XCTHTTPResponse) -> Void) throws {
        try app.test(.POST, usersURI + "signup", beforeRequest : { req in
            let createUserData = CreateUserData(username: "chy", password: "chypassword", email: "chy@chy.com", avatar: nil)
            try req.content.encode(createUserData)
        }, afterResponse: afterResponse)
    }
    
    func testUserCanBeRetrivedFromAPI() throws {
        let user = try User.createOne()
        try app.test(.GET, "\(usersURI)\(user.id!)", afterResponse: { (response) in
            let receivedUser = try response.content.decode(User.Public.self)
            XCTAssertEqual(receivedUser.id, user.id)
            XCTAssertEqual(receivedUser.username, receivedUser.username)
        })
    }
    
    func testUserCanFollow() throws {
        let user1 = try User.createOne()
        let user2 = try User.createAnother()
        try user1.login { (token) in
            try app.test(.GET, usersURI + "follow/" + String(user2.id!), beforeRequest: { request in
                request.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            }, afterResponse: { (response) in
                XCTAssert(response.status == .created)
                let updatedUser1 = try User.find(user1.id!, on: app.db).wait()!
                let updatedUser2 = try User.find(user2.id!, on: app.db).wait()!
                XCTAssertEqual(updatedUser1.profile.followCount, 1)
                XCTAssertEqual(updatedUser2.profile.followerCount, 1)
                try updatedUser1.$followees.load(on: app.db).wait()
                XCTAssertEqual(updatedUser1.followees[0].id, user2.id)
                try updatedUser2.$followers.load(on: app.db).wait()
                XCTAssertEqual(updatedUser2.followers[0].id, user1.id)
            })
        }
    }
    
    func testUserCanNotFollowFollowedUser() throws {
        let user1 = try User.createOne()
        let user2 = try User.createAnother()
        try user1.login { (token) in
            try app.test(.GET, usersURI + "follow/" + String(user2.id!), beforeRequest: { request in
                request.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            }, afterResponse: { (_) in
                try app.test(.GET, usersURI + "follow/" + String(user2.id!), beforeRequest: { request in
                    request.headers.bearerAuthorization = BearerAuthorization(token: token.value)
                }, afterResponse: { (response) in
                    XCTAssert(response.status == .badRequest)
                    let updatedUser1 = try User.find(user1.id!, on: app.db).wait()
                    let updatedUser2 = try User.find(user2.id!, on: app.db).wait()
                    XCTAssertEqual(updatedUser1?.profile.followCount, 1)
                    XCTAssertEqual(updatedUser2?.profile.followerCount, 1)
                })
            })
        }
    }
}
