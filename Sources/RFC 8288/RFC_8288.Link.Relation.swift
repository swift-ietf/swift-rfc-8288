extension RFC_8288.Link {
    /// A registered or extension link relation type.
    public struct Relation: Hashable, Sendable {
        public let rawValue: String

        init(validated rawValue: String) {
            self.rawValue = rawValue
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue.lowercased())
        }

        public static let next = Self(validated: "next")
    }
}
