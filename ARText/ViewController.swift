//
//  ViewController.swift
//  QuikPricer
//
//  Copyright Ali Mohammadian
//

import UIKit
import SceneKit
import ARKit
import CoreML
import Vision
import ImageIO

class ViewController: UIViewController,ARSCNViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var creditLabel: UILabel!
    
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
    
    let model1 = try! VNCoreMLModel(for: HackVT5Items().model)
    
    static var textChange: String = ""
    
    static var urlUse: String = ""
    
    static var nameUse: String = ""
    //
    static var creditCount: Int = 800
    
    var picInt: Int = 0
    
    
    @IBAction func buyRecent(_ sender: UIButton) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
    }
    

    
    let defaults = UserDefaults.standard
    
    let session = ARSession()
    
    var textNode:SCNNode?
    var textSize:CGFloat = 1
    var textDistance:Float = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //setup sceneView
        
        setupScene()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let picNum = UserDefaults.standard.object(forKey: "picInt") as? Int {
            self.picInt = picNum
        }
        
        
        if let creditHis = UserDefaults.standard.object(forKey: "creditScore") as? Int {
            ViewController.creditCount = creditHis
            if (ViewController.creditCount > 800) {
                ViewController.creditCount = 800
            }
            creditLabel.text = "Credit Score: \(ViewController.creditCount)"
        }
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Image Classification
    
    /// - Tag: MLModelSetup
    
    lazy var classificationRequest: VNCoreMLRequest = {
        
        let request = VNCoreMLRequest(model: model1, completionHandler: { [weak self] request, error in
            self?.processClassifications(for: request, error: error, category: "Item:")
        })
        request.imageCropAndScaleOption = .centerCrop
        return request
        
        
    }()
    
    
    /// - Tag: PerformRequests
    func updateClassifications(for image: UIImage) {
        
        
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        
        if let ori = orientation {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: ori)
            
            do {
                //Analyze Item
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
            
        }
    }
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?, category: String) {
        
        
        guard let results = request.results else {
            return
        }
        
        
        // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
        let classifications = results as! [VNClassificationObservation]
        
        if classifications.isEmpty {
            return
        } else {
                let topClassifications = classifications.prefix(1)
                let descriptions = topClassifications.map { classification in
                
                    //Format String as eg: "Airpods"
                    return String(format: "%@\n", classification.identifier)
                    //return String(format: "%@\n", classification.identifier)
                }
            ViewController.textChange = descriptions[0]
            print(descriptions[0])
            let str: String = descriptions[0]
            print(str)
            if (str == "MacBook\n") {
                ViewController.textChange.append("Price Match: $1,299")
                ViewController.urlUse = "https://www.apple.com/shop/buy-mac/macbook/space-gray-1.2ghz#"
                ViewController.nameUse = "MacBook"
                if (ViewController.creditCount <= 790) {
                    ViewController.creditCount += 10
                }
                
            } else if (str == "Airpods\n") {
                ViewController.textChange.append("Price Match: $159.99")
                ViewController.urlUse = "https://www.apple.com/shop/product/MMEF2AM/A/airpods"
                ViewController.nameUse = "Airpods"
                if (ViewController.creditCount >= 600) {
                    ViewController.creditCount -= 10
                }
            } else if (str == "Monster Energy\n") {
                ViewController.textChange.append("Price Match: $2.99")
                ViewController.urlUse = "https://www.amazon.com/Monster-Energy-Drink-Green-Original/dp/B006IMBHVU"
                ViewController.nameUse = "Monster Energy"
                if (ViewController.creditCount <= 800) {
                    ViewController.creditCount -= 15
                }
            } else if (str == "Coca Cola\n") {
                ViewController.textChange.append("Price Match: $0.99")
                ViewController.urlUse = "https://www.amazon.com/stores/page/5F7F22EF-7E3B-4BFF-B91E-23F98843C929"
                ViewController.nameUse = "Coca Cola"
                if (ViewController.creditCount <= 795) {
                    ViewController.creditCount -= 10
                }
            } else if (str == "ThinkPad\n") {
                ViewController.textChange.append("Price Match: Starts at $1,000.00")
                ViewController.urlUse = "https://www.amazon.com/Lenovo-Thinkpad-Ultrabook-20F9-S20T00-Multitouch/dp/B01DJNW7AA"
                ViewController.nameUse = "ThinkPad"
                if (ViewController.creditCount <= 795) {
                    ViewController.creditCount += 5
                }
            }
            
        }
        
    }
    
    func setupScene() {
        // set up sceneView
        sceneView.delegate = self
        sceneView.session = session
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = false
        
        sceneView.preferredFramesPerSecond = 60
        sceneView.contentScaleFactor = 1.3
        //sceneView.showsStatistics = true
        
        enableEnvironmentMapWithIntensity(25.0)
        
        DispatchQueue.main.async {
            //self.screenCenter = self.sceneView.bounds.mid
        }
        
        if let camera = sceneView.pointOfView?.camera {
            camera.wantsHDR = true
            //camera.wantsExposureAdaptation = true
            //camera.exposureOffset = -1
            //camera.minimumExposure = -1
        }
        
        sceneView.showsStatistics = true
        //sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints]
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func handleSendButton(_ sender: AnyObject) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            node.removeFromParentNode()
        }
        let myImg: UIImage = sceneView.snapshot()
        
        self.updateClassifications(for: myImg)
        creditLabel.text = "Credit Score: \(ViewController.creditCount)"
        let tempT = ViewController.textChange
        self.showText(text: tempT)
        
        if (picInt == 8) {
            picInt = 0
        }
        
        
        self.view.endEditing(true)
        let saveImg: UIImage = sceneView.snapshot()
        let data = saveImg.jpegData(compressionQuality: 1.00)
        UserDefaults.standard.set(data, forKey: "imageData\(picInt)")
        UserDefaults.standard.set(ViewController.urlUse, forKey: "urlData\(picInt)")
        UserDefaults.standard.set(ViewController.nameUse, forKey: "nameData\(picInt)")
        UserDefaults.standard.set(ViewController.creditCount, forKey: "creditScore")
        
        UserDefaults.standard.set(picInt + 1, forKey: "picInt")
        picInt += 1
    }
    
    
    @objc func keyboardWillHide(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                //key point 0,
                self.inputContainerViewBottom.constant =  0
                //textViewBottomConstraint.constant = keyboardHeight
                UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
            }
        }
    }
    @objc func keyboardWillShow(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                self.inputContainerViewBottom.constant = keyboardHeight
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    
    func showText(text: String) -> Void {
        
        
        let fontSize = 2.5
        let textDistance = 5.0
        let textColor = UIColor.white
        
        let textScn = ARText(text: text, font: UIFont .systemFont(ofSize: CGFloat(fontSize)), color: textColor, depth: CGFloat(fontSize/10))
        let textNode = TextNode(distance: Float(textDistance / 10), scntext: textScn, sceneView: self.sceneView, scale: 1/100.0)
        self.sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    
    
    @IBAction func restartButton(_ sender: UIButton) {
        
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            node.removeFromParentNode()
        }
        
    }
    
    func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
        if sceneView.scene.lightingEnvironment.contents == nil {
            if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
                sceneView.scene.lightingEnvironment.contents = environmentMap
            }
        }
        sceneView.scene.lightingEnvironment.intensity = intensity
    }
    
    
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
}

