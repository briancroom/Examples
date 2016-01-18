import HTTP

/// A responder that accepts WebSocket requests and standard HTTP requests
struct CompositeResponder: ContextResponderType {
    let webSocketResponder: ContextResponderType
    let standardResponder: ResponderType

    func respond(context: Context) {
        let wrappedRespond: Response -> Void = { webSocketResponse in
            if webSocketResponse.statusCode < 400 {
                context.respond(webSocketResponse)
            } else {
                let routerResponse: Response
                do {
                    routerResponse = try self.standardResponder.respond(context.request)
                } catch {
                    routerResponse = Response(status: .InternalServerError)
                }
                context.respond(routerResponse)
            }
        }

        let wrappedContext = Context(request: context.request, respond: wrappedRespond, upgrade: context.upgrade)
        webSocketResponder.respond(wrappedContext)
    }
}
