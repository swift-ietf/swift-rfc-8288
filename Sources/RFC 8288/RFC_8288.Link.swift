public import RFC_3986

extension RFC_8288 {
    /// A Web Link with its target URI reference and target attributes.
    public struct Link: Hashable, Sendable {
        public let target: RFC_3986.URI
        public let parameters: [Parameter]
        public let relations: [Relation]
    }
}
