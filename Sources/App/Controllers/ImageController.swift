//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/1.
//

import Vapor
import Fluent

struct ImageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let imageGroup = routes.grouped("api", "images")
        imageGroup.get(":imageName", use: getImageHandler(_:))
    }
    
    func getImageHandler(_ req: Request) throws -> Response {
        guard let imageName = req.parameters.get("imageName") else {
            return Response(status: .notFound);
        }
        let filePath = workingDirectory + "Images/" + imageName
        let fileURL = URL(fileURLWithPath: filePath)
        
        let data = try Data(contentsOf: fileURL)
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "image/jpeg")
        return Response( headers: headers, body: .init(data: data))
    }
}
