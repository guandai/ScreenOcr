import Carbon
import Cocoa

// Define a typealias for our callback
typealias HotKeyCallback = () -> Void

// Global variable to store our callback
var globalCbFullOcr: HotKeyCallback = {}
var globalCbOpenSetting: HotKeyCallback = {}

var globalCallbackMap: [UInt32: HotKeyCallback] = [
    1001: globalCbFullOcr,
    1002: globalCbOpenSetting,
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

    // Compare signature + id:
    if hkID.signature == OSType(1234) {
        print("🔥 Shortcut \(hkID.id) pressed!")
        if let callback = globalCallbackMap[hkID.id] ?? nil {
            callback()  // Unwrapping safely
        }
    }

    return noErr
}
