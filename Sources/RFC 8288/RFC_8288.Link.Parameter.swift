extension RFC_8288.Link {
    /// A link parameter, including extension parameters unknown to this package.
    public struct Parameter: Hashable, Sendable {
        public let name: Name
        public let value: Value?

        init(name: Name, value: Value?) {
            self.name = name
            self.value = value
        }
    }
}
