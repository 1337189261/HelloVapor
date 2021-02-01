//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/1/28.
//


import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("api","users")
        usersRoute.get("all", use: getAllHandler(_:))
        usersRoute.get(":userid", use: getHandler(_:))
        usersRoute.get(":userid", "songs", use: getSongsHandler(_:))
        usersRoute.put(":userid", use: updateHandler(_:))
        usersRoute.post("signup", use: createHandler(_:))
        
        usersRoute.get("search", use: searchHandler(_:))
        
        let basicAuthMiddleware = User.authenticator()
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)

        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.on(.POST, "updateAvatar", body: .collect(maxSize: "1mb"), use: updateAvatarHandler(_:))
        tokenAuthGroup.delete(":userid", use: deleteHandler(_:))
    }

    func createHandler(_ req: Request) throws -> EventLoopFuture<Token> {
        try User.validate(content: req)
        let user = try req.content.decode(User.self)
        user.password = try Bcrypt.hash(user.password)
        var token: Token!
        return checkIfUserExists(user.username, req: req)
            .flatMap { $0 ? req.eventLoop.future(error: UserError.usernameTaken) : user.save(on: req.db)}
            .flatMap {
                guard let newToken = try? Token.generate(for: user) else {
                    return req.eventLoop.future(error: Abort(.internalServerError))
                }
                token = newToken
                return token.save(on: req.db)
            }
            .map {token}
    }

    func getHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
        User.find(req.parameters.get("userid"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .convertToPublic()
    }

    func getSongsHandler(_ req:Request) throws -> EventLoopFuture<[Song]> {
        User.find(req.parameters.get("userid"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (user) in
                user.$songs.get(on: req.db)
            }
    }

    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[User.Public]> {
        User.query(on: req.db).all().convertToPublic()
    }

    func updateHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
        let updateUser = try req.content.decode(User.self)
        return User.find(req.parameters.get("userid"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (user) in
                user.username = updateUser.username
                return user.save(on: req.db).map { user.convertToPublic() }
            }
    }

    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        User.find(req.parameters.get("userid"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (user) in
                user.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }

    func searchHandler(_ req: Request) throws -> EventLoopFuture<[User.Public]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return User.query(on: req.db).filter(\.$username == searchTerm)
            .all().convertToPublic()
    }
    
    func loginHandler(_ req: Request) throws -> EventLoopFuture<Token> {
      let user = try req.auth.require(User.self)
      let token = try Token.generate(for: user)
      return token.save(on: req.db).map { token }
    }
    
    func updateAvatarHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        let imageData = try req.content.decode(ImageUploadData.self)
        let name = try "\(user.requireID())-\(UUID().uuidString).jpeg"
        let path = workingDirectory + "Images/" + name
        FileManager().createFile(atPath: path, contents: imageData.picture, attributes: nil)
        user.avatar = name
        return user.save(on: req.db).transform(to: .noContent)
    }
    
    private func checkIfUserExists(_ username: String, req: Request) -> EventLoopFuture<Bool> {
      User.query(on: req.db)
        .filter(\.$username == username)
        .first()
        .map { $0 != nil }
    }
    
}

struct ImageUploadData: Content {
    var picture: Data
}
