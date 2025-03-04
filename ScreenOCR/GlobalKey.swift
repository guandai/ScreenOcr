import Carbon
import Cocoa

// Define a typealias for our callback
typealias HotKeyCallback = () -> Void

// Global variable to store our callback
var globalCbFullOcr: HotKeyCallback = {}
var globalCbOpenSetting: HotKeyCallback = {}

var globalCbMap: [String: [String: Any]] = [
    "run": [
        "keyId": UInt32(1001),
        "cb": globalCbFullOcr,
    ],
    "setting": [
        "keyId": UInt32(1002),
        "cb": globalCbOpenSetting,
    ],
]

@_cdecl("globalHotKeyHandler")
func globalHotKeyHandler(
    _ nextHandler: EventHandlerCallRef?,
    _ theEvent: EventRef?,
    _ userData: UnsafeMutableRawPointer?
) -> OSStatus {
    var hkID = EventHotKeyID()
    GetEventParameter(
        theEvent,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hkID)

    if hkID.signature != OSType(1234) {
        print("! not valid signature")
        return errSecParam  // Commonly used OSStatus error for invalid parameters
    }

    if let matchingEntry = globalCbMap.first(where: {
        $0.value["keyId"] as? UInt32 == hkID.id
    }) {
        print("> globalHotKeyHandler Found:", matchingEntry)
        if let callback = matchingEntry.value["cb"] as? HotKeyCallback {
            print("🔥 Executing callback for keyId \(hkID.id)")
            callback()
        } else {
            print("⚠️ Callback not found for keyId \(hkID.id)")
        }
    } else {
        print("❌ globalHotKeyHandler No match found")
    }

    return noErr
}
