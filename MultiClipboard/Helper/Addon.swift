import UIKit

extension UIView{
    func hide(){
        self.isHidden = true
    }
    func show(){
        self.isHidden = false
    }
    func flash(text: String){
        flash(
            text: text,
            textColor: UIColor.white,
            backgroundColor: UIColor.black,
            duration: 0.5,
            complete: {}
        )
    }
    func flash(
        text: String,
        textColor: UIColor,
        backgroundColor: UIColor,
        duration: TimeInterval,
        complete: @escaping ()->()
        
        ){
        let lbl = UILabel(frame: self.bounds)
        lbl.text = text
        lbl.textColor = textColor
        lbl.textAlignment = .center
        lbl.backgroundColor = backgroundColor
        lbl.layer.cornerRadius = self.layer.cornerRadius
        lbl.alpha = 1
        self.addSubview(lbl)
        UIView.animate(withDuration: duration, animations: {
            lbl.alpha = 0
        }){_ in
            lbl.removeFromSuperview()
            complete()
        }
    }
    
    func cornerRadius(usingCorners corners: UIRectCorner, cornerRadii: CGSize)
    {
        let path = UIBezierPath(roundedRect: self.bounds,
        byRoundingCorners: corners,
        cornerRadii: cornerRadii)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    
    func cornerRadiusWithBorder(corners: UIRectCorner, radii: CGFloat){
        cornerRadiusWithBorder(
            usingCorners: corners,
            cornerRadii: CGSize(width: radii, height: radii),
            width: 2,
            color: UIColor.black.cgColor
        )
    }
    
    func cornerRadiusWithBorder(usingCorners corners: UIRectCorner, cornerRadii: CGSize, width: CGFloat, color: CGColor){
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: cornerRadii)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
        
        let frameLayer = CAShapeLayer()
        frameLayer.path = path.cgPath
        frameLayer.lineWidth = width
        frameLayer.strokeColor = color
        frameLayer.fillColor = nil
        
        for sublayer in layer.sublayers ?? []{
            sublayer.removeFromSuperlayer()
        }
        layer.addSublayer(frameLayer)
        
    }
    
}

extension UIButton{
    var text: String?{
        get{
            return title(for: .normal)
        }
        set{
            setTitle(newValue, for: .normal)
        }
    }
}

public extension UITableView {
    func indexPathForView(_ view: UIView) -> IndexPath? {
        let center = view.center
        let viewCenter = self.convert(center, from: view.superview)
        let indexPath = self.indexPathForRow(at: viewCenter)
        return indexPath
    }
}
