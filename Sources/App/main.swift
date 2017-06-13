import Vapor
import PostgreSQLProvider
import AuthProvider

let config = try Config()

do {
    try config.addProvider(PostgreSQLProvider.Provider.self)
    config.preparations.append(User.self)
    config.preparations.append(Token.self)
} catch {
    assertionFailure("Error adding provider: \(error)")
}

config.addConfigurable(middleware: PasswordAuthenticationMiddleware(User.self), name: "sessions")
config.addConfigurable(middleware: TokenAuthenticationMiddleware(User.self), name: "token")

let drop = try Droplet(config)

let uc = UserController()
uc.addRoutes(to: drop)

try drop.run()
