import Foundation
import Core
import HTTP
import Middleware
import PostgreSQL

let todoResources: TodoResources = {
    let repository: TodoRepository
    if let connectionString = NSProcessInfo.processInfo().environment["DATABASE_URL"] {
        // "postgresql://devfloater106-xl:postgres@localhost/todos"
        let connectionInfo = Connection.Info(connectionString: connectionString)
        log("Using PostgresTodoRepository")
        repository = PostgresTodoRepository(connectionInfo: connectionInfo)
    } else {
        log("Using TransientTodoRepository")
        repository = TransientTodoRepository()
    }

    return TodoResources(repository: repository)
}()

final class TodoResources {
    let todos: TodoRepository

    init(repository: TodoRepository){
        todos = repository
    }

    func index(request: Request) throws -> Response {
        let json: JSON = ["todos": JSON.from(try todos.all().map(Todo.toJSON))]
        return Response(status: .OK, json: json)
    }

    func create(request: Request) throws -> Response {
        guard let json = request.JSONBody, title = json["title"]?.stringValue else {
            return Response(status: .BadRequest)
        }
        let todo = try todos.insert(title, done: false)
        return Response(status: .OK, json: todo.toJSON())
    }

    func show(request: Request) throws -> Response {
        guard let id = request.parameters["id"], todo = try todos.find(id) else {
            return Response(status: .NotFound)
        }
        return Response(status: .OK, json: todo.toJSON())
    }

    func update(request: Request) throws -> Response {
        guard let id = request.parameters["id"] where try todos.find(id) != nil else {
            return Response(status: .NotFound)
        }
        guard let json = request.JSONBody,
            title = json["title"]?.stringValue,
            done = json["done"]?.boolValue else {
                return Response(status: .BadRequest)
        }
        try todos.update(Todo(id: id, title: title, done: done))
        return Response(status: .NoContent)
    }

    func destroy(request: Request) throws -> Response {
        guard let id = request.parameters["id"] where try todos.find(id) != nil else {
            return Response(status: .NotFound)
        }
        try todos.delete(id)
        return Response(status: .NoContent)
    }
}
