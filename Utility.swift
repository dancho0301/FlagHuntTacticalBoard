//
//  Utility.swift
//  FlagHuntTacticalBoard
//
//  Created by dancho on 2016/11/05.
//  Copyright © 2016年 dancho. All rights reserved.
//

import UIKit
import SceneKit

class Utility: NSObject {
    
    static func addVector3(vector1 : SCNVector3, vector2 : SCNVector3) -> SCNVector3{
        return SCNVector3FromFloat3(SCNVector3ToFloat3(vector1) + SCNVector3ToFloat3(vector2))
    }
    
//    // ラジアン角度がマイナスだったら、正の数に変換する
    static func calcRadian(radian: Float) -> Float{
        if radian < 0 {
            return (2 * Float(M_PI)) - fabs(radian).truncatingRemainder(dividingBy: 2 * Float(M_PI))
            
//            let cameraKakudo = fabs(cameraRadian * 180 / Float(M_PI)).truncatingRemainder(dividingBy: 360)

        } else{
            return radian
        }
    }

}
