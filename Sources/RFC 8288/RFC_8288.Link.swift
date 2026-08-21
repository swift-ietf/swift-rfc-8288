public import RFC_3986

extension RFC_8288 {

    public struct Link: Hashable, Sendable {
        public let target: RFC_3986.URI
        public let parameters: [Parameter]
        public let relations: [Relation]
    }
}
