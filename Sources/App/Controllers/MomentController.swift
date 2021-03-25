//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/3/24.
//

import Vapor
import Fluent

struct MomentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let momentsRoute = routes.grouped("api", "moments")
        momentsRoute.get("all", use: getAllMoments(_:))
        momentsRoute.post("create", use: createHandler(_:))
    }
    
    func getAllMoments(_ req: Request) throws -> EventLoopFuture<[Moment.Public]> {
        Moment.query(with: req).all().convertToPublic()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        let createMomentData = try req.content.decode(CreateMomentData.self)
        var imageUrls = [String]()
        for data in createMomentData.images {
            let name = UUID().uuidString + ".jpeg"
            let path = workingDirectory + "Resources/Images/" + name
            FileManager().createFile(atPath: path, contents: data, attributes: nil)
            imageUrls.append(name.imgUrl)
        }
        let moment = Moment(content: createMomentData.content, userId: user.id!, images: imageUrls, location: createMomentData.location)
        return moment.save(on: req.db).transform(to: .noContent)
    }
}

struct CreateMomentData: Codable {
    let content: String
    let image1: Data?
    let image2: Data?
    let image3: Data?
    let image4: Data?
    let image5: Data?
    let image6: Data?
    let image7: Data?
    let image8: Data?
    let image9: Data?
    let location: String?
    var images: [Data] {
        [image1, image2, image3, image4, image5, image6,image7, image8, image9].compactMap {$0}
    }
}
