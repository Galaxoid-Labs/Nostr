import XCTest
@testable import Nostr
import secp256k1

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
    
    func testCreateAndSignEventThatIsValid() throws {
        let keyPair = try KeyPair(bech32PrivateKey: "nsec1r7uh0ryrf0n7z3l4qumzevw9q2s57us4wzqrendpavtjn7uvy5rs9szssa")
        XCTAssertNotNil(keyPair)
        
        var event = Event(id: nil, pubkey: keyPair.publicKey,
                          createdAt: Timestamp(timestamp: 1711384422),
                          kind: EventKind(id: EventKind.textNote.id), tags: [], content: "Hello this is a new event", sig: nil)
        
        try event.sign(with: keyPair)
        XCTAssertEqual(event.id, "da036de740ac051db00ac323d4ced88722d005c41fe9d43a90abadc8df3b96e1")
        XCTAssertNotEqual(event.sig, "")
        XCTAssertTrue(event.isValid())
    }
    
}
