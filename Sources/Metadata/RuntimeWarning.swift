// https://www.pointfree.co/blog/posts/70-unobtrusive-runtime-warnings-for-libraries

#if DEBUG
    import os
    import XCTest

    private let rw = (
        dso: { () -> UnsafeMutableRawPointer in
            let count = _dyld_image_count()
            for i in 0..<count {
                if let name = _dyld_get_image_name(i) {
                    let swiftString = String(cString: name)
                    if swiftString.hasSuffix("/SwiftUI") {
                        if let header = _dyld_get_image_header(i) {
                            return UnsafeMutableRawPointer(mutating: UnsafeRawPointer(header))
                        }
                    }
                }
            }
            return UnsafeMutableRawPointer(mutating: #dsohandle)
        }(),
        log: OSLog(subsystem: "com.apple.runtime-issues", category: "Metadata")
    )
#endif

@_transparent
@inline(__always)
func runtimeWarning(_ message: @autoclosure () -> StaticString, _ args: @autoclosure () -> [CVarArg] = []) {
    #if DEBUG
        let message = message()
        unsafeBitCast(
            os_log as (OSLogType, UnsafeRawPointer, OSLog, StaticString, CVarArg...) -> Void,
            to: ((OSLogType, UnsafeRawPointer, OSLog, StaticString, [CVarArg]) -> Void).self
        )(.fault, rw.dso, rw.log, message, args())
        XCTFail(String(format: "\(message)", arguments: args()))
    #endif
}
