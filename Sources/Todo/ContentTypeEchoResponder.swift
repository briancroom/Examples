import HTTP

struct ContentTypeEchoResponder: ResponderType {
    let underlyingResponder: ResponderType

    func respond(request: Request) throws -> Response {
        let response = try underlyingResponder.respond(request)

        if response.statusCode == 200 && response.headers["Content-Type"] == nil {
            if let requestType = contentTypeFromRequest(request) {
                var headers = response.headers
                headers["Content-Type"] = requestType

                return Response(
                    statusCode: response.statusCode,
                    reasonPhrase: response.reasonPhrase,
                    majorVersion: response.majorVersion,
                    minorVersion: response.minorVersion,
                    headers: headers,
                    body: response.body)
            }
        }
        return response
    }

    private func contentTypeFromRequest(request: Request) -> String? {
        if let acceptType = request.headers["Accept"]?.componentsSeparatedByString(",").first where !acceptType.containsString("*") {
            return acceptType
        } else {
            return nil
        }
    }
}
