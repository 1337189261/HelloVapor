import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: UserController())
    try app.register(collection: SongController())
    try app.register(collection: FileController())
    try app.register(collection: PlaylistController())
    try app.register(collection: HomeController())
    try app.register(collection: CommentController())
}
