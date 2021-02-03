//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/2.
//

import XCTVapor
import App

extension Application {
    static func testable() throws -> Application {
        let app = Application(.testing)
        try configure(app)
        
        try app.autoRevert().wait()
        try app.autoMigrate().wait()
        
        return app
    }
}
