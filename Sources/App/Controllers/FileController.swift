//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/1.
//

import Vapor
import Fluent
import SwiftUI

struct FileController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let imageGroup = routes.grouped("api", "images")
        imageGroup.get(":imageName", use: getImageHandler(_:))
        routes.get("api", "songs", "file", ":songName", use: getSongHandler(_:))
        routes.get("api", "lyric", ":lyricName", use: getLyricHandler(_:))
    }
    
    func getImageHandler(_ req: Request) throws -> Response {
        guard let imageName = req.parameters.get("imageName") else {
            return Response(status: .notFound);
        }
        let filePath = workingDirectory + "Resources/Images/" + imageName
        req.logger.info(Logger.Message(stringLiteral: filePath))
        let fileURL = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: fileURL)
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "image/jpeg")
        return Response(headers: headers, body: .init(data: data))
    }
    
    func getSongHandler(_ req: Request) throws -> Response {
        guard let songName = req.parameters.get("songName") else {
            return Response(status: .notFound);
        }
        let filePath = workingDirectory + "Resources/Songs/" + songName
        req.logger.info(Logger.Message(stringLiteral: filePath))
        let fileURL = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: fileURL)
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "audio/mpeg")
        return Response(headers: headers, body: .init(data: data))
    }
    
    func getLyricHandler(_ req: Request) throws -> Response {
        guard let lyricName = req.parameters.get("lyricName") else {
            return Response(status: .notFound);
        }
        let filePath = workingDirectory + "Resources/Lyrics/" + lyricName
        req.logger.info(Logger.Message(stringLiteral: filePath))
        let fileURL = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: fileURL)
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/plain")
        return Response(headers: headers, body: .init(data: data))
    }
}

//func audioPath(for fileName: String) -> String {
//    workingDirectory + "Resources/Songs/" + (fileName.hasSuffix("mp3") ? fileName : (fileName + ".mp3"))
//}
