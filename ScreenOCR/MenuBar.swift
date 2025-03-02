import Cocoa
import Carbon


func registerGlobalShortcut() {
    NSLog("🔄 Registering global hotkey Ctrl + Cmd + Shift + 6")

    let keyCode: UInt32 = UInt32(kVK_ANSI_6)  // Key "6"
    let modifierFlags: UInt32 = UInt32(cmdKey | shiftKey | controlKey) // Ctrl + Cmd + Shift

    let hotKeyID = EventHotKeyID(signature: OSType(1234), id: 1)
    var hotKeyRef: EventHotKeyRef?

    let eventHandler: EventHandlerUPP = { (nextHandler, theEvent, userData) -> OSStatus in
        var hotKeyID = EventHotKeyID()
        GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout.size(ofValue: hotKeyID), nil, &hotKeyID)

        if hotKeyID.id == 1 {
            NSLog("🚀 Hotkey Ctrl + Cmd + Shift + 6 pressed!")
            print("🚀 Hotkey Ctrl + Cmd + Shift + 6 pressed!")
        }
        return noErr
    }

    let eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
    InstallEventHandler(GetApplicationEventTarget(), eventHandler, 1, [eventType], nil, nil)

    let status = RegisterEventHotKey(keyCode, modifierFlags, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    
    if status == noErr {
        NSLog("✅ Hotkey registered successfully")
        print("✅ Hotkey registered successfully")
    } else {
        NSLog("❌ Failed to register hotkey. Error code: \(status)")
        print("❌ Failed to register hotkey. Error code: \(status)")
    }
}
