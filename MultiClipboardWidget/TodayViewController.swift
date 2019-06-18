import UIKit
import NotificationCenter

class Storage{
    static var strs: [String] = []
    static var userDefaults: UserDefaults?{
        get{
            return UserDefaults(suiteName: "group.com.jtien.clipboard")
        }
    }
    static func saveToShare(){
        strs = strs.filter{
            str in str != ""
        }
        userDefaults!.set(strs, forKey: "strs")
    }
    static func readItemsFromShare(){
        if let _strs = userDefaults!.array(forKey: "strs"){
            strs = _strs as! [String]
        }
    }
}
//**************************************************************
class TodayViewController: UIViewController, NCWidgetProviding {
    var simpleMode = true
    var btns_field: [UIButton] = []
    var lbl_current = UITextView()
    var btn_current = UIButton()
    var samp_btn_field = UIButton()
    var samp_btn_paste = UIButton()
    var cover = UILabel()
    let color = UIColor.black
    var pickedIdx = -1
    let minrownum = 4
    let maxrownum = 7
    let f = CGFloat(8)
    var h = CGFloat(33)
    var _w = 0
    var clipBoardText: String?{
        get{
            return UIPasteboard.general.string
        }
        set{
            UIPasteboard.general.string = newValue
        }
    }
    var w: CGFloat{
        get{
            return CGFloat(_w)
        }
        set{
            _w = Int(newValue)
        }
    }
    var rownum: Int{
        get{
            var n = Storage.strs.count
            n =  n > maxrownum ? maxrownum : n
            return n < minrownum ? minrownum : n
        }
    }
    var dataChanged: Bool{
        get{
            if(Storage.strs.count < minrownum){
                return minrownum == btns_field.count
            }else if(Storage.strs.count > maxrownum){
                return maxrownum == btns_field.count
            }else{
                return btns_field.count != Storage.strs.count
            }
        }
    }
    func getStr(_ idx: Int)->String{
        if idx < Storage.strs.count{
            return Storage.strs[idx]
        }
        return ""
    }
    func getText(_ idx: Int)->String{
        if idx < btns_field.count{
            return btns_field[idx].title(for: .normal)!
        }
        return ""
    }
    // MARK: - Init Content
    func initSample(){
        samp_btn_field.setTitleColor(color, for: .normal)
        samp_btn_field.addTarget(self, action: #selector(pasteItem(_:)), for: .touchUpInside)
        samp_btn_field.titleEdgeInsets.left = f
        samp_btn_field.titleEdgeInsets.right = f
        samp_btn_field.titleLabel?.lineBreakMode = .byTruncatingTail
        //----------------------------------
        samp_btn_paste.setImage(UIImage(named: "paste")?.withRenderingMode(.alwaysTemplate), for: .normal)
        samp_btn_paste.contentVerticalAlignment = .fill
        samp_btn_paste.contentHorizontalAlignment = .fill
        samp_btn_paste.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        samp_btn_paste.tintColor = color
        samp_btn_paste.setTitleColor(color, for: .normal)
        samp_btn_paste.addTarget(self, action: #selector(pasteItem(_:)), for: .touchUpInside)
    }
    func initCurrentLabel(){
        lbl_current.frame = CGRect(
            x: f,
            y: f,
            width: w-f*2-f-h,
            height: h
        )
        view.addSubview(lbl_current)
        lbl_current.text = clipBoardText
        lbl_current.backgroundColor = nil
        lbl_current.textAlignment = .center
        lbl_current.textColor = color
        lbl_current.font = UIFont.systemFont(ofSize: 17)
        lbl_current.setBoarder(color.cgColor, h/4)
        lbl_current.isHidden = simpleMode
        lbl_current.picked(true)
        lbl_current.textContainerInset.left = f
        lbl_current.textContainerInset.right = f
        lbl_current.textContainer.maximumNumberOfLines = 1
        lbl_current.textContainer.lineBreakMode = .byTruncatingTail
        lbl_current.isEditable = false
        btn_current.frame = CGRect(
            x: f,
            y: f,
            width: w-f*2-f-h,
            height: h
        )
        btn_current.addTarget(self, action: #selector(openApp(_:)), for: .touchUpInside)
        view.addSubview(btn_current)
    }
    func initItems(){
        clear()
        initCurrentLabel()
        for _ in 0..<rownum{
            addItem(str: "")
        }
    }
    func addItem(str: String){
        let idx = btns_field.count
        let container: UIView = UIView()
        view.addSubview(container)
        //-----------------------------------------
        let btn_field = samp_btn_field.duplicate(forControlEvents: [.touchUpInside])!
        btn_field.setBoarder(color.cgColor, h/4)
        btn_field.tag = -1 * (idx+1)
        btns_field.append(btn_field)
        container.addSubview(btn_field)
        //-----------------------------------------
        let btn_paste = samp_btn_paste.duplicate(forControlEvents: [.touchUpInside])!
        btn_paste.setBoarder(color.cgColor, h/4)
        btn_paste.tag = idx
        container.addSubview(btn_paste)
        //-----------------------------------------
    }
    func clear(){
        for v in view.subviews{
            v.removeFromSuperview()
        }
        btns_field.removeAll()
    }
    // MARK: - Set Content
    func setItems(){
        if(dataChanged){
            initItems()
        }
        for idx in 0..<btns_field.count{
            setItem(idx: idx, str: getStr(idx))
        }
        lbl_current.isHidden = simpleMode
        btn_current.isHidden = simpleMode
    }
    func setItem(idx: Int, str: String){
        let i = CGFloat(idx+1)
        let container: UIView = btns_field[idx].superview!
        let btn_field = container.subviews[0] as! UIButton
        let btn_paste = container.subviews[1] as! UIButton
        if(simpleMode){
            let i_mod = (idx)%2
            let i_div = floor(CGFloat((idx)/2))
            container.frame = CGRect(
                x: (i_mod == 0 ? f : w/2+f/2),
                y: f+(h+f)*i_div,
                width: w/2-f/2*3,
                height: h
            )
            btn_field.frame = CGRect(
                x: 0,
                y: 0,
                width: container.frame.width,
                height: h
            )
            btn_field.setTitle(str, for: .normal)
            btn_paste.isHidden = true
        }else{
            container.frame = CGRect(
                x: f,
                y: f+(h+f)*i,
                width: w-f*2,
                height: h
            )
            btn_field.frame = CGRect(
                x: 0,
                y: 0,
                width: container.frame.width-f-h,
                height: h
            )
            btn_field.setTitle(str, for: .normal)
            btn_paste.frame = CGRect(
                x: container.frame.width-h,
                y: 0,
                width: h,
                height: h
            )
            btn_paste.isHidden = false
        }
    }
    func refresh(){
        load()
        setItems()
        initCurrentLabel()
        checkMatch()
    }
    // MARK: - View & Data
    func hint(_ str: String){
        cover.text = str
        cover.textColor = UIColor.white
        cover.backgroundColor = color
        cover.alpha = 1
        cover.textAlignment = .center
        view.addSubview(cover)
        view.bringSubviewToFront(cover)
        UIView.animate(withDuration: 0.5, animations: {
            self.cover.alpha = 0
        }){ _ in
            
        }
    }
    func checkMatch(){
        if(!simpleMode){
            clearPicked()
            return
        }
        if(pickedIdx>0){
            if(clipBoardText != btns_field[pickedIdx].title(for: .normal)){
                clearPicked()
            }else{
                return
            }
        }
        var found = false
        for (idx, btn) in btns_field.enumerated(){
            if (!found && btn.title(for: .normal) == clipBoardText){
                btn.picked(true)
                pickedIdx = idx
                found = true
            }else{
                btn.picked(false)
            }
        }
    }
    func clearPicked(){
        pickedIdx = -1
        for btn in btns_field{
            btn.picked(false)
        }
    }
    func save(){
        Storage.strs = []
        for btn in btns_field{
            Storage.strs.append(btn.title(for: .normal)!)
        }
        Storage.saveToShare()
    }
    func load(){
        Storage.readItemsFromShare()
    }
    // MARK: - Signal
    @objc func openApp(_ sender: Any?) {
        let url = URL(string: "MultiClipboard://")!
        self.extensionContext?.open(url, completionHandler: nil)
    }
    
    @objc func pasteItem(_ sender: Any?) {
        let btn = sender as! UIButton
        var idx = btn.tag
        if idx<0{
            idx = -idx-1
            clipBoardText = btn.title(for: .normal)
            lbl_current.text = clipBoardText
            for btn in btns_field{
                btn.picked(false)
            }
            if(simpleMode){
                btn.picked(true)
            }
            //btn.trigger()
            btn.hint("Copied!")
            pickedIdx = idx
        }else{
            if(idx == pickedIdx && getText(idx) == clipBoardText){}
            let temp = getText(idx)
            btns_field[idx].setTitle(clipBoardText, for: .normal)
            /*
            for i in (0...idx).reversed(){
                if(i<1){break}
                btns_field[i].setTitle(btns_field[i-1].title(for: .normal), for: .normal)
            }
            btns_field[0].setTitle(clipBoardText, for: .normal)
             */
            clipBoardText = temp
            lbl_current.text = clipBoardText
            if(pickedIdx>=0){
                //btns_field[pickedIdx].setTitle(lbl_current.text, for: .normal)
            }
            save()
            btns_field[idx].hint("Switched!")
            lbl_current.hint("Switched!")
        }
    }
    // MARK: - Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        // Do any additional setup after loading the view from its nib.
        load()
        initSample()
        initItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            h = CGFloat(33)
            simpleMode = false
            self.preferredContentSize = CGSize(width: maxSize.width, height: (h+f)*CGFloat(rownum+1)+f)
        }else{
            //h = CGFloat(44)
            h = (maxSize.height - 3*f) / CGFloat(2)
            self.preferredContentSize = CGSize(width: maxSize.width, height: 2*h + 3*f)
            simpleMode = true
        }
        //--------------------------------------------
        w = maxSize.width
        cover.frame.size = self.preferredContentSize
        refresh()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        completionHandler(NCUpdateResult.newData)
    }
    
}

extension UIView {
    func setBoarder(_ color: CGColor, _ radius: CGFloat){
        layer.borderWidth = 1
        layer.borderColor = color
        layer.cornerRadius = radius
    }
    
    func hint(_ str: String){
        let cover = UILabel(frame: frame)
        cover.frame.origin = CGPoint(x: 0, y: 0)
        cover.text = str
        cover.textAlignment = .center
        cover.textColor = UIColor.white
        cover.layer.backgroundColor = UIColor.black.cgColor
        cover.layer.cornerRadius = layer.cornerRadius
        cover.alpha = 1
        addSubview(cover)
        UIView.animate(withDuration: 0.5, animations: {
            cover.alpha = 0
        }){ _ in
            cover.removeFromSuperview()
        }
    }
    
    func picked(_ state: Bool){
        if(state){
            layer.borderWidth = 2
            if let btn = self as? UIButton{
                btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            }
            if let lbl = self as? UILabel{
                lbl.font = UIFont.boldSystemFont(ofSize: 17)
            }
            if let tv = self as? UITextView{
                tv.font = UIFont.boldSystemFont(ofSize: 17)
            }
            //btn.backgroundColor = color
            //btn.setTitleColor(UIColor.white, for: .normal)
        }else{
            layer.borderWidth = 1
            if let btn = self as? UIButton{
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            }
            if let lbl = self as? UILabel{
                lbl.font = UIFont.systemFont(ofSize: 17)
            }
            if let tv = self as? UITextView{
                tv.font = UIFont.systemFont(ofSize: 17)
            }
            //btn.backgroundColor = nil
            //btn.setTitleColor(color, for: .normal)
        }
    }
}

extension UIButton {
    
    /// Creates a duplicate of the terget UIButton
    /// The caller specified the UIControlEvent types to copy across to the duplicate
    ///
    /// - Parameter controlEvents: UIControlEvent types to copy
    /// - Returns: A UIButton duplicate of the original button
    
    func trigger(){
        backgroundColor = UIColor.black
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundColor = self.backgroundColor!.withAlphaComponent(0)
        }){ _ in
            self.backgroundColor = nil
        }
    }
    
    func duplicate(forControlEvents controlEvents: [UIControl.Event]) -> UIButton? {
        do{
            let archivedButton = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            guard let buttonDuplicate = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedButton) as? UIButton else { return nil }
            
            //guard let buttonDuplicate = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [UIButton.self], from: archivedButton) as? UIButton else { return nil }
            
            // Copy targets and associated actions
            self.allTargets.forEach { target in
                
                controlEvents.forEach { controlEvent in
                    
                    self.actions(forTarget: target, forControlEvent: controlEvent)?.forEach { action in
                        buttonDuplicate.addTarget(target, action: Selector(action), for: controlEvent)
                    }
                }
            }
            return buttonDuplicate
        }catch{
            
        }
        return nil
    }
}
