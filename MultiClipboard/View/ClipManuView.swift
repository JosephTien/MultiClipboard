import UIKit

class ClipManuView: UIView {
    var textview = UITextView()
    var textview2 = UITextView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        textview.frame = self.bounds
        textview.frame.origin = CGPoint(x: 0, y: Dimension.statusBarHeight)
        textview.isEditable = false
        textview.font = UIFont.systemFont(ofSize: 20)
        textview.isSelectable = false
        addSubview(textview)
        textview.text = """
        
        Current clipboard content is revealed
        in the upper space.
        
              : Add current clipboard content
                into the list
              : Edit clipboard
              : Clear clipboard
              : Sync the clipboard
                with the PC Web App
                (http://synclipboard.com)
        
              : Drag to rearrange
              : Delete list item
        
        Press list item to use the content.
        Long press to go to the website
        if the content is a url link.
        
        MultiClipboard support Today Widget.
        In the full mode of Today Widget,
        try to use or switch the content,
        or click the clipboard to open the app.
        """
        textview2.frame = self.bounds
        textview2.frame.origin = CGPoint(x: 0, y: Dimension.statusBarHeight)
        textview2.isEditable = false
        textview2.isSelectable = false
        textview2.font = UIFont.systemFont(ofSize: 20)
        textview2.backgroundColor = UIColor.clear
        addSubview(textview2)
        textview2.text = """

        
        
        
        ⇩

        ✎
        ⌧
        ⎋


        
        ☰
        Ｘ
        """
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
