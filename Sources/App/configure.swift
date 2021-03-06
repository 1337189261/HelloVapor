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
var recreateDatabase: Bool {
    true
}
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
//    print(FileManager.default.homeDirectoryForCurrentUser.standardizedFileURL)
//    print(("~" as NSString).expandingTildeInPath)
//    print(NSHomeDirectory())
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
    app.migrations.add(CreateComment())
    app.migrations.add(CreateCommentReply())
    
    app.migrations.add(CreateFollowRelation())
    app.migrations.add(CreatePlaylistFollowRelation())
    app.migrations.add(CreatePlaylistSongRelation())
    app.migrations.add(CreateUserArtistFollowRelation())
    app.migrations.add(CreateMoment())
    
    app.databases.middleware.use(UserMiddleware())
    if recreateDatabase {
        print("recreate Database")
        try app.autoRevert().wait()
    }
    try app.autoMigrate().wait()
    app.views.use(.leaf)
    if isLinux {
        workingDirectory = "/home/jiahao/HelloVapor/"
    } else {
        workingDirectory = app.directory.workingDirectory
    }
    app.logger.info(.init(stringLiteral: workingDirectory))
    if recreateDatabase {
        try createMockData(db: app.db)
    }
    try routes(app)
}
var chengdu: Song!
var haoyu: User!
let chengduId = UUID(uuidString: "43b82c23-2e83-474f-869d-adb373119fbb")!
let haoyuId = UUID(uuidString: "a8fde558-7cee-44dc-849b-a88ae686279e")!
func createMockData(db: Database) throws {
    let user = User(id: haoyuId, username: "chy", hashedPassword: try Bcrypt.hash("chypassword"), email: "chy@chy.com", avatar: "avatar.jpg".imgUrl)
    try user.save(on: db).wait()
    haoyu = user
    let token = Token(value: "VcTB88YiiLK4Khnrbdfl/g==", userID: user.id!)
    try token.save(on: db).wait()
    let artists = try [("赵雷", "ZhaoLei.jpg"), ("毛不易", "MaoBuYi.jpg"), ("林俊杰", "JJLin.jpg")].map { (name, imgName) -> Artist in
        let artist = Artist(nickname: name,avatarUrl: imgName.imgUrl)
        try artist.save(on:db).wait()
        return artist
    }
    let songs = [
        Song(id:chengduId ,authorId: artists[0].id!, filename: "chengdu", name: "成都", duration: 328, lyricName: "chengdu.lrc"),
        Song(authorId: artists[1].id!, filename: "xiangwozheyangderen", name: "像我这样的人", duration: 208),
        Song(authorId: artists[2].id!, filename: "guanjianci", name: "关键词", duration: 212)
    ]
    try songs.forEach {try $0.save(on: db).wait()}
    chengdu = songs[0]
    let playlist = Playlist(creatorId: user.id!, name: "别急，我们会在无数个晚风中相遇", avatarUrl: "fm1.jpg".imgUrl)
    try playlist.save(on: db).wait()
    try songs.forEach {
        try playlist.$songs.attach($0, on: db).wait()
    }
    
    
    
    let jayChou = Artist(nickname: "周杰伦", avatarUrl: "JayChou.jpg".imgUrl)
    try jayChou.save(on: db).wait()
    let songs2 = [Song(authorId: jayChou.id!, filename: "gaobaiqiqiu", name: "告白气球", duration: 215),
                  Song(authorId: jayChou.id!, filename: "shuohaobuku", name: "说好不哭", duration: 222),
                  Song(authorId: jayChou.id!, filename: "bunengshuodemimi", name: "不能说的秘密", duration: 297),]
    try songs2.forEach {try $0.save(on: db).wait()}
    let playlist2 = Playlist(creatorId: user.id!, name: "周杰伦的歌", avatarUrl: "fm2.jpg".imgUrl)
    try playlist2.save(on: db).wait()
    try songs2.forEach {
        try playlist2.$songs.attach($0, on: db).wait()
    }
    
    mockComment(on: db)
    mockMoment(on: db)
}
