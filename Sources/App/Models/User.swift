import Vapor
import PostgreSQLProvider
import AuthProvider

final class User: Model {
    let storage = Storage()
    let name: String
    let email: String
    let password: String

    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
    }
    
    init(row: Row) throws {
        name = try row.get("name")
        email = try row.get("email")
        password = try row.get("password")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("email", email)
        try row.set("password", password)
        return row
    }
}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { users in
            users.id()
            users.string("name")
            users.string("email")
            users.string("password")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User: JSONRepresentable {
    func makeJSON() throws -> JSON {
        let json = try JSON(node:
            [
                "name": name,
                "email": email,
                "password": password
            ]
        )
        return json
    }
}

extension User: PasswordAuthenticatable {
    
}

extension User: TokenAuthenticatable {
    public typealias TokenType = Token
}

extension Request {
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}
