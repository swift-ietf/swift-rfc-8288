extension RFC_8288.Link.Parameter {

    public struct Value: Hashable, Sendable {
        public let rawValue: String

        init(validated rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
