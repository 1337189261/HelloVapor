//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/1.
//

import Vapor

struct FileController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let imageGroup = routes.grouped("api", "images")
        imageGroup.get(":imageName", use: getImageHandler(_:))
        routes.get("api", "songs", "file", ":songName", use: getSongHandler(_:))
        routes.get("api", "lyric", ":lyricName", use: getLyricHandler(_:))
    }
    
    func getImageHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let imageName = req.parameters.get("imageName") ?? ""
        let filePath = workingDirectory + "Resources/Images/" + imageName
        req.logger.info(Logger.Message(stringLiteral: filePath))
        let response = req.fileio.streamFile(at: filePath)
        return req.eventLoop.makeSucceededFuture(response)
    }
    
    func getSongHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let songName = req.parameters.get("songName") ?? ""
        
        let filePath = workingDirectory + "Resources/Songs/" + songName
        req.logger.info(Logger.Message(stringLiteral: filePath))
        let response = req.fileio.streamFile(at: filePath)
        return req.eventLoop.makeSucceededFuture(response)
    }
    
    func getLyricHandler(_ req: Request) throws -> EventLoopFuture<String> {
        guard let lyricName = req.parameters.get("lyricName") else {
            return req.eventLoop.future(error: Abort(.notFound));
        }
        let filePath = workingDirectory + "Resources/Lyrics/" + lyricName
        req.logger.info(Logger.Message(stringLiteral: filePath))
        let fileURL = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: fileURL)
        let lyric = String(data: data, encoding: .utf8) ?? ""
        return req.eventLoop.future(lyric)
    }
}

//func audioPath(for fileName: String) -> String {
//    workingDirectory + "Resources/Songs/" + (fileName.hasSuffix("mp3") ? fileName : (fileName + ".mp3"))
//}
