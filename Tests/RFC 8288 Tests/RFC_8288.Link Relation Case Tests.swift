import RFC_8288
import RFC_9110
import Testing

@Suite
struct `Link relation case` {
    @Test(arguments: ["Next", "NEXT", "nExT"])
    func `a registered relation type is case-insensitive`(_ rel: String) throws {
        let links = try RFC_8288.Link.Parse()(RFC_9110.Field.Value("<https://a.test/2>; rel=\(rel)"))
        #expect(links.first?.relations == [.next])
    }

    @Test
    func `an extension relation URI still parses`() throws {
        let links = try RFC_8288.Link.Parse()(RFC_9110.Field.Value(#"<https://a.test/2>; rel="https://example.com/rel/Item""#))
        #expect(links.first?.relations.count == 1)
    }

    @Test(arguments: ["N_ext", "Ne/xt", "-next"])
    func `malformed relation types are still refused`(_ rel: String) {
        #expect(throws: RFC_8288.Link.Parse.Error.self) {
            try RFC_8288.Link.Parse()(RFC_9110.Field.Value("<https://a.test/2>; rel=\"\(rel)\""))
        }
    }
}
