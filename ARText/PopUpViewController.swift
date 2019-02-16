//
//  PopUpViewController.swift
//  PopUp
//
//  Created by Ali Mohammadian.
//  Copyright © 2019 LookALike. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    var array: [UIImage?] = [nil, nil, nil, nil, nil, nil, nil, nil]
    
    var storeURL: [String?] = [nil, nil, nil, nil, nil, nil, nil, nil]
    
    var strName: [String?] = [nil, nil, nil, nil, nil, nil, nil, nil]
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for x in 0...7 {
            if let data = UserDefaults.standard.object(forKey: "imageData\(x)") as? Data {
                if let image : UIImage = UIImage(data: data) {
                    array[x] = image
                }
            }
            if let str = UserDefaults.standard.object(forKey: "urlData\(x)") as? String {
                storeURL[x] = str
            }
            
            if let name = UserDefaults.standard.object(forKey: "nameData\(x)") as? String {
                strName[x] = name
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        self.showAnimate()
        
        
        
        let itemSize = UIScreen.main.bounds.width/2.05
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        myCollectionView.collectionViewLayout = layout
        
        // Do any additional setup after loading the view.
    }
    
    //Number of views
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    //Populate view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! myCell
        cell.myImageView.image = array[indexPath.row]
        
        cell.numb = indexPath.row
        cell.item = storeURL[indexPath.row]
        cell.name = strName[indexPath.row]
        cell.addTapGestureRecognizer {
            let purchaseSourcePicker = UIAlertController(title: "Choose an option", message: "", preferredStyle: .actionSheet)
            let purchaseGo = UIAlertAction(title: "Purchase \(cell.name!)", style: .default) { [unowned self] _ in
                if let url = URL(string: cell.item!) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            purchaseSourcePicker.addAction(purchaseGo)
            
            purchaseSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            purchaseSourcePicker.modalPresentationStyle = .popover
            self.present(purchaseSourcePicker, animated: true)
        }
        return cell
    }

    @IBAction func closeButtonFinal(_ sender: UIButton) {
        self.removeAnimate()
        self.view.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closePopUp(_ sender: AnyObject) {
        self.removeAnimate()
        self.view.removeFromSuperview()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.view.isUserInteractionEnabled = true
        self.view.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.view.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }

}


extension UIView {
    
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
}

