import UIKit

class ClipTextView: UITextView{
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(
            frame: CGRect( x: x, y: y, width: width, height: height),
            textContainer: nil
        )
        text = VC.clipBoardText
        textAlignment = .center
        font = UIFont.systemFont(ofSize: 17)
        //layer.borderWidth = 1
        //layer.cornerRadius = D.cornerRadius
        //cornerRadiusWithBorder(corners: [.topRight, .topLeft], radii: D.cornerRadius)
        contentInset = UIEdgeInsets(
            top: D.space,
            left: D.space,
            bottom: D.space,
            right: D.space
        )
        isEditable = false
        
    }
    
}
