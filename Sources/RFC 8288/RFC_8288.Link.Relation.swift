extension RFC_8288.Link {
    /// A registered or extension link relation type.
    public struct Relation: Hashable, Sendable {
        public let rawValue: String

        init(validated rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_8288.Link.Relation {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        // swift-linter:disable:next raw value access
        // REASON: same-package implementation — the type's own Equatable witness projecting its own `rawValue`.
        // swift-linter:disable:next chained rawvalue access
        // REASON: same-package implementation — the type's own Equatable witness projecting its own `rawValue`.
        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.lowercased())
    }

    public static let next = Self(validated: "next")
}
