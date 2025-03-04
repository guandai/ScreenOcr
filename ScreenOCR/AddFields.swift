import Cocoa

let btnW = 140
let btnH = 24

var change_btn_y = 80;
var change_tf_y = 80;
let y_offset = 40;

typealias Fn = () -> Void

// Helper class to handle closure-based action
class BtnWrapper: NSObject {
    let action: () -> Void
    init(action: @escaping () -> Void) {
        self.action = action
    }
    @objc func invoke() { action() }
}

class AddFields {
    var rs: RegisterShortcut
    var cbMap: CbMap

    init(rs: RegisterShortcut, cbMap: CbMap) {
        self.rs = rs
        self.cbMap = cbMap
    }
    
    func addBtn (cv: NSView, title: String, action: @escaping Fn, wraps: inout [BtnWrapper],  x: Int, y: Int, w: Int = btnW, h: Int = btnH ) {
        let actionWrapper = BtnWrapper(action: action)
        wraps.append(actionWrapper)

        let btn = NSButton()
        btn.title = title
        btn.bezelStyle = .rounded
        btn.frame = NSRect(x: x, y: y, width: w, height: h)
        btn.target = actionWrapper
        btn.action = #selector(BtnWrapper.invoke)
        cv.addSubview(btn)
    }
    
    func addChangeKey(cv: NSView, keyName: String, title: String, wraps: inout [BtnWrapper]) {
        let tf = NSTextField()
        // Text field for new hotKeyID combination
        tf.frame = NSRect(x: 20, y: change_tf_y, width: 200, height: 24)
        tf.placeholderString = "cmd+shift+..."
        cv.addSubview(tf)
        
        let action: () -> Void = {
            let uhk = UpdateHotKey(rs: self.rs, cbMap: self.cbMap)
            uhk.updateHotKey(keyName: keyName, tf: tf)
        }
        addBtn(cv: cv, title: title, action: action, wraps: &wraps, x: 230, y: change_btn_y)
        change_btn_y += y_offset
        change_tf_y += y_offset
    }
}



func debugCallback(_ callback: Any) {
    let mirror = Mirror(reflecting: callback)
    print("x Type: \(mirror.subjectType)")
    print("x Children: \(mirror.children)")
    print("x Description: \(String(describing: callback))")
}
