import Byte
import Byte
import RFC_3986
public import RFC_9110

extension RFC_8288.Link {

    public struct Parse: Sendable {
        public init() {}
    }
}

extension RFC_8288.Link.Parse {
    private static let field = "link"

    public func callAsFunction(
        _ headers: RFC_9110.Message.Headers
    ) throws(Error) -> [RFC_8288.Link] {
        try self(
            headers.compactMap { header in
                header.name.rawValue.lowercased() == Self.field ? header.value : nil
            }
        )
    }

    public func callAsFunction(
        _ values: [RFC_9110.Field.Value]
    ) throws(Error) -> [RFC_8288.Link] {
        var links: [RFC_8288.Link] = []
        for value in values {
            links.append(contentsOf: try self(value))
        }
        return links
    }

    public func callAsFunction(
        _ value: RFC_9110.Field.Value
    ) throws(Error) -> [RFC_8288.Link] {

        var input = [Byte](utf8: value.rawValue)[...]
        var links: [RFC_8288.Link] = []

        while true {
            whitespace(&input)
            while input.first?.bitPattern == 0x2C {
                input.removeFirst()
                whitespace(&input)
            }
            guard !input.isEmpty else { return links }

            links.append(try link(&input))
            whitespace(&input)

            guard let next = input.first else { return links }
            guard next.bitPattern == 0x2C else {
                throw .trailingContent(next)
            }
            input.removeFirst()
        }
    }

    private func link(
        _ input: inout ArraySlice<Byte>
    ) throws(Error) -> RFC_8288.Link {
        guard input.first?.bitPattern == 0x3C else { throw .expectedTarget }
        input.removeFirst()

        var targetBytes: [Byte] = []
        while let byte = input.first, byte.bitPattern != 0x3E {
            targetBytes.append(byte)
            input.removeFirst()
        }
        guard input.first?.bitPattern == 0x3E else { throw .unterminatedTarget }

        let target: RFC_3986.URI
        do throws(RFC_3986.Error) {
            target = try RFC_3986.URI(ascii: targetBytes)
        } catch {
            throw .invalidTarget(error)
        }
        input.removeFirst()

        var parameters: [RFC_8288.Link.Parameter] = []
        while true {
            whitespace(&input)
            guard input.first?.bitPattern == 0x3B else { break }
            input.removeFirst()
            whitespace(&input)
            parameters.append(try parameter(&input))
        }

        return .init(
            target: target,
            parameters: parameters,
            relations: try relations(parameters)
        )
    }

    private func parameter(
        _ input: inout ArraySlice<Byte>
    ) throws(Error) -> RFC_8288.Link.Parameter {
        guard let nameBytes = token(&input) else { throw .invalidParameterName }
        let name = RFC_8288.Link.Parameter.Name(
            validated: String(decoding: nameBytes, as: UTF8.self)
        )

        whitespace(&input)
        guard input.first?.bitPattern == 0x3D else {
            return .init(name: name, value: nil)
        }
        input.removeFirst()
        whitespace(&input)

        let value: [Byte]
        if input.first?.bitPattern == 0x22 {
            guard let quoted = quotedString(&input) else { throw .invalidQuotedValue }
            value = quoted
        } else {
            guard let bytes = token(&input) else { throw .invalidParameterValue }
            value = Swift.Array(bytes)
        }
        return .init(
            name: name,
            value: .init(validated: String(decoding: value, as: UTF8.self))
        )
    }

    private func whitespace(_ input: inout ArraySlice<Byte>) {
        while let byte = input.first, byte.bitPattern == 0x20 || byte.bitPattern == 0x09 {
            input.removeFirst()
        }
    }

    private func token(_ input: inout ArraySlice<Byte>) -> ArraySlice<Byte>? {
        let end = input.firstIndex { !RFC_9110.Token.isTchar($0.bitPattern) } ?? input.endIndex
        guard end > input.startIndex else { return nil }
        let bytes = input[input.startIndex..<end]
        input = input[end...]
        return bytes
    }

    private func quotedString(_ input: inout ArraySlice<Byte>) -> [Byte]? {
        guard input.first?.bitPattern == 0x22 else { return nil }
        var index = input.index(after: input.startIndex)
        var bytes: [Byte] = []
        while index < input.endIndex {
            let byte = input[index]
            switch byte.bitPattern {
            case 0x22:
                input = input[input.index(after: index)...]
                return bytes

            case 0x5C:
                index = input.index(after: index)
                guard index < input.endIndex, quotedPair(input[index]) else { return nil }
                bytes.append(input[index])

            case 0x09, 0x20, 0x21, 0x23...0x5B, 0x5D...0x7E, 0x80...:
                bytes.append(byte)

            default:
                return nil
            }
            index = input.index(after: index)
        }
        return nil
    }

    private func quotedPair(_ byte: Byte) -> Bool {
        switch byte.bitPattern {
        case 0x09, 0x20...0x7E, 0x80...: true
        default: false
        }
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

        let rawValue = value.rawValue
        guard
            !rawValue.isEmpty,
            !rawValue.hasPrefix(" "),
            !rawValue.hasSuffix(" ")
        else {
            throw .invalidRelation(rawValue)
        }

        var relations: [RFC_8288.Link.Relation] = []
        for element in rawValue.split(separator: " ") {
            let relation = String(element)
            guard valid(relation) else {
                throw .invalidRelation(rawValue)
            }
            relations.append(.init(validated: relation))
        }
        return relations
    }

    private func valid(_ relation: String) -> Bool {
        let bytes = [Byte](utf8: relation)
        guard let first = bytes.first?.bitPattern else { return false }
        let isLetter: (UInt8) -> Bool = { ($0 | 0x20) >= 0x61 && ($0 | 0x20) <= 0x7A }
        if isLetter(first),
            bytes.dropFirst().allSatisfy({
                let byte = $0.bitPattern
                return isLetter(byte) || (byte >= 0x30 && byte <= 0x39) || byte == 0x2E || byte == 0x2D
            })
        {
            return true
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
