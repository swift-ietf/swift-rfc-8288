import Byte_Parser_Primitives
import Byte_Primitives_Standard_Library_Integration
import RFC_3986
public import RFC_9110

extension RFC_8288.Link {
    /// Parses the HTTP `Link` field representation defined by RFC 8288 Section 3.
    public struct Parse: Sendable {
        public init() {}
    }
}

extension RFC_8288.Link.Parse {
    public func callAsFunction(
        _ headers: RFC_9110.Headers
    ) throws(Error) -> [RFC_8288.Link] {
        try self(headers.values("Link"))
    }

    public func callAsFunction(
        _ values: [RFC_9110.Header.Field.Value]
    ) throws(Error) -> [RFC_8288.Link] {
        var links: [RFC_8288.Link] = []
        for value in values {
            links.append(contentsOf: try self(value))
        }
        return links
    }

    public func callAsFunction(
        _ value: RFC_9110.Header.Field.Value
    ) throws(Error) -> [RFC_8288.Link] {
        // swift-linter:disable:next raw value access
        // REASON: no typed byte accessor exposed by `RFC_9110.Header.Field.Value`; `.rawValue` is its only projection.
        var input = Byte.Input(utf8: value.rawValue)
        var links: [RFC_8288.Link] = []

        while true {
            RFC_9110.Parse.OWS<Byte.Input>().parse(&input)
            while input.first == 0x2C {
                input.removeFirst()
                RFC_9110.Parse.OWS<Byte.Input>().parse(&input)
            }
            guard !input.isEmpty else { return links }

            links.append(try link(&input))
            RFC_9110.Parse.OWS<Byte.Input>().parse(&input)

            guard !input.isEmpty else { return links }
            guard input.first == 0x2C else {
                throw .trailingContent(input[input.startIndex])
            }
            input.removeFirst()
        }
    }

    private func link(
        _ input: inout Byte.Input
    ) throws(Error) -> RFC_8288.Link {
        guard input.first == 0x3C else { throw .expectedTarget }
        input.removeFirst()

        var targetBytes: [Byte] = []
        while let byte = input.first, byte != 0x3E {
            targetBytes.append(byte)
            input.removeFirst()
        }
        guard input.first == 0x3E else { throw .unterminatedTarget }

        let target: RFC_3986.URI
        do throws(RFC_3986.Error) {
            target = try RFC_3986.URI(ascii: targetBytes)
        } catch {
            throw .invalidTarget(error)
        }
        input.removeFirst()

        var parameters: [RFC_8288.Link.Parameter] = []
        while true {
            RFC_9110.Parse.OWS<Byte.Input>().parse(&input)
            guard input.first == 0x3B else { break }
            input.removeFirst()
            RFC_9110.Parse.OWS<Byte.Input>().parse(&input)
            parameters.append(try parameter(&input))
        }

        return .init(
            target: target,
            parameters: parameters,
            relations: try relations(parameters)
        )
    }

    private func parameter(
        _ input: inout Byte.Input
    ) throws(Error) -> RFC_8288.Link.Parameter {
        let nameBytes: Byte.Input
        do throws(RFC_9110.Parse.Token<Byte.Input>.Error) {
            nameBytes = try RFC_9110.Parse.Token<Byte.Input>().parse(&input)
        } catch {
            throw .invalidParameterName
        }
        let name = RFC_8288.Link.Parameter.Name(
            validated: String(decoding: nameBytes, as: UTF8.self)
        )

        RFC_9110.Parse.OWS<Byte.Input>().parse(&input)
        guard input.first == 0x3D else {
            return .init(name: name, value: nil)
        }
        input.removeFirst()
        RFC_9110.Parse.OWS<Byte.Input>().parse(&input)

        let value: [Byte]
        if input.first == 0x22 {
            do throws(RFC_9110.Parse.QuotedString<Byte.Input>.Error) {
                value = try RFC_9110.Parse.QuotedString<Byte.Input>().parse(&input)
            } catch {
                throw .invalidQuotedValue
            }
        } else {
            let token: Byte.Input
            do throws(RFC_9110.Parse.Token<Byte.Input>.Error) {
                token = try RFC_9110.Parse.Token<Byte.Input>().parse(&input)
            } catch {
                throw .invalidParameterValue
            }
            value = Swift.Array(token)
        }
        return .init(name: name, value: .init(value))
    }

    private func relations(
        _ parameters: [RFC_8288.Link.Parameter]
    ) throws(Error) -> [RFC_8288.Link.Relation] {
        guard let parameter = parameters.first(where: { $0.name == .relation }) else {
            return []
        }
        guard let value = parameter.value else {
            throw .invalidRelation("")
        }

        var relations: [RFC_8288.Link.Relation] = []
        var start = value.bytes.startIndex
        var index = start
        while index <= value.bytes.endIndex {
            if index == value.bytes.endIndex || value.bytes[index] == 0x20 {
                guard start < index else {
                    throw .invalidRelation(value.string)
                }
                let bytes = Swift.Array(value.bytes[start..<index])
                guard valid(bytes) else {
                    throw .invalidRelation(String(decoding: bytes, as: UTF8.self))
                }
                relations.append(
                    .init(validated: String(decoding: bytes, as: UTF8.self))
                )
                if index == value.bytes.endIndex { break }
                repeat {
                    index = value.bytes.index(after: index)
                } while index < value.bytes.endIndex && value.bytes[index] == 0x20
                start = index
                continue
            }
            index = value.bytes.index(after: index)
        }
        return relations
    }

    private func valid(_ bytes: [Byte]) -> Bool {
        guard let first = bytes.first else { return false }
        if first >= 0x61 && first <= 0x7A {
            return bytes.dropFirst().allSatisfy {
                ($0 >= 0x61 && $0 <= 0x7A)
                    || ($0 >= 0x30 && $0 <= 0x39)
                    || $0 == 0x2E
                    || $0 == 0x2D
            }
        }

        let uri: RFC_3986.URI
        do throws(RFC_3986.Error) {
            uri = try RFC_3986.URI(ascii: bytes)
        } catch {
            return false
        }
        return uri.scheme != nil
    }
}
