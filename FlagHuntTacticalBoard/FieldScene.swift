//
//  FieldScene.swift
//  FlagHuntTacticalBoard
//
//  Created by dancho on 2016/11/02.
//  Copyright © 2016年 dancho. All rights reserved.
//

import SceneKit

class FieldScene: SCNScene {
    
    var lookOverCameraNode          : SCNNode!          // 俯瞰視点カメラ
    var subjectiveCameraNode        : SCNNode!          // 主観視点カメラ
    
    var fieldNode                   : SCNNode!

    
    
    func createField(){
        fieldNode = SCNNode()
        
        
    }
    
    
}
