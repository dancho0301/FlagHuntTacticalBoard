//
//  FieldNode.swift
//  FlagHuntTacticalBoard
//
//  Created by dancho on 2016/11/05.
//  Copyright © 2016年 dancho. All rights reserved.
//

import SceneKit

class FieldNode: SCNNode {
    
     init(x: Int, y: Int) {
        super.init()

        let field = SCNBox(
            width: CGFloat(x + 1),
            height: 0.1,
            length: CGFloat(y + 1),
            chamferRadius: 0.0)
        field.firstMaterial?.diffuse.contents = UIColor.green
        self.geometry = field
        self.position = SCNVector3(x: (Float(x)/2), y: 0, z: (Float(y)/2))

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}