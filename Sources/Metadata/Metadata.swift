import Foundation

/// A representation of a website's metadata.
///
/// > Important: Temporarily, ``Metadata`` contains only the `title` of the website.
///              This will be addressed and expanded once the metadata extraction is
///              properly implemented.
public struct Metadata: Sendable {
    /// The title of the website.
    public let title: String?

    /// Creates a metadata description with the given title.
    ///
    /// - Parameter title: The title of the website.
    @inlinable
    public init(title: String? = nil) {
        self.title = title
    }
}

// MARK: - CustomStringConvertible

extension Metadata: CustomStringConvertible {
    public var description: String {
        "Metadata(title: \(title ?? "nil"))"
    }
}
