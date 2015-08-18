import UIKit

@IBDesignable
class UINumField: UILabel , IDPNumpadViewControllerDelegate{

    private var vc:IDPNumpadViewController?

    // 入力中かどうかのステータス
    private var isBusy = false
    
    // MARK: - Property
    
    // フォーカスがない時の背景色
    @IBInspectable var offColor: UIColor = .lightGrayColor(){
        didSet{ //storyboardでリアルタイムに表示するため
            backgroundColor = offColor
        }
    }
    // フォーカスがある時の背景色
    @IBInspectable var onColor: UIColor = .clearColor()
//        {
//        didSet{ //storyboardでリアルタイムに表示するため
//            backgroundColor = onColor
//        }
//    }
    // 設定された値を読み取るためのプロパティ
    var value:CFloat {
        get{
            return CFloat(vc!.value)
        }
    }

    //MARK: - Initialize
    
    func initialize(){
        // UILabelを Storyboard で置いた時のデフォルト値を削除する
        text="0.0"
        // Labelのフォントのサイズを修正
        font = UIFont.systemFontOfSize(35)
        // Labelがタッチイベントを受け取るように設定する
        userInteractionEnabled = true

        backgroundColor = offColor
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize() // 実行時は、ここを通る

        // SimpleNumpadの生成が、Storyboardで処理できないため、ここで初期化する
        vc = IDPNumpadViewController(style:IDPNumpadViewControllerStyle.CalcApp,inputStyle: IDPNumpadViewControllerInputStyle.Number,showNumberDisplay: false)
        vc?.delegate = self // SimpleNumpadのデリゲートクラスを自身とする
        
    }
    // init() イニシャライザを書く場合は、これも同時に定義しないとエラーとなる
    // Failed to update auto layout status interface Builder Cocoa touch
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // ここでStoryboard上の見た目を初期化する
    override func prepareForInterfaceBuilder() {
        initialize()
    }
    
    //MARK: - delegate
    
    // SimpleNumpadの内部の値が変化した際のイベント処理
    func numpadViewControllerDidUpdate(numpadViewController: IDPNumpadViewController!) {
        self.text = "\(vc!.value)"
    }
    // Enterが押された時のイベント処理
    func numpadViewControllerDidEnter(numpadViewController: IDPNumpadViewController!) {
        // モーダルビューを閉じる
        parentViewController!.dismissViewControllerAnimated(true, completion: {})
        // ステータスを変更
        isBusy = false
        // 背景色を変更
        backgroundColor = offColor
    }
    
    
    // コントロールがタッチされた際のイベント処理
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if isBusy {
            return // 既に入力中の場合は処理なし
        }
        // ステータスを「入力中」に変更
        isBusy = true
        // 背景色を変更
        backgroundColor = onColor
        // 親のビューコントローラのモーダルビューとして、vc(SimpleNumpad)を開く
        parentViewController!.presentViewController(self.vc!, animated: true, completion: {})
    }
    
    // 親となるUIViewControllerを検索（取得）する
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

}
