#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif
import Foundation

func log(message: String, error: Bool = false) {
    let pid = NSProcessInfo.processInfo().processIdentifier
    fputs("* (\(pid)) \(message)\n", error ? stderr : stdout)
}

func logError(message: String) {
    log(message, error: true)
}
