extension RFC_8288.Link {

    public struct Parameter: Hashable, Sendable {
        public let name: Name
        public let value: Value?
    }
}
