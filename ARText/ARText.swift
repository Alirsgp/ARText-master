//
//  ARText.swift
//  
//
//  Created by Ali Mohammadian
//

import UIKit
import SceneKit
import ARKit


class ARText:SCNText{
    
    
    override init() {
        super.init()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    init(text:String,
        font:UIFont,
        color:UIColor,
        depth:CGFloat
        ){
        super.init()
        
        self.string = text
        self.extrusionDepth = depth
        self.font = font
        self.alignmentMode = convertFromCATextLayerAlignmentMode(CATextLayerAlignmentMode.center)
        self.truncationMode = convertFromCATextLayerTruncationMode(CATextLayerTruncationMode.middle)
        self.firstMaterial?.isDoubleSided = true
        self.firstMaterial!.diffuse.contents = color        
        self.flatness = 0.3
    
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATextLayerAlignmentMode(_ input: CATextLayerAlignmentMode) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATextLayerTruncationMode(_ input: CATextLayerTruncationMode) -> String {
	return input.rawValue
}
