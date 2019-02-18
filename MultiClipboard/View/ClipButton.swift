import UIKit

class ClipButton: UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //-----------------------------------------------------
    enum Style{
        case add
        case check
        case edit
        case rearrange
        case clear
        case sync
        case manu
    }
    var action = {}
    convenience init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, style: Style, action: @escaping ()->()) {
        self.init(frame: CGRect( x: x, y: y, width: width, height: height))
        let l = D.ButtonDiameter
        layer.borderWidth = 1
        layer.cornerRadius = l/2
        setTitleColor(UIColor.black, for: .normal)
        switch(style){
        case .add:
            setTitle("⇩", for: .normal)//✚
            addTarget(self, action: #selector(execute(_:)), for: .touchUpInside)
        case .check:
            setTitle("✓", for: .normal)
            addTarget(self, action: #selector(execute(_:)), for: .touchUpInside)
        case .edit:
            setTitle("✎", for: .normal)
            addTarget(self, action: #selector(execute(_:)), for: .touchUpInside)
        case .rearrange:
            setTitle("☰", for: .normal)
            addTarget(self, action: #selector(execute(_:)), for: .touchUpInside)
        case .clear:
            setTitle("⌧", for: .normal)
            addTarget(self, action: #selector(execute(_:)), for: .touchUpInside)
        case .sync:
            setTitle("⎋", for: .normal)
            addTarget(self, action: #selector(execute(_:)), for: .touchUpInside)
        case .manu:
            setTitle("?", for: .normal)
            addTarget(self, action: #selector(execute(_:)), for: .touchUpInside)
        }
        self.action = action
    }
    @objc func execute(_ sender: Any?){
        action()
    }
}

