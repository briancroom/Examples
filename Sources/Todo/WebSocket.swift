import WebSocket

let webSocketServer = WebSocketServer { webSocket in
    webSocket.listen { event in
        do {
            switch event {
            case .Text(let text):
                if text == "todos" {
                    let todos = try todoResources.todos.all()
                    if todos.count == 0 {
                        webSocket.send("You have no todos. Taking some time off? (:")
                    }
                    for todo in todos {
                        webSocket.send("\(todo)")
                    }
                }

                if text == "done" {
                    let doneTodos = try todoResources.todos.all().filter({ $0.done })
                    for todo in doneTodos {
                        webSocket.send("\(todo)")
                    }
                }
            default: break
            }
        } catch {
            webSocket.send("Oops, something went wrong.")
        }
    }
}
