import XCTest
import Nostr
import P256K

final class NostrTests: XCTestCase {
    
    func testNewKeyPair() throws {
        let keyPair = try KeyPair()
        XCTAssertNotNil(keyPair)
    }
    
    func testRestoreKeyPairFromNsec() throws {
        let keyPair = try KeyPair(bech32PrivateKey: "nsec1r7uh0ryrf0n7z3l4qumzevw9q2s57us4wzqrendpavtjn7uvy5rs9szssa")
        XCTAssertNotNil(keyPair)
        XCTAssertEqual(keyPair.privateKey, "1fb9778c834be7e147f507362cb1c502a14f721570803ccda1eb1729fb8c2507")
        XCTAssertEqual(keyPair.publicKey, "4b7fef1400aae7011f3121c1cbf63e72ae30ef250e0da169e0fd48427f3fb794")
        XCTAssertEqual(keyPair.bech32PrivateKey, "nsec1r7uh0ryrf0n7z3l4qumzevw9q2s57us4wzqrendpavtjn7uvy5rs9szssa")
        XCTAssertEqual(keyPair.bech32PublicKey, "npub1fdl779qq4tnsz8e3y8quha37w2hrpme9pcx6z60ql4yyylelk72qplz85a")
    }
    
    func testDecodeBech32EncodedNote() throws {
        let hex = try "note17cp3vms0md4qx20rnxpgpm9dpe2d386l30pq68e9nfqeswk2nhasgvrk8y".hexFromBech32(hrp: "note")
        XCTAssertNotNil(hex)
        XCTAssertEqual(hex, "f603166e0fdb6a0329e3998280ecad0e54d89f5f8bc20d1f259a41983aca9dfb")
    }
    
    func testEventIdIsValid() throws {
        let eventJson =
"""
{\"id\":\"f603166e0fdb6a0329e3998280ecad0e54d89f5f8bc20d1f259a41983aca9dfb\",\"pubkey\":\"3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d\",\"created_at\":1711372078,\"kind\":1,\"tags\":[[\"client\",\"gossip\"],[\"p\",\"fd5989ddfadd9e2af6ceb8b63942a9e31b37367e89917931ede3b2ea76823f10\"],[\"e\",\"7eb018629bcea71512ac83a8b5dab73fa0484c395eafeff797ace4ec463fee7f\",\"wss://nostr.wine/\",\"root\"],[\"e\",\"ab1f4ebf1f75c7bdff65e95bbd068775b5623fedf9be1b0903cbc0b47e1d1c4d\",\"wss://nostr.mom/\",\"reply\"]],\"content\":\"Damn, this is frightening.\\n\\nWhy are early 2000s articles flagged as AI?\",\"sig\":\"09c197c5159eeac3213fdadec5245501df617a23a5f9b581db22ee822a10f98509302a50335166bd24f672ec19c945e0048bedf25497e53161b80b9e67a1d941\"}
"""
        guard let data = eventJson.data(using: .utf8) else { return XCTAssert(false, "Unable to encode json string to data") }
        let decoder = JSONDecoder()
        let event = try! decoder.decode(Event.self, from: data)
        XCTAssertTrue(event.hasValidId())
    }
    
    // Signature verification
    func testEventIsValid() throws {
        let eventJson =
"""
{\"id\":\"f603166e0fdb6a0329e3998280ecad0e54d89f5f8bc20d1f259a41983aca9dfb\",\"pubkey\":\"3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d\",\"created_at\":1711372078,\"kind\":1,\"tags\":[[\"client\",\"gossip\"],[\"p\",\"fd5989ddfadd9e2af6ceb8b63942a9e31b37367e89917931ede3b2ea76823f10\"],[\"e\",\"7eb018629bcea71512ac83a8b5dab73fa0484c395eafeff797ace4ec463fee7f\",\"wss://nostr.wine/\",\"root\"],[\"e\",\"ab1f4ebf1f75c7bdff65e95bbd068775b5623fedf9be1b0903cbc0b47e1d1c4d\",\"wss://nostr.mom/\",\"reply\"]],\"content\":\"Damn, this is frightening.\\n\\nWhy are early 2000s articles flagged as AI?\",\"sig\":\"09c197c5159eeac3213fdadec5245501df617a23a5f9b581db22ee822a10f98509302a50335166bd24f672ec19c945e0048bedf25497e53161b80b9e67a1d941\"}
"""
        guard let data = eventJson.data(using: .utf8) else { return XCTAssert(false, "Unable to encode json string to data") }
        let decoder = JSONDecoder()
        let event = try! decoder.decode(Event.self, from: data)
        XCTAssertTrue(event.isValid())
    }
    
    func testCreateAndSignEventThatIsValid() throws {
        let keyPair = try KeyPair(bech32PrivateKey: "nsec1r7uh0ryrf0n7z3l4qumzevw9q2s57us4wzqrendpavtjn7uvy5rs9szssa")
        XCTAssertNotNil(keyPair)
        
        var event = Event(id: nil, pubkey: keyPair.publicKey,
                          createdAt: Timestamp(timestamp: 1711384422),
                          kind: Kind(id: Kind.textNote.id), tags: [], content: "Hello this is a new event", sig: nil)
        
        try event.sign(with: keyPair)
        XCTAssertEqual(event.id, "da036de740ac051db00ac323d4ced88722d005c41fe9d43a90abadc8df3b96e1")
        XCTAssertNotEqual(event.sig, "")
        XCTAssertTrue(event.isValid())
    }
    
    func testGeneratePOWKeyPair() async throws {
        try await KeyPair.benchMarkCore()
        if let keyPair = try await KeyPair.newLeadingZeroBitKey(withMinimumLeadingZeroBits: 16) {
            print(keyPair.leadingZeroBits)
            XCTAssertNotNil(keyPair)
            XCTAssertTrue(keyPair.leadingZeroBits >= 16)
            print("Public Key  => " + keyPair.publicKey)
            print("Private Key => " + keyPair.privateKey)
            print("NPUB        => " + keyPair.bech32PublicKey)
            print("NSEC        => " + keyPair.bech32PrivateKey)
        } else {
            XCTAssert(false, "")
        }
    }
    
    func testVanityHexPrefixKeyPair() async throws {
        try await KeyPair.benchMarkCore()
        let prefix = "dead"
        if let keyPair = try await KeyPair.newVanityHexKey(leadingHexPrefix: prefix) {
            XCTAssertNotNil(keyPair)
            XCTAssertTrue(keyPair.publicKey.hasPrefix(prefix))
            print("Public Key  => " + keyPair.publicKey)
            print("Private Key => " + keyPair.privateKey)
            print("NPUB        => " + keyPair.bech32PublicKey)
            print("NSEC        => " + keyPair.bech32PrivateKey)
        } else {
            XCTAssert(false, "")
        }
    }
    
    func testVanityHexSuffixKeyPair() async throws {
        try await KeyPair.benchMarkCore()
        let suffix = "dead"
        if let keyPair = try await KeyPair.newVanityHexKey(trailingHexSuffix: suffix) {
            XCTAssertNotNil(keyPair)
            XCTAssertTrue(keyPair.publicKey.hasSuffix(suffix))
            print("Public Key  => " + keyPair.publicKey)
            print("Private Key => " + keyPair.privateKey)
            print("NPUB        => " + keyPair.bech32PublicKey)
            print("NSEC        => " + keyPair.bech32PrivateKey)
        } else {
            XCTAssert(false, "")
        }
    }
    
    func testVanityBech32PrefixKeyPair() async throws {
        try await KeyPair.benchMarkCoreWithBech32()
        let prefix = "dead"
        if let keyPair = try await KeyPair.newVanityBech32Key(leadingBech32Prefix: prefix) {
            XCTAssertNotNil(keyPair)
            XCTAssertTrue(keyPair.bech32PublicKey.hasPrefix("npub1"+prefix))
            print("Public Key  => " + keyPair.publicKey)
            print("Private Key => " + keyPair.privateKey)
            print("NPUB        => " + keyPair.bech32PublicKey)
            print("NSEC        => " + keyPair.bech32PrivateKey)
        } else {
            XCTAssert(false, "")
        }
    }
    
    func testVanityBech32SuffixKeyPair() async throws {
        try await KeyPair.benchMarkCoreWithBech32()
        let suffix = "dead"
        if let keyPair = try await KeyPair.newVanityBech32Key(trailingBech32Suffix: suffix) {
            XCTAssertNotNil(keyPair)
            XCTAssertTrue(keyPair.bech32PublicKey.hasSuffix(suffix))
            print("Public Key  => " + keyPair.publicKey)
            print("Private Key => " + keyPair.privateKey)
            print("NPUB        => " + keyPair.bech32PublicKey)
            print("NSEC        => " + keyPair.bech32PrivateKey)
        } else {
            XCTAssert(false, "")
        }
    }
    
    func testEncodeNote() async {
        let id = "f603166e0fdb6a0329e3998280ecad0e54d89f5f8bc20d1f259a41983aca9dfb"
        if let encoded = try? encodeNote(withId: id) {
            XCTAssertEqual(encoded, "note17cp3vms0md4qx20rnxpgpm9dpe2d386l30pq68e9nfqeswk2nhasgvrk8y")
        } else {
            XCTAssert(false, "")
        }
    }
    
    func testDecodeNote() async {
        let id = "note17cp3vms0md4qx20rnxpgpm9dpe2d386l30pq68e9nfqeswk2nhasgvrk8y"
        if let decoded = try? decodeNote(id) {
            XCTAssertEqual(decoded, "f603166e0fdb6a0329e3998280ecad0e54d89f5f8bc20d1f259a41983aca9dfb")
        } else {
            XCTAssert(false, "")
        }
    }
    
    func testDecodeNProfile() async {
        let profile = "nprofile1qqsrhuxx8l9ex335q7he0f09aej04zpazpl0ne2cgukyawd24mayt8gpp4mhxue69uhhytnc9e3k7mgpz4mhxue69uhkg6nzv9ejuumpv34kytnrdaksjlyr9p"
        if let decoded = try? profile.decodeNProfile() {
            XCTAssertEqual(decoded.publicKey, "3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d")
            XCTAssertEqual(decoded.relays, ["wss://r.x.com", "wss://djbas.sadkb.com"])
        } else {
            XCTAssert(false, "")
        }
    }
    
    func testDecodeNEvent() async {
        let nevent = "nevent1qqsxxr5klnl7uxxhrxl0lgvsf8m27ft8dk00kcuzakfxeyvutd6ja0cprfmhxue69uhhyetvv9ujuam9wd6x2unwvf6xxtnrdaksyg8yvswsamt36tgvpa5v6dgg658umvv4ftquek3xnhdm0fuf0s3xzsa845wv"
        if let decoded = try? nevent.decodeNEvent() {
            print(decoded)
            XCTAssertEqual(decoded.id, "630e96fcffee18d719beffa19049f6af25676d9efb6382ed926c919c5b752ebf")
            XCTAssertEqual(decoded.author, "e4641d0eed71d2d0c0f68cd3508d50fcdb1954ac1ccda269ddbb7a7897c22614")
            XCTAssertEqual(decoded.relays, ["wss://relay.westernbtc.com"])
        } else {
            XCTAssert(false, "")
        }
    }
    
    func testDecodeNAddr() async {
        let naddr = "naddr1qqrxyctwv9hxzqfwwaehxw309aex2mrp0yhxummnw3ezuetcv9khqmr99ekhjer0d4skjm3wv4uxzmtsd3jjucm0d5q3vamnwvaz7tmwdaehgu3wvfskuctwvyhxxmmdqgsrhuxx8l9ex335q7he0f09aej04zpazpl0ne2cgukyawd24mayt8grqsqqqa28a3lkds"
        if let decoded = try? naddr.decodeNAddr() {
            print(decoded)
            XCTAssertEqual(decoded.publicKey, "3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d")
            XCTAssertEqual(decoded.identifier, "banana")
            XCTAssertEqual(decoded.kind, 30023)
            XCTAssertEqual(decoded.relays, ["wss://relay.nostr.example.mydomain.example.com", "wss://nostr.banana.com"])
        } else {
            XCTAssert(false, "")
        }
    }
    
    func testEncodeNEvent() async {
        let id = "45326f5d6962ab1e3cd424e758c3002b8665f7b0d8dcee9fe9e288d7751ac194"
        let relays = ["wss://banana.com"]
        let author = "7fa56f5d6962ab1e3cd424e758c3002b8665f7b0d8dcee9fe9e288d7751abb88"
        if let encoded = try? encodeNEvent(withId: id, author: author, relays: relays) {
            XCTAssertEqual(encoded, "nevent1qqsy2vn0t45k92c78n2zfe6ccvqzhpn977cd3h8wnl579zxhw5dvr9qpzpmhxue69uhkyctwv9hxztnrdaksygrl54h466tz4v0re4pyuavvxqptsejl0vxcmnhfl60z3rth2x4m3q04ndyp")
        } else {
            XCTAssert(false, "")
        }
    }
    
    func testEncodeNProfile() async {
        let relays = ["wss://r.x.com", "wss://djbas.sadkb.com"]
        let author = "3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d"
        if let encoded = try? encodeNProfile(publicKey: author, relays: relays) {
            XCTAssertEqual(encoded, "nprofile1qqsrhuxx8l9ex335q7he0f09aej04zpazpl0ne2cgukyawd24mayt8gpp4mhxue69uhhytnc9e3k7mgpz4mhxue69uhkg6nzv9ejuumpv34kytnrdaksjlyr9p")
        } else {
            XCTAssert(false, "")
        }
    }
    
    func testEncodeNAddr() async {
        let author = "3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d"
        let relays = ["wss://relay.nostr.example.mydomain.example.com", "wss://nostr.banana.com"]
        let kind: UInt32 = 30023
        let identifier = "banana"
        if let encoded = try? encodeNAddr(publicKey: author, relays: relays, identifier: identifier, kind: kind) {
            XCTAssertEqual(encoded, "naddr1qqrxyctwv9hxzqfwwaehxw309aex2mrp0yhxummnw3ezuetcv9khqmr99ekhjer0d4skjm3wv4uxzmtsd3jjucm0d5q3vamnwvaz7tmwdaehgu3wvfskuctwvyhxxmmdqgsrhuxx8l9ex335q7he0f09aej04zpazpl0ne2cgukyawd24mayt8grqsqqqa28a3lkds")
        } else {
            XCTAssert(false, "")
        }
    }
    
}
