//
//  FlagNode
//  FlagHuntTacticalBoard
//
//  Created by dancho on 2016/11/05.
//  Copyright © 2016年 dancho. All rights reserved.
//

import SceneKit

class FlagNode: SCNNode {
    
    override init() {
        super.init()
        let flagGeometry = SCNPyramid(width: 1, height: 0.1, length: 1)
        flagGeometry.firstMaterial?.diffuse.contents = UIColor.red
        self.geometry = flagGeometry

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
        - parameter position: 位置
        - parameter flag: フラッグ位置ならtrue
     */
        init(position: SCNVector3, flag: Bool) {
        super.init()
        let flagGeometry = SCNPyramid(width: 1, height: 0.1, length: 1)
        flagGeometry.firstMaterial?.diffuse.contents = UIColor.red
        self.geometry = flagGeometry
        self.position = position
        
        if flag{
            let flagNode2 = SCNNode()
            let flagGeometry2 = SCNCylinder(radius: 0.1, height: 5)
            flagGeometry2.firstMaterial?.diffuse.contents = UIColor.red
            flagNode2.geometry = flagGeometry2
            flagNode2.position = SCNVector3(x: 0, y: 2.5, z: 0)
            flagNode2.opacity = 0.5
            self.addChildNode(flagNode2)
        }
    }
    
    
}
