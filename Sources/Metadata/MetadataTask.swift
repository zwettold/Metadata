import Foundation
import libxml2

/// A task unit that performs the parsing of website's metadata.
public final class MetadataTask: NSObject, Identifiable {
    /// The unique identifier of the task.
    ///
    /// This is used to identify the task within the task queue.
    public let id: UUID

    /// The underlying network task that fetches the website's content.
    private let task: URLSessionDataTask

    /// The current state of the task.
    public private(set) var state: State = .idle

    /// Creates a new task unit with the given unique identifier and an underlying network task.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the task.
    ///   - task: The underlying network task.
    @usableFromInline
    internal init(id: UUID, task: URLSessionDataTask) throws {
        self.id = id
        self.task = task

        super.init()

        guard task.state == .suspended else {
            throw MetadataError.invalidTaskState(task: self)
        }

        self.task.delegate = self
    }
}

// MARK: MetadataTask.State

extension MetadataTask {
    /// A state of the metadata task unit.
    public enum State: Equatable {
        /// The metadata task has not been started yet.
        case idle

        /// The metadata task is currently fetching and parsing the website's metadata.
        case processing

        /// The metadata task has finished running.
        ///
        /// If the task has finished running successfully, the `error` property will be `nil`.
        /// Otherwise, the `error` property will hold the error that caused the task to fail.
        ///
        /// - Parameter error: The error that caused the task unit to finish running.
        case completed(error: MetadataError? = nil)
    }
}

// MARK: - URLSessionDataDelegate Conformance

extension MetadataTask: URLSessionDataDelegate {
    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        guard state == .idle else {
            runtimeWarning(
                """
                A task unit received a network response while it was in the %@ state.

                This is not a valid behavior and may indicate a bug in the application.
                Please report this issue to the library maintainer.
                """,
                [String(describing: state)]
            )
            return completionHandler(.cancel)
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            state = .completed(error: .invalidResponse(response, request: dataTask.originalRequest))
            completionHandler(.cancel)
            return
        }

        state = .processing
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard state == .processing else {
            runtimeWarning(
                """
                A task unit received data while it was in the %@ state.

                This is not a valid behavior and may indicate a bug in the application.
                Please report this issue to the library maintainer.
                """,
                [String(describing: state)]
            )
            return
        }

        // TODO(zwett): Parse the data.
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard state == .processing else {
            runtimeWarning(
                """
                A task unit completed while it was in the %@ state.

                This is not a valid behavior and may indicate a bug in the application.
                Please report this issue to the library maintainer.
                """,
                [String(describing: state)]
            )
            return
        }

        if let error = error {
            // A client-side error has occurred, such as being unable to resolve the hostname or connect to the host.
            state = .completed(error: .invalidRequest(task.originalRequest, error: error))
        } else {
            state = .completed()
        }
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard state == .processing else {
            runtimeWarning(
                """
                A task unit became invalid while it was in the %@ state.

                This is not a valid behavior and may indicate a bug in the application.
                Please report this issue to the library maintainer.
                """,
                [String(describing: state)]
            )
            return
        }

        if let error = error {
            // A client-side error has occurred, such as being unable to resolve the hostname or connect to the host.
            state = .completed(error: .invalidRequest(nil, error: error))
        } else {
            state = .completed()
        }
    }
}
