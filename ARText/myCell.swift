//
//  myCell.swift
//  collection
//
//  Created by Ali Mohammadian
//

import UIKit

class myCell: UICollectionViewCell {
    
    @IBOutlet weak var myImageView: UIImageView!
    var numb: Int = 0
    
    var item: String? = nil
    
    var name: String? = nil
    
    func returnNum() -> Int {
        return numb
    }
}
