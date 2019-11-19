import UIKit
import SDWebImage
import SwiftyJSON
import CoreImage
import Alamofire

class ViewController: UIViewController, UIPencilInteractionDelegate {
    
    // MARK: Properties
    enum CanvasStatus: Equatable {
        case none
        case ready
        case typeSelected
        case imageLoaded
        case clearCanvas
        case diseaseSelected
        case annotating
        case saved
    }

    enum DrawingStatus: Equatable {
        case none
        case start
        case end
    }
    
    private var useDebugDrawing = false
    private var status:CanvasStatus = .none
    private var drawingStatus:DrawingStatus = .none
    private var currentPicture:JSON = JSON()
    
    private var filter = CIFilter(name: "CIControls")
    private var ciimage = CIImage()
    
    @IBOutlet private weak var canvasView: CanvasView!
    @IBOutlet private weak var debugButton: UIButton!
    
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet private weak var locationLabel: UILabel!
    
    /// An IBOutlet Collection with all of the labels for touch values.
    @IBOutlet private var gagueLabelCollection: [UILabel]!
    @IBOutlet weak var pictureImageView: UIImageView!
    var pictureImage = UIImage()
    var originalPictureImage = UIImage()    // non-filtering image

    // Image Process
    var brightnessFilter = CIFilter(name: "CIColorControls")!
    var invertFilter = CIFilter(name: "CIColorInvert")!
    var aCIImage = CIImage()
    var context  = CIContext()
    var newUIImage = UIImage()
    var outputImage = CIImage()
    
    // MARK: Send Actions
    @IBAction func save(_ sender: Any) {
        guard let deviceId = UIDevice.current.identifierForVendor else {
            return
        }

//        let drawLines = self.canvasView.getDrawLines();
        let drawLinesAndLabels = self.canvasView.getDrawLinesAndLabels();
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(drawLinesAndLabels)
        let drawLinesAndLabelsString = String(data: data, encoding: .utf8)!
        
        AF.request(K.API_SERVER_PREFIX + "os_findings/http_add", method: .post, parameters:[
            "os_app_user_id":deviceId.uuidString,
            "os_raw_picture_id":self.currentPicture["OsRawPicture"]["id"].stringValue,
            "finding_plain":drawLinesAndLabelsString,
            "memo":self.canvasView.memo
        ]).responseJSON {response in
            switch response.result {
            case .success(_):
                let alert = UIAlertController(title: "Success", message: "This action can repeat.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                }))
                self.present(alert, animated: true, completion: nil)
                break
            case .failure(_):
                let alert = UIAlertController(title: "Failed", message: "This action can repeat.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                }))
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }
    
    // MARK: Actions
    func setStatus(status:CanvasStatus) {
        print("setStatus = \(status) self.status = \(self.status)")

        if(self.status == status) { return };
        
        switch status {
        case .ready:
            self.trashButton.isEnabled = false
            break
        case .typeSelected:
            break
        case .imageLoaded:
            self.canvasView.clear()
            self.status = status
            self.setStatus(status: .annotating)
            break
        case .clearCanvas:
            self.trashButton.isEnabled = false
            self.status = status
            self.setStatus(status: .annotating)
            break;
        case .diseaseSelected:
            self.status = status
            self.setStatus(status: .annotating)
            break
        case .annotating:
            self.status = status
            break
        case .saved:
            self.status = status
            break
        default:
            assert(true)
            break;
        }
    }

    func setDrawingStatus(status:DrawingStatus) {
        print("setStatus = \(status) self.status = \(self.status)")
        
        if self.drawingStatus == status { return }
        if K.APP_ENV == .production && self.status != .annotating { return }
        
        switch status {
        case .none:
            
            break;
        case .start:    // 그리기 시작
            self.drawingStatus = status
            self.locationView.isHidden = false
            break
        case .end:      // 그리기 끝. 라벨링 추가
            performSegue(withIdentifier: "showLabelTableViewController", sender: nil)
            self.setDrawingStatus(status: .none)
            self.trashButton.isEnabled = true
            self.locationView.isHidden = true
            self.canvasView.addSelectedPropertyIntoLastLine()
            break
        }
    }
    
    func viewPicture(data: JSON) {
        self.currentPicture = data;
        self.title = data["OsPictureType"]["name"].stringValue + " - " + data["OsRawPicture"]["display_name"].stringValue
        self.pictureImageView.sd_setImage(with: URL(string:K.API_SERVER_PREFIX + data["OsRawPicture"]["original_name"].stringValue))
        self.setStatus(status: .imageLoaded)
        guard let cgImage = self.pictureImageView.image?.cgImage?.copy() else {
            return
        }
        self.pictureImage = UIImage(cgImage: cgImage,
                               scale: self.pictureImageView.image!.scale,
                               orientation: self.pictureImageView.image!.imageOrientation)
//        self.originalPictureImage = UIImage(cgImage: cgImage,
//                                            scale: self.pictureImageView.image!.scale,
//                                            orientation: self.pictureImageView.image!.imageOrientation)
        print(data)
    }
    
    func removeLastLine() {
        canvasView.removeLastLine()
    }
    
    /// call from LabelTableViewController
    func saveLabels(_ labels: [Int], memo: String) -> Void {
        self.canvasView.labels.append(labels)
        self.canvasView.memo = memo
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.isDebuggingEnabled   = self.useDebugDrawing
        clearGagues()
        self.locationView.isHidden = true
        
        if #available(iOS 12.1, *) {
            let pencilInteraction = UIPencilInteraction()
            pencilInteraction.delegate = self
            view.addInteraction(pencilInteraction)
        }
        
        self.title = K.APP_TITLE
        self.setStatus(status: .ready)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if K.APP_ENV == .production {
            performSegue(withIdentifier: "showIntroduceViewController", sender: self)
            return
        }
    }
    
    // MARK: Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if targetEnvironment(simulator)
        // your simulator code
        #else
        // your real device code
        guard touches.first?.type == .pencil else {
            self.toggleNavigationSeparatorView()
            return
        }
        #endif

        if K.APP_ENV == .production && self.status != .annotating { return }
        
        canvasView.drawTouches(touches, withEvent: event)

        touches.forEach { (touch) in
            updateGagues(with: touch)
        }
        
        self.setDrawingStatus(status: .start)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if targetEnvironment(simulator)
        // your simulator code
        #else
        // your real device code
        guard touches.first?.type == .pencil else {
            return
        }
        #endif

        if K.APP_ENV == .production && self.status != .annotating { return }
        
        canvasView.drawTouches(touches, withEvent: event)
        
        touches.forEach { (touch) in
            updateGagues(with: touch)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if targetEnvironment(simulator)
        // your simulator code
        #else
        // your real device code
        guard touches.first?.type == .pencil else {
            return
        }
        #endif

        if K.APP_ENV == .production && self.status != .annotating { return }

        canvasView.drawTouches(touches, withEvent: event)
        canvasView.endTouches(touches, cancel: false)

        touches.forEach { (touch) in
            clearGagues()
        }
        
        self.setDrawingStatus(status: .end)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first?.type == .pencil else {
            return
        }

        if K.APP_ENV == .production && self.status != .annotating { return }

        canvasView.endTouches(touches, cancel: true)

        touches.forEach { (touch) in
            clearGagues()
        }
    }

    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        if self.status != .annotating { return }

        canvasView.updateEstimatedPropertiesForTouches(touches)
    }

    // MARK: Actions

    @IBAction private func clearView(sender: Any) {
        let alert = UIAlertController(title: "Are you sure remove annotation data?", message: "This action cannot cancle.", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertAction.Style.destructive, handler: { (UIAlertAction) -> Void in
            self.canvasView.clear()
            self.setStatus(status: .clearCanvas)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction private func toggleDebugDrawing(sender: UIButton) {
        canvasView.isDebuggingEnabled = !canvasView.isDebuggingEnabled
        useDebugDrawing.toggle()
        sender.isSelected = canvasView.isDebuggingEnabled
    }

    @IBAction func writeLabels(_ sender: Any) {
        
    }
    
    @IBAction private func toggleUsePreciseLocations(sender: UIButton) {
        canvasView.usePreciseLocations = !canvasView.usePreciseLocations
        sender.isSelected = canvasView.usePreciseLocations
    }

    func toggleNavigationSeparatorView() {
        if (self.navigationController?.isNavigationBarHidden == true) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }

    // MARK: Image Process
    func changeInvert(_ value: Bool) -> Void {
        imageInvert(imgView: pictureImageView, onoff: value, image: pictureImage)
    }
    
    func changeBrightness(_ value: Float) -> Void {
        imageBrightness(imgView: pictureImageView, sliderValue: CGFloat(value), image: pictureImage)
    }
    
    func imageInvert(imgView : UIImageView, onoff : Bool, image: UIImage) {
        if onoff {
            let aCGImage = image.cgImage
            aCIImage = CIImage(cgImage: aCGImage!)
            context = CIContext(options: nil)

            invertFilter.setValue(aCIImage, forKey: kCIInputImageKey)
            
            outputImage = invertFilter.outputImage!
            let cgimg = context.createCGImage(outputImage, from: outputImage.extent)
            newUIImage = UIImage(cgImage: cgimg!)
            imgView.image = newUIImage
            return
        }

        imgView.image = image
        
        print("invert")
    }
    
    func imageBrightness(imgView : UIImageView , sliderValue : CGFloat, image: UIImage){
        let aCGImage = image.cgImage
        aCIImage = CIImage(cgImage: aCGImage!)
        context = CIContext(options: nil)

        brightnessFilter.setValue(aCIImage, forKey: "inputImage")
        
        brightnessFilter.setValue(sliderValue, forKey: "inputBrightness")
        outputImage = brightnessFilter.outputImage!
        let cgimg = context.createCGImage(outputImage, from: outputImage.extent)
        newUIImage = UIImage(cgImage: cgimg!)
        imgView.image = newUIImage
        print("brightness")
    }
    
    // MARK: Convenience
    
    private func updateGagues(with touch: UITouch) {
        let location = touch.preciseLocation(in: canvasView)
        locationLabel.text = location.valueFormattedForDisplay ?? ""
    }
    
    private func clearGagues() {
        gagueLabelCollection.forEach { (label) in
            label.text = ""
        }
    }

    /// A view controller extension that implements pencil interactions.
    /// - Tag: PencilInteraction
    @available(iOS 12.1, *)
    func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
        guard UIPencilInteraction.preferredTapAction == .switchPrevious else { return }
        
        /* The tap interaction is a quick way for the user to switch tools within an app.
         Toggling the debug drawing mode from Apple Pencil is a discoverable action, as the button
         for debug mode is on screen and visually changes to indicate what the tap interaction did.
         */
        self.toggleNavigationSeparatorView()
    }
    
    // MARK: - Navigation
    
//    override func performSegue(withIdentifier identifier: String, sender: Any?) {
//        print("performSegue - View Controller identifier = " + identifier)
//        if(identifier == "showLabelViewController") {
//            
//        }
//    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDiseaseTableViewController" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! DiseaseTableViewController
//            guard self.currentPicture["OsPictureType"]["id"] != nil else {
                targetController.pictureTypeId = 2
                return;
//            }
//            targetController.pictureTypeId = self.currentPicture["OsPictureType"]["id"].intValue
        }

        if segue.identifier == "showLabelTableViewController" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! LabelTableViewController
                targetController.pictureTypeId = self.currentPicture["OsPictureType"]["id"].intValue;
        }

        if segue.identifier == "showAnnotationTableViewController" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! AnnotationTableViewController
            targetController.canvasView = canvasView
        }

    }
}
