import UIKit
import SocketIO

typealias VC = ViewController
typealias D = Dimension
struct Dimension{
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    static let statusBarHeight = UIApplication.shared.statusBarFrame.height
    static let cellHeight = CGFloat(44)
    static let clipViewHeight = CGFloat(88)
    static let ButtonDiameter = CGFloat(37)
    static let space = CGFloat(8)
    static let cornerRadius = CGFloat(15)
}
protocol ClipDelegate {
    func getAtCellIdx(view: UIView)->Int?
    func getCell(at: Int)->CTVC?
    func useCell(at: Int)
    func addCell()
    func addCell(str: String)
    func removeCell(at: Int)
    func switchCell(at: Int)
    func rearrangeCells()
    func editClip()
    func confirmClip()
    func clearClip()
}
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, ClipDelegate{
    private static var _shared: VC? = nil
    static var shared: VC?{get{return _shared}}
    static var clipBoardText: String?{
        get{
            return UIPasteboard.general.string
        }
        set{
            UIPasteboard.general.string = newValue
        }
    }
    //--------------------------------------------
    static let y_clipButton = D.statusBarHeight + D.clipViewHeight + D.space * 2
    static let y_clipTableView = D.statusBarHeight + D.clipViewHeight + D.ButtonDiameter + D.space * 3
    //--------------------------------------------
    var clipTextView = ClipTextView(
        x: D.space + D.ButtonDiameter,
        y: D.statusBarHeight + D.space * 2,
        width: D.screenWidth - 2 * D.ButtonDiameter - 2 * D.space,
        height: D.clipViewHeight
    )
    var clipButton_manu = ClipButton(
        x: D.screenWidth - D.ButtonDiameter - D.space,
        y: D.statusBarHeight + D.space,
        width: D.ButtonDiameter,
        height: D.ButtonDiameter,
        style: .manu,
        action: {}
    )
    var clipButton_sync = ClipButton(
        x: D.space,
        y: D.statusBarHeight + D.space,
        width: D.ButtonDiameter,
        height: D.ButtonDiameter,
        style: .sync,
        action: {}
    )
    var clipButton_add = ClipButton(
        x: D.screenWidth / 2 - D.ButtonDiameter / 2,
        y: y_clipButton,
        width: D.ButtonDiameter,
        height: D.ButtonDiameter,
        style: .add,
        action: {}
    )
    var clipButton_edit = ClipButton(
        x: D.screenWidth - D.ButtonDiameter - D.space,
        y: y_clipButton,
        width: D.ButtonDiameter,
        height: D.ButtonDiameter,
        style: .edit,
        action: {}
    )
    var clipButton_confirm = ClipButton(
        x: D.screenWidth - D.ButtonDiameter - D.space,
        y: y_clipButton,
        width: D.ButtonDiameter,
        height: D.ButtonDiameter,
        style: .check,
        action: {}
    )
    var clipButton_clear = ClipButton(
        x: D.space,
        y: y_clipButton,
        width: D.ButtonDiameter,
        height: D.ButtonDiameter,
        style: .clear,
        action: {}
    )
    var clipButton_rearrange = ClipButton(
        x: D.space,
        y: y_clipButton,
        width: D.ButtonDiameter,
        height: D.ButtonDiameter,
        style: .rearrange,
        action: {}
    )
    var clipTableViewBorder = UIView(frame: CGRect(
        x: 0,
        y: y_clipTableView-1,
        width: D.screenWidth,
        height: 1
    ))
    var clipTableView = ClipTableView(
        x: 0,
        y: y_clipTableView,
        width: D.screenWidth,
        height: D.screenHeight - y_clipTableView
    )
    //--------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewController._shared = self
        
        clipTableView.delegate = self
        clipTableView.dataSource = self
        
        clipButton_sync.action = {self.syncClipboard()}
        clipButton_manu.action = {self.showManu()}
        clipButton_add.action = {self.addCell()}
        clipButton_edit.action = {self.editClip()}
        clipButton_confirm.action = {self.confirmClip()}
        clipButton_clear.action = {self.clearClip()}
        clipButton_rearrange.action = {self.rearrangeCells()}
        
        view.addSubview(clipTextView)
        view.addSubview(clipButton_sync)
        view.addSubview(clipButton_manu)
        view.addSubview(clipButton_add)
        view.addSubview(clipButton_edit)
        view.addSubview(clipButton_confirm)
        view.addSubview(clipButton_clear)
        view.addSubview(clipButton_rearrange)
        view.addSubview(clipTableViewBorder)
        view.addSubview(clipTableView)
        
        //Storage.readItemsFromFile()
        //Storage.saveToShare()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(willResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(Storage.strs.count==0){
            Storage.strs.append("Let's install the widget!")
        }
        extraViewSetUp()
    }

    func extraViewSetUp(){
        clipButton_edit.show()
        clipButton_confirm.hide()
        clipButton_rearrange.hide()
        clipTextView.isSelectable = false
        clipTableView.isEditing = true
        clipTableViewBorder.backgroundColor = UIColor.black
        clipTextView.text = VC.clipBoardText
        Storage.readItemsFromShare()
        clipTableView.reloadData()
    }
    
    @objc func didBecomeActiveNotification(){
        extraViewSetUp()
    }
    
    @objc func willResignActiveNotification(){
        confirmClip()
    }
    
    func save(){
        Storage.saveToShare()
        Storage.saveToFile()
    }
    // MARK: - Clip TableView data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Storage.strs.count
    }
    
    func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath){
        let cell = getCell(at: indexPath.row)
        VC.clipBoardText = cell?.getText()
        cell?.flash(text: "Copied!")
        clipTextView.text = VC.clipBoardText
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ClipTableViewCell(frame: CGRect(
            x: 0,
            y: 0,
            width: D.screenWidth,
            height: clipTableView.rowHeight
        ))
        cell.delegate = self
        cell.setContent(Storage.strs[indexPath.row])
        //cell.setContentSimple(Storage.strs[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }

    /*
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        
        let ackAction = UITableViewRowAction(style: .default, title: "", handler: {_,_ in })
        
        return [ackAction]
    }
 */
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            removeCell(at: indexPath.row)
        } else if editingStyle == .insert {
            
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let str = Storage.strs[fromIndexPath.row]
        Storage.strs.remove(at: fromIndexPath.row)
        Storage.strs.insert(str, at: to.row)
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: - Clip TextView delegate
    
    func textViewDidFinishEditing(){
        VC.clipBoardText = clipTextView.text
    }
    
    // MARK: - Clip Protocal
    
    func getCell(at: Int)->CTVC?{
        if let cell = clipTableView.cellForRow(at: IndexPath(row: at, section: 0)) as? CTVC{
            return cell
        }
        print("Not a CTVC")
        return nil
    }
    
    func addCell() {
        if let str = clipTextView.text{
            if str == "" {return}
            Storage.strs = [str] + Storage.strs
            clipTableView.beginUpdates()
            clipTableView.insertRows(
                at: [IndexPath(row: 0, section: 0)],
                with: .automatic
            )
            clipTableView.endUpdates()
            save()
        }
    }
    func addCell(str: String) {
        Storage.strs = [str] + Storage.strs
        clipTableView.beginUpdates()
        clipTableView.insertRows(
            at: [IndexPath(row: 0, section: 0)],
            with: .automatic
        )
        clipTableView.endUpdates()
        save()
    }
    func useCell(at: Int){
        VC.clipBoardText = getCell(at: at)?.getText()
        clipTextView.text = VC.clipBoardText
        shareClip()
    }
    func removeCell(at: Int){
        Storage.strs.remove(at: at)
        clipTableView.beginUpdates()
        clipTableView.deleteRows(
            at: [IndexPath(row: at, section: 0)],
            with: .fade
        )
        clipTableView.endUpdates()
        save()
    }
    func switchCell(at: Int) {
        if let temp = VC.clipBoardText{
            VC.clipBoardText = Storage.strs[at]
            Storage.strs[at] = temp
            clipTextView.text = temp
            getCell(at: at)?.btn_field?.setTitle(temp, for: .normal)
            save()
        }
    }
    func rearrangeCells() {
        clipTableView.isEditing = !clipTableView.isEditing
    }
    
    func editClip() {
        clipButton_edit.hide()
        clipButton_confirm.show()
        clipTextView.isEditable = true
        clipTextView.becomeFirstResponder()
    }
    
    func confirmClip() {
        clipButton_edit.show()
        clipButton_confirm.hide()
        clipTextView.isSelectable = false
        clipTextView.isEditable = false
        VC.clipBoardText = clipTextView.text
        shareClip()
    }
    func clearClip(){
        clipTextView.text = ""
        if(!clipTextView.isEditable){
            VC.clipBoardText = ""
        }
    }
    func getAtCellIdx(view: UIView)->Int?{
        return clipTableView.indexPathForView(view)?.row
    }
    
    // MARK: - My Function
    var manager: SocketManager? = nil
    var socket: SocketIOClient? = nil
    var linked = false
    var uuid = ""
    func syncClipboard(){
        if(linked){
            releaseSocket()
        }else{
            let QRHelper = QRScaner()
            QRHelper.finalHandler = {
                if(QRHelper.code != ""){
                    self.buildSocket(QRHelper.code)
                }else{
                    self.manualKeyIn(handler: self.buildSocket)
                }
            }
            QRHelper.start(self)
        }
    }
    
    func buildSocket(_ url: String){
        let nodes = url.split(separator: "?")
        if(nodes.count<2){return}
        let path = String(nodes[0])
        for param in nodes[1].split(separator: "&"){
            let comps = param.split(separator: "=")
            if(comps.count<2){return}
            if String(comps[0]) == "id"{
                uuid = String(comps[1])
            }
        }
        manager?.disconnect()
        manager = SocketManager(socketURL: URL(string: path)!, config: [.log(true), .compress])
        socket = manager!.defaultSocket
        socket?.on(clientEvent: .connect) {data, ack in
            self.clipButton_sync.backgroundColor = UIColor.black
            self.clipButton_sync.setTitleColor(UIColor.white, for: .normal)
            self.linked = true
            self.socket?.emit("require", ["uuid":self.uuid, "ask":true] )
        }
        socket?.on("clipboard") {data, ack in
            let obj = data[0] as! [String: Any]
            let str = obj["str"] as! String
            self.clipTextView.text = str
            VC.clipBoardText = self.clipTextView.text
        }
        socket?.on("ask") {data, ack in
           self.shareClip()
        }
        socket?.connect()
    }
    
    func shareClip(){
        if(linked){
            socket?.emit("clipboard", ["uuid":uuid, "str": clipTextView.text!, "src": "app"] )
        }
    }
    
    func releaseSocket(){
        clipButton_sync.backgroundColor = UIColor.white
        clipButton_sync.setTitleColor(UIColor.black, for: .normal)
        linked = false
        manager?.disconnect()
        manager = nil
        socket = nil
        uuid = ""
    }
    
    func manualKeyIn(handler: @escaping (String)->()) {
        let keyinController = UIAlertController(
            title: "手動輸入",
            message: "",
            preferredStyle: .alert)
        
        keyinController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "url"
        }
        let tf = ((keyinController.textFields?.first)! as UITextField)
        keyinController.addAction(
            UIAlertAction(
                title: "取消",
                style: .cancel){(action: UIAlertAction!) -> Void in}
            )
        keyinController.addAction(
            UIAlertAction(
                title: "確定",
                style: UIAlertAction.Style.default,
                handler: {(action: UIAlertAction!) -> Void in
                    handler(tf.text!)
                }
            )
        )
        self.present(
            keyinController,
            animated: true,
            completion: nil
        )
    }
    
    func showManu(){
        
    }
}
