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
        databaseName = "vapor_database"
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
    // 这里的 migration 的添加是有顺序要求的
    app.migrations.add(CreateUser())
    app.migrations.add(CreateArtist())
    app.migrations.add(CreateSong())
    app.migrations.add(CreateToken())
    app.migrations.add(CreatePlaylist())
    
    app.migrations.add(CreateFollowRelation())
    app.migrations.add(CreatePlaylistFollowRelation())
    app.migrations.add(CreatePlaylistSongRelation())
    app.migrations.add(CreateUserArtistFollowRelation())
    
    app.databases.middleware.use(UserMiddleware())
    try app.autoRevert().wait()
    try app.autoMigrate().wait()
    app.views.use(.leaf)
    workingDirectory = app.directory.workingDirectory
    if isLinux {
        workingDirectory = "/home/ubuntu/HelloVapor/"
    } else {
        workingDirectory = app.directory.workingDirectory
    }
    app.logger.info(.init(stringLiteral: workingDirectory))
    try createMockData(db: app.db)
    try routes(app)
}

func createMockData(db: Database) throws {
    let artists = try ["赵雷", "毛不易", "林俊杰"].map { name -> Artist in
        let artist = Artist(nickname: name)
        try artist.save(on:db).wait()
        return artist
    }
    
    let songs = [
        Song(authorId: artists[0].id!, songUrl: "chengdu".songUrl, name: "成都"),
        Song(authorId: artists[1].id!, songUrl: "xiangwozheyangderen".songUrl, name: "像我这样的人"),
        Song(authorId: artists[2].id!, songUrl: "guanjianci".songUrl, name: "关键词")
    ]
    try songs.forEach {try $0.save(on: db).wait()}
    
    let user = User(username: "chy", hashedPassword: try Bcrypt.hash("chypassword"), email: "chy@chy.com", avatar: "avatar.jpg".imgUrl)
    try user.save(on: db).wait()
    
    let playlist = Playlist(creatorId: user.id!, name: "别急，我们会在无数个晚风中相遇", avatarUrl: "fm1.jpg".imgUrl)
    try playlist.save(on: db).wait()
    try songs.forEach {
        try playlist.$songs.attach($0, on: db).wait()
    }
    
}
