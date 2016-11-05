//
//  SubjectiveCameraNode.swift
//  FlagHuntTacticalBoard
//
//  Created by dancho on 2016/11/05.
//  Copyright © 2016年 dancho. All rights reserved.
//

import SceneKit

class SubjectiveCameraNode: SCNNode {

    var markerNode = SCNNode()
    
    
//    overlet camera : SCNCamera
    var _position = SCNVector3()
    override var position: SCNVector3 {
        didSet{
        }
    }
    
    init(position: SCNVector3, angle: SCNVector3) {
        super.init()
        print("今のカメラの方向", self.eulerAngles)

        self.camera = SCNCamera()
        
        self.name = "subjectiveCameraNode"
        self.position = position
        self.eulerAngles = angle
//        self.camera?.yFov = Double(fovY)
//        self.camera?.xFov = Double(fovX)
        
        let markGeometry = SCNCone(topRadius: 0.001, bottomRadius: 0.2, height: 0.5)
        markGeometry.firstMaterial?.diffuse.contents = UIColor.orange
        self.geometry = markGeometry
        
        print("今のカメラの方向", self.eulerAngles)
        
        setMarker()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    func setMarker(){
        markerNode = SCNNode()
        
//        let testGeometry = SCNPyramid(width: 0.7, height: 0.7, length: 0.7)
        let markGeometry = SCNCone(topRadius: 0.001, bottomRadius: 0.2, height: 0.5)
        markGeometry.firstMaterial?.diffuse.contents = UIColor.purple
        markerNode.geometry = markGeometry
//        markerNode.position = self.position
        let markerNodeEulerAngle = SCNVector3FromFloat3(SCNVector3ToFloat3(self.eulerAngles) + vector3(Float(-M_PI_2), 0, 0))
        markerNode.eulerAngles = markerNodeEulerAngle
        
//        markerNode.eulerAngles = self.eulerAngles
        
        self.addChildNode(markerNode)
    }
    
    
    
    // カメラを動かす。。。のは無理！三角関数とかわかんない！
    func move(vector: String){
        print("##### 移動開始 #####")
        
        print("今のカメラの方向", self.eulerAngles.y, Utility.calcRadian(radian: self.eulerAngles.y))
        
        // 移動したい方向
        var cameraRadian = Float()
        switch vector {
        case "UP":
            cameraRadian = Utility.calcRadian(radian: self.eulerAngles.y + Float(M_PI_2))
        case "DOWN":
            cameraRadian = Utility.calcRadian(radian: self.eulerAngles.y + Float.pi)
        case "LEFT":
            cameraRadian = Utility.calcRadian(radian: self.eulerAngles.y + Float.pi)
        case "RIGHT":
            cameraRadian = Utility.calcRadian(radian: self.eulerAngles.y)
        default:
            break
        }

        // （参考用：カメラの角度）
        let cameraKakudo = fabs(cameraRadian * 180 / Float(M_PI)).truncatingRemainder(dividingBy: 360)
        print("進行方向", cameraRadian, cameraKakudo, Utility.calcRadian(radian: cameraRadian))
        
        let _cameraVector       = SCNVector3(x: cos(cameraRadian), y: 0, z: sin(cameraRadian))
        print("カメラの位置", self.position)
        print("カメラの移動", _cameraVector)
        
        // カメラの現在位置に、移動したい方向を足す
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        
        self.position = Utility.addVector3(vector1: self.position, vector2: _cameraVector)
        markerNode.eulerAngles = Utility.addVector3(vector1: self.eulerAngles, vector2: SCNVector3(Float(-M_PI_2), 0, 0))

        print("カメラの移動先", self.position)

        
        SCNTransaction.commit()
    }

}
