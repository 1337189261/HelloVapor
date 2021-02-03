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
 
 
 docker run --name postgres-test \
   -e POSTGRES_DB=vapor-test \
   -e POSTGRES_USER=vapor_username \
   -e POSTGRES_PASSWORD=vapor_password \
   -p 5433:5432 -d postgres
 */
// configures your application

var workingDirectory: String = ""
public func configure(_ app: Application) throws {
    
    let databaseName: String
    let databasePort: Int
    if app.environment == .testing {
        databaseName = "vapor-test"
        databasePort = 5433
    } else {
        databaseName = "vapor-database"
        databasePort = 5432
    }
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)
    
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: databasePort,
        username: Environment.get("DATABASE_USERNAME")
            ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? databaseName
    ), as: .psql)
    app.migrations.add(CreateUser())
    app.migrations.add(CreateSong())
    app.migrations.add(CreateToken())
    app.migrations.add(CreateFollowRelation())
    app.databases.middleware.use(UserMiddleware())
    try app.autoMigrate().wait()
    app.views.use(.leaf)
    workingDirectory = app.directory.workingDirectory
    
    try routes(app)
}
