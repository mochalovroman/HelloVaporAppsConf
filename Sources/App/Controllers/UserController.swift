import Vapor
import AuthProvider

final class UserController {
    func addRoutes(to drop: Droplet) {
        drop.post("register", handler: saveHandler)
        
        drop.group(PasswordAuthenticationMiddleware(User.self)) { basicauth in
            basicauth.get("login", handler: loginHandler)
        }
        
        drop.group(TokenAuthenticationMiddleware(User.self)) { tokenauth in
            tokenauth.get("me", handler: meHandler)
            tokenauth.get("userlist", handler: userListHandler)
        }
    }
    
    func userListHandler(_ req: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }
    
    func meHandler(_ req: Request) throws -> ResponseRepresentable {
        return try req.user().name
    }
    
    func loginHandler(_ req: Request) throws -> ResponseRepresentable {
        let existUser = try req.user()
        if (existUser.email.isEmpty) {
            return try JSON(node: ["message": "Unkwown login error"])
        } else {
            return try JSON(node: ["message": "You logged succesfully \(existUser.email)"])
        }
    }
    
    func saveHandler(_ req: Request) throws -> ResponseRepresentable {
        guard let name = req.data["name"]?.string,
            let email = req.data["email"]?.string,
            let password = req.data["password"]?.string else {
                throw Abort.badRequest
        }
        
        let user = User(name: name,
                        email: email,
                        password: password)
        
        let existUsers = try User.makeQuery().filter("email", .equals, email).all()
        if existUsers.count == 0 {
            try user.save()
            let token = Token(token: user.name+"appsconf", user_id: user.id!)
            try token.save()
            print("token owner: \(try token.user.get()!.email)")
        } else {
            throw Abort(.conflict, reason: "User already exist", identifier: "demoAppExistError")
        }
        
        return try user.makeJSON()
    }
}
