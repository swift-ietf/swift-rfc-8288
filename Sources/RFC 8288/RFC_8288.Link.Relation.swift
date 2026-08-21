extension RFC_8288.Link {

    public struct Relation: Hashable, Sendable {
        public let rawValue: String

        init(validated rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_8288.Link.Relation {
    public static func == (lhs: Self, rhs: Self) -> Bool {

        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.lowercased())
    }

    public static let next = Self(validated: "next")
}
