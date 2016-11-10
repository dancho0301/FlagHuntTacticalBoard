//
//  StartNode.swift
//  FlagHuntTacticalBoard
//
//  Created by dancho on 2016/11/05.
//  Copyright © 2016年 dancho. All rights reserved.
//

import SceneKit

class StartNode: SCNNode {
    
    override init() {
        super.init()
        let startGeometry = SCNPyramid(width: 1, height: 0.1, length: 1)
        self.geometry = startGeometry
        startGeometry.firstMaterial?.diffuse.contents = UIColor.yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
