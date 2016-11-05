//
//  BunkerNode.swift
//  FlagHuntTacticalBoard
//
//  Created by dancho on 2016/11/05.
//  Copyright © 2016年 dancho. All rights reserved.
//
//  バンカー用ノード
//

import SceneKit

class BunkerNode: SCNNode {

    let bunkerGeometry = SCNBox(width: 1.1, height: 1, length: 1.1, chamferRadius: 0.1)
    
    override init() {
        super.init()
        self.geometry = bunkerGeometry
        
        var materials = [SCNMaterial]()
        for i in 1...6 {
            let material = SCNMaterial()
            if i == 1 { material.diffuse.contents = UIColor.darkGray }
            if i == 2 { material.diffuse.contents = UIColor.darkGray }
            if i == 3 { material.diffuse.contents = UIColor.darkGray }
            if i == 4 { material.diffuse.contents = UIColor.darkGray  }
            if i == 5 { material.diffuse.contents = UIColor.yellow }
            if i == 6 { material.diffuse.contents = UIColor.darkGray }
            materials.append(material)
        }
        self.geometry?.materials = materials
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpperBunker(){
        self.geometry?.materials[4].diffuse.contents = UIColor.orange
    }
    
    
    
}
