//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/3/8.
//

@testable import App
import XCTVapor
import Fluent
import Vapor

let commentUrl = "/api/comments/"

final class CommentTests: XCTestCase {
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testRetriveComments() throws {
//        try app.test(.GET, commentUrl + chengduId.uuidString, afterResponse: { response in
//            print(response.content)
//            let comments = try response.content.decode([Comment.Public].self)
//            XCTAssertTrue(comments.count > 0, "获取歌曲评论数量为0")
//        })
    }
}


