import Foundation

/// The errors which can occur within the `Metadata` framework.
public enum MetadataError: LocalizedError, Hashable {
    /// The metadata task unit is in an invalid state.
    ///
    /// - Parameter task: The metadata task unit that is in an invalid state.
    case invalidTaskState(task: MetadataTask? = nil)

    /// An error that indicates a failure that is not covered by a more specific error case.
    ///
    /// Whenever possible, more specific error cases should be thrown. Fallback to `MetadataError.generic` _only_ when
    /// no other error cases are applicable.
    ///
    /// - Parameters:
    ///   - errorDescription: A localized message describing what error occurred.
    ///   - failureReason: A localized message describing the reason for the failure.
    ///   - recoverySuggestion: A localized message describing how one might recover from the failure.
    ///   - helpAnchor: A localized message providing “help” text if the user requests help.
    case generic(
        _ errorDescription: String,
        failureReason: String? = nil,
        recoverySuggestion: String? = nil,
        helpAnchor: String? = nil
    )

    // MARK: LocalizedError

    public var errorDescription: String? {
        switch self {
        case .invalidTaskState(let task):
            guard let task = task else {
                return "The task unit is in an invalid state."
            }
            return "The task unit with an id \(task.id) is in an invalid state."
        case .generic(let errorDescription, _, _, _):
            return errorDescription
        }
    }

    public var failureReason: String? {
        switch self {
        case .invalidTaskState(_):
            return nil
        case .generic(_, let failureReason, _, _):
            return failureReason
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .invalidTaskState(_):
            return nil
        case .generic(_, _, let recoverySuggestion, _):
            return recoverySuggestion
        }
    }

    public var helpAnchor: String? {
        switch self {
        case .invalidTaskState(_):
            return nil
        case .generic(_, _, _, let helpAnchor):
            return helpAnchor
        }
    }
}
