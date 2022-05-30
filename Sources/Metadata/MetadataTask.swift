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
    public enum State {
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

extension MetadataTask: URLSessionDataDelegate {}
