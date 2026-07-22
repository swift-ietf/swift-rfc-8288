public import Byte_Primitives
public import RFC_3986

extension RFC_8288.Link.Parse {
    public enum Error: Swift.Error, Hashable, Sendable {
        case expectedTarget
        case invalidParameterName
        case invalidParameterValue
        case invalidQuotedValue
        case invalidRelation(String)
        case invalidTarget(RFC_3986.Error)
        case trailingContent(Byte)
        case unterminatedTarget
    }
}
