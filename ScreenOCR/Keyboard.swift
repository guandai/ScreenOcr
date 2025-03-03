import Carbon
import Cocoa

// Define a typealias for our callback
typealias HotKeyCallback = () -> Void

// Global variable to store our callback
var globalCbFullOcr: HotKeyCallback = {}
var globalCbOpenSetting: HotKeyCallback = {}

var globalCallbackMap: [UInt32: HotKeyCallback] = [
  1001: globalCbFullOcr,
  1002: globalCbOpenSetting
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


class RegisterShortcut {
  func setHotKeyCallback(hkID: UInt32, callback: @escaping HotKeyCallback) {
    print("🔥 Global hotkey triggered: executing screenshot capture!")
    globalCallbackMap[hkID] = callback
  }

  func registerGlobalHotKey(
    key: String,
    modifiers: [String],
    callback: @escaping HotKeyCallback,
    hotKeyIDNumber: UInt32,
    signature: OSType = OSType(1234)
  ) {
    // Find the key code
    guard let keyCode = keyCodeMap[key.uppercased()] else {
      print("❌ registerGlobalHotKey: Unrecognized key '\(key)'")
      return
    }

    // Set Callback
    setHotKeyCallback(hkID: hotKeyIDNumber, callback: callback)
    
    // Build Carbon modifier flags
    let carbonFlags = carbonModifiers(forModifiers: modifiers)

    // Create the hotkey identifier
    let hotKeyID = EventHotKeyID(signature: signature, id: hotKeyIDNumber)

    // The reference that macOS gives us
    var hotKeyRef: EventHotKeyRef?

    // The event types we care about (a pressed hotkey)
    let eventType = EventTypeSpec(
      eventClass: OSType(kEventClassKeyboard),
      eventKind: OSType(kEventHotKeyPressed)
    )
    print(6)
    // Install our globalHotKeyHandler function pointer
    //    Instead of an inline Swift closure.
    InstallEventHandler(
      GetApplicationEventTarget(),
      globalHotKeyHandler,  // <--- Pass the top-level function
      1,
      [eventType],
      nil,  // userData, if you want to pass something in
      nil
    )

    // 7. Finally register the hotkey
    let status = RegisterEventHotKey(
      keyCode, carbonFlags, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)

    if status == noErr {
      print(11)
      print("✅ Registered hotkey: \(modifiers)+\(key) (id=\(hotKeyIDNumber), sig=\(signature))")
    } else {
      print("❌ Failed to register hotkey. Error code: \(status)")
    }
  }

  /// Unregister a global hotkey by ID
  func unregisterGlobalHotKey(_ hotKeyIDNumber: UInt32) {
        if let hotKeyRef = hotKeyRefs[hotKeyIDNumber] {
            let status = UnregisterEventHotKey(hotKeyRef)
            if status == noErr {
                print("✅ Unregistered hotkey with ID: \(hotKeyIDNumber)")
                hotKeyRefs.removeValue(forKey: hotKeyIDNumber)  // Remove from dictionary
            } else {
                print("❌ Failed to unregister hotkey with ID: \(hotKeyIDNumber). Error code: \(status)")
            }
        } else {
            print("⚠️ No hotkey found with ID: \(hotKeyIDNumber)")
        }
  }
  
    
}
