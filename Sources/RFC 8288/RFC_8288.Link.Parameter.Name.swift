extension RFC_8288.Link.Parameter {
    /// A case-insensitive HTTP token naming a link parameter.
    public struct Name: Hashable, Sendable {
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

        public static let relation = Self(validated: "rel")
    }
}
