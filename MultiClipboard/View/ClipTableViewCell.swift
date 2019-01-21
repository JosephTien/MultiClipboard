import UIKit

typealias CTVC = ClipTableViewCell
class ClipTableViewCell: UITableViewCell{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //-----------------------------------------------------
    private static var _img_paste: UIImage? = nil
    private var img_paste: UIImage{
        get{
            if(CTVC._img_paste == nil){
                CTVC._img_paste = UIImage(named: "paste")?.withRenderingMode(.alwaysTemplate)
            }
            return CTVC._img_paste!
        }
    }
    var delegate: ClipDelegate?
    var lbl_text: UILabel? = nil
    var btn_field: UIButton? = nil
    var btn_delete: UIButton? = nil
    var btn_switch: UIButton? = nil
    var btn_add: UIButton? = nil
    func setContentSimple(_ str: String){
        selectionStyle = .none
        //-------------------------------
        btn_delete = UIButton(frame:
            CGRect(
                x: D.space,
                y: D.space + D.cellHeight/2 - D.ButtonDiameter/2,
                width: D.ButtonDiameter,
                height: D.ButtonDiameter
            )
        )
        btn_delete!.setTitle("✖", for: .normal)
        btn_delete!.setTitleColor(UIColor.black, for: .normal)
        btn_delete!.titleLabel?.textAlignment = .center
        btn_delete!.layer.borderWidth = 1
        btn_delete!.layer.cornerRadius = D.ButtonDiameter/2
        btn_delete!.addTarget(self, action: #selector(removeStr(_:)), for: .touchUpInside)
        contentView.addSubview(btn_delete!)
        //-------------------------------
        lbl_text = UILabel(frame:CGRect(
            x: D.space * 2 + D.ButtonDiameter,
            y: D.space,
            width: D.screenWidth - D.space * 4 - D.ButtonDiameter * 2,
            height: D.cellHeight
        ))
        lbl_text!.text = str
        lbl_text!.textAlignment = .center
        contentView.addSubview(lbl_text!)
        //-------------------------------
        let view_border_up = UIView(frame:CGRect(
            x: 0,
            y: -1,//D.cellHeight + D.space + D.space - 1,
            width: D.screenWidth,
            height: 1
        ))
        view_border_up.backgroundColor = UIColor.black
        addSubview(view_border_up)
        //-------------------------------
        let view_border_down = UIView(frame:CGRect(
            x: 0,
            y: D.cellHeight + D.space + D.space - 1,
            width: D.screenWidth,
            height: 1
        ))
        view_border_down.backgroundColor = UIColor.black
        addSubview(view_border_down)
    }
    func setContent(_ str: String){
        let s = D.space
        let w = D.screenWidth
        let h = D.cellHeight
        let l = D.ButtonDiameter
        for v in contentView.subviews{
            v.removeFromSuperview()
        }
        //-------------------------------
        frame = CGRect(
            x: 0,
            y: 0,
            width: w,
            height: h + 2 * s)
        contentView.frame = frame
        contentView.center = center
        selectionStyle = .none
        //-------------------------------
        btn_field = UIButton(frame:
            CGRect(
                x: 0,
                y: 0,
                width: w - 4 * s - 2 * l,
                height: h
            )
        )
        btn_field!.center = contentView.center
        btn_field!.setTitle(str, for: .normal)
        btn_field!.setTitleColor(UIColor.black, for: .normal)
        btn_field!.titleLabel?.textAlignment = .center
        btn_field!.titleLabel?.lineBreakMode = .byTruncatingTail
        //btn_field!.layer.borderWidth = 1
        btn_field!.layer.cornerRadius = h/4
        btn_field!.addTarget(self, action: #selector(useStr(_:)), for: .touchUpInside)
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(goTo(_:)))
        btn_field?.addGestureRecognizer(longGesture)
        contentView.addSubview(btn_field!)
        //-------------------------------
        btn_delete = UIButton(frame:
            CGRect(
                x: s,
                y: s + h/2 - l/2,
                width: l,
                height: l
            )
        )
        btn_delete!.setTitle("✖", for: .normal)
        btn_delete!.setTitleColor(UIColor.black, for: .normal)
        btn_delete!.titleLabel?.textAlignment = .center
        //btn_delete!.layer.borderWidth = 1
        btn_delete!.layer.cornerRadius = l/2
        btn_delete!.addTarget(self, action: #selector(removeStr(_:)), for: .touchUpInside)
        contentView.addSubview(btn_delete!)
        //-------------------------------
        btn_switch = UIButton(frame:
            CGRect(
                x: w - s - l,
                y: s + h/2 - l/2,
                width: l,
                height: l
            )
        )
        btn_switch!.setImage(img_paste, for: .normal)
        btn_switch!.contentVerticalAlignment = .fill
        btn_switch!.contentHorizontalAlignment = .fill
        btn_switch!.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        btn_switch!.tintColor = UIColor.black
        //btn_switch!.layer.borderWidth = 1
        btn_switch!.layer.cornerRadius = l/2
        btn_switch!.addTarget(self, action: #selector(switchStr(_:)), for: .touchUpInside)
        //contentView.addSubview(btn_switch!)\
        //-------------------------------
        let view_border_up = UIView(frame:CGRect(
            x: 0,
            y: -1,//D.cellHeight + D.space + D.space - 1,
            width: D.screenWidth,
            height: 1
        ))
        view_border_up.backgroundColor = UIColor.black
        addSubview(view_border_up)
        //-------------------------------
        let view_border_down = UIView(frame:CGRect(
            x: 0,
            y: D.cellHeight + D.space + D.space - 1,
            width: D.screenWidth,
            height: 1
        ))
        view_border_down.backgroundColor = UIColor.black
        addSubview(view_border_down)
    }
    
    func getText()->String{
        if(lbl_text != nil){
            return lbl_text!.text ?? ""
        }
        else if(btn_field != nil){
            return btn_field!.title(for: .normal)!
        }
        return ""
        
    }
    func setText(_ text: String){
        btn_field!.setTitle(text, for: .normal)
    }
    @objc func useStr(_ sender: Any?) {
        flash(text: "Copied!")
        if let idx = delegate?.getAtCellIdx(view: sender as! UIView){
            delegate?.useCell(at: idx)
        }
    }
    
    @objc func removeStr(_ sender: Any?) {
        if let idx = delegate?.getAtCellIdx(view: sender as! UIView){
            delegate?.removeCell(at: idx)
        }
    }
    @objc func switchStr(_ sender: Any?) {
        if let idx = delegate?.getAtCellIdx(view: sender as! UIView){
            delegate?.switchCell(at: idx)
        }
    }
    @objc func goTo(_ sender: UIGestureRecognizer) {
        if sender.state == .began {
            if let btn = btn_field{
                let urlPath = btn.title(for: .normal) ?? ""
                if let url = URL(string: urlPath){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
}
