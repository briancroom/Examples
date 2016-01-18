import HTTP

struct ErrorReportingResponder: ResponderType {
    let underlyingResponder: ResponderType

    func respond(request: Request) -> Response {
        do {
            return try underlyingResponder.respond(request)
        } catch let e {
            logError("Error was thrown while responding:\n\(e)")
            return Response(status: .InternalServerError, body: "Oops, something went wrong! The error was: \n\(e)")
        }
    }
}
