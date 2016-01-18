#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif
import Foundation
import Epoch

setbuf(stdout, nil)

let port = (NSProcessInfo.processInfo().environment["PORT"].flatMap { Int($0) }) ?? 8080

let standardResponder = ErrorReportingResponder(underlyingResponder: router)
let responder = CompositeResponder(webSocketResponder: webSocketServer, standardResponder: standardResponder)

log("Starting server on port \(port).")

Server(port: port, responder: responder).start()

