import RFC_8288
import RFC_3986
import RFC_9110
import Testing

@Suite
struct `RFC 8288 Link Parse Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `RFC 8288 Link Parse Tests`.Unit {
    @Test
    func `Single next link`() throws {
        let links = try parse("<https://api.example.test/items?page=2>; rel=next")

        #expect(links.count == 1)
        #expect(links[0].target.value == "https://api.example.test/items?page=2")
        #expect(links[0].relations == [.next])
    }

    @Test
    func `Multiple values and field instances preserve order`() throws {
        let headers = RFC_9110.Headers([
            try .init(
                name: "Link",
                value: "<https://example.test/1>; rel=first, <https://example.test/2>; rel=next"
            ),
            try .init(name: "Link", value: "<https://example.test/3>; rel=last"),
        ])

        let links = try RFC_8288.Link.Parse()(headers)

        #expect(links.map(\.target.value) == [
            "https://example.test/1",
            "https://example.test/2",
            "https://example.test/3",
        ])
        #expect(links[1].relations.contains(.next))
    }

    @Test
    func `Quoted delimiters and escapes remain parameter data`() throws {
        let links = try parse(
            #"</items?page=2>; rel="next prev"; title="a,b;c\\d"; x-extension=opaque; flag"#
        )

        #expect(links[0].target.value == "/items?page=2")
        #expect(links[0].relations.map(\.rawValue) == ["next", "prev"])
        #expect(links[0].parameters[1].value?.string == #"a,b;c\d"#)
        // swift-linter:disable:next raw value access
        // REASON: test asserts the RawRepresentable `rawValue` contract directly.
        #expect(links[0].parameters[2].name.rawValue == "x-extension")
        #expect(links[0].parameters[2].value?.string == "opaque")
        #expect(links[0].parameters[3].value == nil)
    }

    @Test
    func `Token and quoted relations are equivalent`() throws {
        let token = try parse("</next>; rel=next")
        let quoted = try parse(#"</next>; rel="next""#)

        #expect(token[0].relations == quoted[0].relations)
    }

    @Test
    func `Only first relation parameter determines semantics`() throws {
        let links = try parse(#"</next>; rel="next"; REL=last"#)

        #expect(links[0].parameters.count == 2)
        #expect(links[0].relations == [.next])
    }

    @Test
    func `Empty list members are ignored`() throws {
        let links = try parse(", , </next>; rel=next, ")

        #expect(links.count == 1)
    }

    @Test(arguments: [
        "items?page=2>; rel=next",
        "<items?page=2; rel=next",
        "<https://example.test/{page}>; rel=next",
        "</next>; =value",
        "</next>; title=",
        #"</next>; title="unterminated"#,
        "</next>; rel=next trailing",
    ])
    func `Malformed fields throw typed errors`(_ value: String) throws {
        #expect(throws: RFC_8288.Link.Parse.Error.self) {
            _ = try parse(value)
        }
    }

    private func parse(_ rawValue: String) throws -> [RFC_8288.Link] {
        try RFC_8288.Link.Parse()(RFC_9110.Header.Field.Value(rawValue))
    }
}
