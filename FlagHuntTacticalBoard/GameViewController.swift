//
//  GameViewController.swift
//  FlagHuntTacticalBoard
//
//  Created by dancho on 2016/11/02.
//  Copyright © 2016年 dancho. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    @IBOutlet var scnView: SCNView!
    @IBOutlet var menuBar: UIView!
    @IBOutlet var cursorView: UIView!

    // デバッグボタン
    @IBAction func btnDebug(_ sender: Any) {
        let scnView = self.view as! SCNView
        debug()
        print("*****************************")
        print(scnView.pointOfView?.name ?? "None")
        print(lookOverCameraNode)
        print(subjectiveCameraNode)
        print("*****************************")
    }
    // 俯瞰ビュー
    @IBAction func btnLookOverView(_ sender: Any) {
        print("lookOverButton tapped")
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        scnView.pointOfView? = lookOverCameraNode
        scnView.pointOfView?.constraints = [SCNLookAtConstraint(target: fieldNode)]
        menuBar.frame = CGRect(x: 0, y: 0, width: 130, height: 60)
        cursorView.isHidden = true
        debugPrint(lookOverCameraNode)      // DEBUG
        SCNTransaction.commit()
    }
    
    // 俯瞰視点カメラの作成
    func initLookOverCamera(){
        lookOverCameraNode = SCNNode()
        lookOverCameraNode.camera = SCNCamera()
        lookOverCameraNode.name = "lookOverCameraNode"
        lookOverCameraNode.position = SCNVector3(x: 24, y: 24, z: 16)
        lookOverCameraNode.camera?.xFov = 0
        lookOverCameraNode.camera?.yFov = 0
        lookOverCameraNode.camera?.zFar = 90
        lookOverCameraNode.eulerAngles = SCNVector3Make(-1.5, 1.57, 0)
    }
    
    // 主観ビュー
    @IBAction func btnSubjectiveView(_ sender: Any) {
        print("subjectiveButton tapped")
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        scnView.pointOfView? = subjectiveCameraNode
        debugPrint(subjectiveCameraNode)     // DEBUG
        scnView.subviews[0].frame = CGRect(x: 0, y: 0, width: 130, height: 180)
        scnView.subviews[0].subviews[2].isHidden = false

        SCNTransaction.commit()
        debug()
    }
    
    func initSubjectiveCamera(){
        subjectiveCameraNode = SCNNode()
        subjectiveCameraNode.camera = SCNCamera()
        subjectiveCameraNode.name = "subjectiveCameraNode"
        subjectiveCameraNode.position = SCNVector3(x: cameraX, y: cameraY, z: cameraZ)
        subjectiveCameraNode.eulerAngles = SCNVector3(x: cameraRotateX, y: cameraRotateY, z: cameraRotateZ)
        subjectiveCameraNode.camera?.yFov = cameraYFov
        subjectiveCameraNode.camera?.xFov = cameraXFov
    }
    
    @IBAction func btnAllowUp(_ sender: Any) {

        var cameraPosition = subjectiveCameraNode.position
        var cameraAngle    = subjectiveCameraNode.eulerAngles
        
        debugPrint(cameraPosition)
        debugPrint(cameraAngle)
        
        cameraPosition.x = cameraPosition.x + 1.0
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        subjectiveCameraNode.position = cameraPosition
        SCNTransaction.commit()
        
    }
    @IBAction func btnAllowDown(_ sender: Any) {
    }

    @IBAction func btnAllowRight(_ sender: Any) {
    }
    @IBAction func btnAllowLeft(_ sender: Any) {
    }
    
    
    
    
    var scene            : SCNScene!
    
    // カメラ
    var lookOverCameraNode      : SCNNode!
    var subjectiveCameraNode    : SCNNode!
    
    var cameraX                 : Float!    = 18
    var cameraY                 : Float!    = 1.4
    var cameraZ                 : Float!    = 20
    var cameraXFov              : Double!   = 0
    var cameraYFov              : Double!   = 0
    var cameraRotateX           : Float!    = 0
    var cameraRotateY           : Float!    = 0
    var cameraRotateZ           : Float!    = 0
//    var cameraRotateW           : Float!
    
    var fieldSizeX              : Int = 24
    var fieldSizeY              : Int = 32
    var fieldNode : SCNNode!
    
    var lockCamera = false
    var defaultFov = 0.0
    
    func getBunkerData() -> Array<Array<Int>>{
        let bunkerArray = [
            [11,1,1],
            [1,2,1],[8,2,1],[18,2,1],
            [8,3,1],
            [4,4,1],[5,4,1],
            [11,5,2],[12,5,1],
            [7,6,1],[14,6,1],
            [3,7,1],
            [0,8,1],[15,8,2],
            [5,9,1],[8,9,2],[9,9,1],[12,9,1],[15,9,1],
            [5,10,1],[12,10,2],[20,10,2],
            [2,11,2],[17,11,2],[20,11,1],
            [2,12,1],[7,12,2],[14,12,1],[17,12,1],
            [7,13,1],[10,13,1],[11,13,2],
            [3,14,1],
            [5,15,1],[6,15,2],[9,15,1],[14,15,2],[21,15,1],
            [2,16,1],[9,16,2],[14,16,1],[17,16,2],[18,16,1]
        ]
        
        return bunkerArray
    }

    func createBunker (x: Int, y: Int, z: Int) -> SCNNode{
        let bunkerNode = SCNNode()
        let bunkerGeometry = SCNBox(width: 1.1, height: 1, length: 1.1, chamferRadius: 0.1)
        bunkerNode.geometry = bunkerGeometry
        //        let textGeometry = SCNText(string: "a", extrusionDepth: 0.1)
        //        textGeometry.font = UIFont(name: "Migu 1M", size: 1)
        //        bunkerNode.geometry = textGeometry
        
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
        bunkerNode.geometry?.materials = materials
        
        bunkerNode.position = SCNVector3Make(35 - Float(x) + 1, Float(z) - 0.2, Float(y) + 0.5)
        
        return bunkerNode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnView.delegate = self
        
        // シーンの作成
        scene = SCNScene()
        scnView.scene = scene
        
        // 俯瞰視点カメラの作成
        initLookOverCamera()
        scene.rootNode.addChildNode(lookOverCameraNode)
        scnView.pointOfView = lookOverCameraNode
        
        // 主観視点カメラの作成
        initSubjectiveCamera()
        scene.rootNode.addChildNode(subjectiveCameraNode)
        
        // 光源の作成
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: -5, y: 20, z: 15)
        scene.rootNode.addChildNode(lightNode)
        
        // フィールドの設定
        fieldNode = SCNNode()
        let field = SCNBox(
            width: CGFloat(fieldSizeX + 1),
            height: 0.1,
            length: CGFloat(fieldSizeY + 1),
            chamferRadius: 0.0)
        field.firstMaterial?.diffuse.contents = UIColor.green
        fieldNode.geometry = field
        fieldNode.position = SCNVector3(x: 24, y: 0, z: 16)
        
        // カメラの制約
        let lookAtConstraint = SCNLookAtConstraint(target: fieldNode)
        debugPrint(lookAtConstraint)
        scnView.pointOfView?.constraints = [lookAtConstraint]
        scene.rootNode.addChildNode(fieldNode)
        
        // バンカーの作成
        let fieldArray = getBunkerData()
        fieldArray.forEach {
            let bunkerPosition = $0
            scene.rootNode.addChildNode(createBunker(x: bunkerPosition[0], y: bunkerPosition[1], z: 1))
            scene.rootNode.addChildNode(createBunker(x: fieldSizeX - bunkerPosition[0], y: fieldSizeY - bunkerPosition[1], z: 1))
            if bunkerPosition[2] == 2{
                scene.rootNode.addChildNode(createBunker(x: bunkerPosition[0], y: bunkerPosition[1], z: 2))
                scene.rootNode.addChildNode(createBunker(x: fieldSizeX - bunkerPosition[0], y: fieldSizeY - bunkerPosition[1], z: 2))
            }
        }
        
        //        scene.rootNode.addChildNode(createBunker(x: 0, y: 0, z: 1))
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.darkGray
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        
        
        
        ///////////////////////
//        btnLookOverView(UIButton)
        btnSubjectiveView(UIButton)

    }
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        print("view tapped")
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    func debug(){
        let scnView = self.view as! SCNView
        print("#############################################################")
        print("scnView.pointOfView?.name          :", scnView.pointOfView?.name ?? "None")
        print("scnView.pointOfView?.position      :", scnView.pointOfView?.position ?? "None")
        print("scnView.pointOfView?.eulerAngles   :", scnView.pointOfView?.eulerAngles ?? "None")
        print("scnView.pointOfView?.rotation      :", scnView.pointOfView?.rotation ?? "None")
        print("scnView.pointOfView?.camera.zFar   :", scnView.pointOfView?.camera?.zFar ?? "None")
        print("scnView.pointOfView?.camera.xFov   :", scnView.pointOfView?.camera?.xFov ?? "None")
        print("scnView.pointOfView?.camera.yFov   :", scnView.pointOfView?.camera?.yFov ?? "None")
        print("#############################################################")
        print("lookOverCameraNode?.name           :", lookOverCameraNode.name ?? "None")
        print("lookOverCameraNode?.position       :", lookOverCameraNode?.position ?? "None")
        print("lookOverCameraNode?.eulerAngles    :", lookOverCameraNode?.eulerAngles ?? "None")
        print("lookOverCameraNode?.rotation       :", lookOverCameraNode?.rotation ?? "None")
        print("lookOverCameraNode?.camera.zFar    :", lookOverCameraNode?.camera?.zFar ?? "None")
        print("lookOverCameraNode?.camera.xFov    :", lookOverCameraNode?.camera?.xFov ?? "None")
        print("lookOverCameraNode?.camera.yFov    :", lookOverCameraNode?.camera?.yFov ?? "None")
        print("#############################################################")
        print("subjectiveCameraNode?.name         :", subjectiveCameraNode.name ?? "None")
        print("subjectiveCameraNode?.position     :", subjectiveCameraNode?.position ?? "None")
        print("subjectiveCameraNode?.eulerAngles  :", subjectiveCameraNode?.eulerAngles ?? "None")
        print("subjectiveCameraNode?.rotation     :", subjectiveCameraNode?.rotation ?? "None")
        print("subjectiveCameraNode?.camera.zFar  :", subjectiveCameraNode?.camera?.zFar ?? "None")
        print("subjectiveCameraNode?.camera.xFov  :", subjectiveCameraNode?.camera?.xFov ?? "None")
        print("subjectiveCameraNode?.camera.yFov  :", subjectiveCameraNode?.camera?.yFov ?? "None")
        print("#############################################################")
        
    }
    
    
}
