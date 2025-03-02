import Cocoa
import Carbon

@_cdecl("globalHotKeyHandler")
func globalHotKeyHandler(
    _ nextHandler: EventHandlerCallRef?,
    _ theEvent: EventRef?,
    _ userData: UnsafeMutableRawPointer?
) -> OSStatus {

    var hkID = EventHotKeyID()
    GetEventParameter(theEvent,
                      EventParamName(kEventParamDirectObject),
                      EventParamType(typeEventHotKeyID),
                      nil,
                      MemoryLayout<EventHotKeyID>.size,
                      nil,
                      &hkID)

    // Compare signature + id:
    if hkID.signature == OSType(1234) && hkID.id == 1 {
        print("🔥 Shortcut #1 pressed!")
        // ...
    } else if hkID.signature == OSType(1234) && hkID.id == 2 {
        print("🔥 Shortcut #2 pressed!")
        // ...
    }

    return noErr
}


func registerGlobalHotKey(
    key: String,
    modifiers: [String],
    hotKeyIDNumber: UInt32 = 1,
    signature: OSType = OSType(1234)
) {
    // 1. Find the key code
    guard let keyCode = keyCodeMap[key.uppercased()] else {
        print("❌ registerGlobalHotKey: Unrecognized key '\(key)'")
        return
    }

    print(1)
    // 2. Build Carbon modifier flags
    let carbonFlags = carbonModifiers(forModifiers: modifiers)

    // 3. Create the hotkey identifier
    let hotKeyID = EventHotKeyID(signature: signature, id: hotKeyIDNumber)

    // 4. The reference that macOS gives us
    var hotKeyRef: EventHotKeyRef?

    // 5. The event types we care about (a pressed hotkey)
    let eventType = EventTypeSpec(
        eventClass: OSType(kEventClassKeyboard),
        eventKind:  OSType(kEventHotKeyPressed)
    )
    print(6)
    // 6. Install our globalHotKeyHandler function pointer
    //    Instead of an inline Swift closure.
    InstallEventHandler(
        GetApplicationEventTarget(),
        globalHotKeyHandler,  // <--- Pass the top-level function
        1,
        [eventType],
        nil,      // userData, if you want to pass something in
        nil
    )

    // 7. Finally register the hotkey
    let status = RegisterEventHotKey(keyCode, carbonFlags, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)

    if status == noErr {
        print(11)
        print("✅ Registered hotkey: \(modifiers)+\(key) (id=\(hotKeyIDNumber), sig=\(signature))")
    } else {
        print("❌ Failed to register hotkey. Error code: \(status)")
    }
}


func carbonModifiers(forModifiers modifiers: [String]) -> UInt32 {
    var carbonFlags: UInt32 = 0

    for mod in modifiers {
        switch mod.lowercased() {
        case "cmd":
            carbonFlags |= UInt32(cmdKey)
        case "shift":
            carbonFlags |= UInt32(shiftKey)
        case "ctrl", "control":
            carbonFlags |= UInt32(controlKey)
        case "alt", "option":
            carbonFlags |= UInt32(optionKey)
        default:
            break
        }
    }
    return carbonFlags
}




/// Common ASCII keys mapped to their Carbon key codes
let keyCodeMap: [String: UInt32] = [
    "A": UInt32(kVK_ANSI_A),
    "B": UInt32(kVK_ANSI_B),
    "C": UInt32(kVK_ANSI_C),
    "D": UInt32(kVK_ANSI_D),
    "E": UInt32(kVK_ANSI_E),
    "F": UInt32(kVK_ANSI_F),
    "G": UInt32(kVK_ANSI_G),
    "H": UInt32(kVK_ANSI_H),
    "I": UInt32(kVK_ANSI_I),
    "J": UInt32(kVK_ANSI_J),
    "K": UInt32(kVK_ANSI_K),
    "L": UInt32(kVK_ANSI_L),
    "M": UInt32(kVK_ANSI_M),
    "N": UInt32(kVK_ANSI_N),
    "O": UInt32(kVK_ANSI_O),
    "P": UInt32(kVK_ANSI_P),
    "Q": UInt32(kVK_ANSI_Q),
    "R": UInt32(kVK_ANSI_R),
    "S": UInt32(kVK_ANSI_S),
    "T": UInt32(kVK_ANSI_T),
    "U": UInt32(kVK_ANSI_U),
    "V": UInt32(kVK_ANSI_V),
    "W": UInt32(kVK_ANSI_W),
    "X": UInt32(kVK_ANSI_X),
    "Y": UInt32(kVK_ANSI_Y),
    "Z": UInt32(kVK_ANSI_Z),

    "0": UInt32(kVK_ANSI_0),
    "1": UInt32(kVK_ANSI_1),
    "2": UInt32(kVK_ANSI_2),
    "3": UInt32(kVK_ANSI_3),
    "4": UInt32(kVK_ANSI_4),
    "5": UInt32(kVK_ANSI_5),
    "6": UInt32(kVK_ANSI_6),
    "7": UInt32(kVK_ANSI_7),
    "8": UInt32(kVK_ANSI_8),
    "9": UInt32(kVK_ANSI_9),

    // You could also add punctuation or special keys if desired:
    // "-", "=", "[", "]", "\\", ";", "'", ",", ".", "/", ...
]
