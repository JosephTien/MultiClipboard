import UIKit

class ClipTableView: UITableView{
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(
            frame: CGRect( x: x, y: y, width: width, height: height),
            style: .plain
        )
        rowHeight = D.cellHeight + 2 * D.space
    }
    //-----------------------------------------------------
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        separatorStyle = .none
    }
}
