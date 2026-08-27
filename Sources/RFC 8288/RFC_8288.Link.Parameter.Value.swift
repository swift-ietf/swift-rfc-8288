public import Byte
import Byte_Standard_Library_Integration

extension RFC_8288.Link.Parameter {

    public struct Value: Hashable, Sendable {
        public let bytes: [Byte]

        init(_ bytes: [Byte]) {
            self.bytes = bytes
        }
    }
}

extension RFC_8288.Link.Parameter.Value {
    public var string: String {
        String(decoding: bytes, as: UTF8.self)
    }
}
