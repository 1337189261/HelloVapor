import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
/*
    docker stop postgres
    docker rm postgres
    docker run --name postgres \
    -e POSTGRES_DB=vapor_database \
    -e POSTGRES_USER=vapor_username \
    -e POSTGRES_PASSWORD=vapor_password \
    -p 5432:5432 -d postgres
 */
// configures your application

var workingDirectory: String = ""
public func configure(_ app: Application) throws {
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)
    
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)
    app.migrations.add(CreateUser())
    app.migrations.add(CreateSong())
    app.migrations.add(CreateToken())
    
//    app.logger.logLevel = .debug
    try app.autoMigrate().wait()
    app.views.use(.leaf)
    workingDirectory = app.directory.workingDirectory
    
    try routes(app)
}
