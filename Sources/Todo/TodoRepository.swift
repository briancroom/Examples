import PostgreSQL
import CLibpq
import Foundation

protocol TodoRepository: class {
    func insert(title: String, done: Bool) throws -> Todo
    func all() throws -> [Todo]
    func find(id: String) throws -> Todo?
    func update(todo: Todo) throws
    func delete(id: String) throws
}

final class TransientTodoRepository: TodoRepository {
    private var todos: [String: Todo] = [:]
    private var nextId: Int = 0

    func insert(title: String, done: Bool) -> Todo {
        let todo = Todo(id: String(nextId), title: title, done: done)
        todos[todo.id] = todo
        nextId += 1

        return todo
    }

    func all() -> [Todo] {
        return todos.sort({ $0.0 < $1.0 }).map({ $0.1 })
    }

    func find(id: String) -> Todo? {
        return todos[id]
    }

    func update(todo: Todo) {
        todos[todo.id] = todo
    }

    func delete(id: String) {
        todos[id] = nil
    }
}

final class PostgresTodoRepository: TodoRepository {
    let connectionInfo: Connection.Info
    var connection: Connection?

    init(connectionInfo: Connection.Info) {
        self.connectionInfo = connectionInfo
    }

    deinit {
        connection?.close()
    }

    private func db() throws -> Connection {
        if let db = connection {
            return db
        } else {
            let db = Connection(connectionInfo)
            log("Trying to open DB")
            try db.open()
            log("Creating DB table")
            try db.execute("CREATE TABLE IF NOT EXISTS todos (id SERIAL PRIMARY KEY, title VARCHAR(256), done BOOLEAN)")
            connection = db

            return db
        }
    }

    func insert(title: String, done: Bool) throws -> Todo {
        let result = try db().execute("INSERT INTO todos (title, done) VALUES('\(title)', \(done ? "TRUE" : "FALSE")) RETURNING id")
        let id = result[0]["id"]!.string!
        return Todo(id: id, title: title, done: done)
    }

    func all() throws -> [Todo] {
        let result = try db().execute("SELECT * FROM todos ORDER BY id")
        return result.map { row in
            return Todo(
                id: row["id"]!.string!,
                title: row["title"]!.string!,
                done: row["done"]!.boolean!
            )   
        }
    }

    func find(id: String) throws -> Todo? {
        let result = try db().execute("SELECT * FROM todos WHERE id = '\(id)'")
        if result.count > 0 {
            return Todo(
                id: result[0]["id"]!.string!,
                title: result[0]["title"]!.string!,
                done: result[0]["done"]!.boolean!
            )
        }
        return nil
    }

    func update(todo: Todo) throws {
        try db().execute("UPDATE todos SET title = '\(todo.title)', done = \(todo.done ? "TRUE" : "FALSE") WHERE id = '\(todo.id)'")
    }

    func delete(id: String) throws {
        try db().execute("DELETE from todos WHERE id = '\(id)'")
    }
}
