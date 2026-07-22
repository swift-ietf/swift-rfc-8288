public import Byte_Primitives
import Byte_Primitives_Standard_Library_Integration

extension RFC_8288.Link.Parameter {
    /// The decoded bytes of a token or quoted-string parameter value.
    public struct Value: Hashable, Sendable {
        public let bytes: [Byte]

        init(_ bytes: [Byte]) {
            self.bytes = bytes
        }

        public var string: String {
            String(decoding: bytes, as: UTF8.self)
        }
    }
}
