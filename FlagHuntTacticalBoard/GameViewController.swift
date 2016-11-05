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
    @IBOutlet var debugArea: UITextView!

    var scene            : SCNScene!
    
    // カメラ
    var lookOverCameraNode      : SCNNode!
    var subjectiveCameraNode    : SubjectiveCameraNode!
    
    var cameraPosition = SCNVector3(x: 5, y: 1.4, z: 1)
    
    var cameraXFov              : Float!   = 0
    var cameraYFov              : Float!   = 0
    
    var cameraAngle    = SCNVector3(x: 0, y: -Float(M_PI), z: 0)
    
    var testNode                : SCNNode!
    
    var fieldSizeX              : Int = 24
    var fieldSizeY              : Int = 32
    var fieldNode : SCNNode!
    
    var lockCamera = false
    var defaultFov = 0.0

    // デバッグボタン
    @IBAction func btnDebug(_ sender: Any) {
        let scnView = self.view as! SCNView
        debug()
//        print("*****************************")
//        print(scnView.pointOfView?.name ?? "None")
//        print(lookOverCameraNode)
//        print(subjectiveCameraNode)
//        print("*****************************")
    }
    
    @IBAction func btnTest(_ sender: Any) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2
//        cameraRotateY = cameraRotateY + Float(M_PI_2)
        let _euler = subjectiveCameraNode.eulerAngles
        subjectiveCameraNode.eulerAngles = SCNVector3(x: _euler.x, y: _euler.y + Float(M_PI_2), z: _euler.z)
        SCNTransaction.commit()
//        debug()
    }
    
    // 俯瞰ビュー
    @IBAction func btnLookOverView(_ sender: Any) {
//        print("lookOverButton tapped")
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        scnView.pointOfView? = lookOverCameraNode
        scnView.pointOfView?.constraints = [SCNLookAtConstraint(target: fieldNode)]
//      テスト中は俯瞰でもカメラを操作する
        menuBar.frame = CGRect(x: 0, y: 0, width: 130, height: 60)
        cursorView.isHidden = true
//        debugPrint(lookOverCameraNode)      // DEBUG
        SCNTransaction.commit()
    }
    
    // 俯瞰視点カメラの作成
    func initLookOverCamera(){
        lookOverCameraNode = SCNNode()
        lookOverCameraNode.camera = SCNCamera()
        lookOverCameraNode.name = "lookOverCameraNode"
        lookOverCameraNode.position = SCNVector3(x: Float(fieldSizeX)/2, y: 24, z: Float(fieldSizeY)/2)
        lookOverCameraNode.camera?.xFov = 0
        lookOverCameraNode.camera?.yFov = 0
        lookOverCameraNode.camera?.zFar = 90
        lookOverCameraNode.eulerAngles = SCNVector3Make(-1.5, 1.57, 0)
    }
    
    // 主観ビュー
    @IBAction func btnSubjectiveView(_ sender: Any) {
//        print("subjectiveButton tapped")
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        scnView.pointOfView? = subjectiveCameraNode
//        debugPrint(subjectiveCameraNode)     // DEBUG
//        menuBar.frame = CGRect(x: 0, y: 0, width: 130, height: 180)
//        cursorView.subviews[2].isHidden = false
        menuBar.frame = CGRect(x: 0, y: 0, width: 130, height: 60)
        cursorView.isHidden = true

        SCNTransaction.commit()
//        debug()
    }
    
    func initSubjectiveCamera(){
//        subjectiveCameraNode = SCNNode()
        
        
        subjectiveCameraNode = SubjectiveCameraNode(position: cameraPosition, angle: cameraAngle)

        // Debug
        testNode = SCNNode()
    }
    
    
    /////////////////////////////////////
    // 矢印ボタンの動作
    /////////////////////////////////////

    @IBAction func btnAllowUp(_ sender: Any) {
        subjectiveCameraNode.move(vector: "UP")
    }
    @IBAction func btnAllowDown(_ sender: Any) {
        subjectiveCameraNode.move(vector: "DOWN")
    }

    @IBAction func btnAllowRight(_ sender: Any) {
        subjectiveCameraNode.move(vector: "RIGHT")
    }
    @IBAction func btnAllowLeft(_ sender: Any) {
        subjectiveCameraNode.move(vector: "LEFT")
    }
    
    
    /////////////////////////////////////
    // バンカー位置の配列を取得する
    // いずれは設定可能にするため、関数で定義
    /////////////////////////////////////
    func getBunkerData() -> Array<Array<Int>>{
        let bunkerArray = [
            [0, 6, 1],
            [1, 12, 1],
            [2, 9, 1],
            [3, 6, 1], [3, 14,1],
            [4, 3, 1],
            [5, 8, 1], [5, 11, 1],
            [6, 5, 1], [6, 15, 1],
            [7, 9, 1], [7, 12, 1],
            [8, 4, 2], [8, 7, 1], [8, 17, 1],
            [9, 4, 1], [8, 7, 1], [8, 17, 1],
            [10,2, 1], [10,11, 2], [10, 14, 2],
            [11,6, 2], [11, 7, 1], [11, 16, 1], [11, 19, 2],
            [12, 0, 1],[12, 3, 1],[12, 10, 1], [12, 19,1],
            [13, 8,1], [13, 13, 1],
            [14, 5, 1], [14, 8, 2], [14, 13, 2],
            [14, 15, 1], [14, 16, 2], [14, 20, 1],
            [15, 10, 1]
        ]
        
        return bunkerArray
    }

    /////////////////////////////////////
    // バンカーの作成
    /////////////////////////////////////
    func createBunker (x: Int, y: Int, z: Int) -> SCNNode{
        let bunkerNode = BunkerNode()
        bunkerNode.position = SCNVector3Make(Float(y), Float(z) - 0.2, Float(x))
        
        // ２段めのバンカーはオレンジにする
        // 俯瞰視点でわかりやすいように。
        if z == 2 {
            bunkerNode.setUpperBunker()
        }
        
        return bunkerNode
    }

    /////////////////////////////////////
    // 初期化
    /////////////////////////////////////
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
        fieldNode = FieldNode(x: fieldSizeX, y: fieldSizeY)
        
        
        ///////////////////////////////////////////////////////////////
        // デバッグ用のポール（あとで消す）
        let testNode1 = SCNNode()
        let testNode1Geometry = SCNBox(width: 1, height: 10, length: 1, chamferRadius: 0)
        testNode1Geometry.firstMaterial?.diffuse.contents = UIColor.red
        testNode1.geometry = testNode1Geometry
        testNode1.position = SCNVector3(x: 0, y: 0, z: 0)
        scene.rootNode.addChildNode(testNode1)
        let testNode2 = SCNNode()
        let testNode2Geometry = SCNBox(width: 1, height: 10, length: 1, chamferRadius: 0)
        testNode2Geometry.firstMaterial?.diffuse.contents = UIColor.blue
        testNode2.geometry = testNode2Geometry
        testNode2.position = SCNVector3(x: Float(fieldSizeX), y: 0, z: Float(fieldSizeY))
        scene.rootNode.addChildNode(testNode2)
        let testNode3 = SCNNode()
        let testNode3Geometry = SCNBox(width: 1, height: 10, length: 1, chamferRadius: 0)
        testNode3Geometry.firstMaterial?.diffuse.contents = UIColor.yellow
        testNode3.geometry = testNode3Geometry
        testNode3.position = SCNVector3(x: 0, y: 0, z: Float(fieldSizeY))
        scene.rootNode.addChildNode(testNode3)
        ///////////////////////////////////////////////////////////////
        
        // カメラの制約
        let lookAtConstraint = SCNLookAtConstraint(target: fieldNode)
        scnView.pointOfView?.constraints = [lookAtConstraint]
        scene.rootNode.addChildNode(fieldNode)
        
        // バンカーの作成
        let fieldArray = getBunkerData()
        fieldArray.forEach {
            let bunkerPosition = $0
            scene.rootNode.addChildNode(createBunker(
                x: bunkerPosition[0],
                y: fieldSizeX - bunkerPosition[1],
                z: 1)
            )
            scene.rootNode.addChildNode(createBunker(
                x: fieldSizeY - bunkerPosition[0],
                y: bunkerPosition[1],
                z: 1)
            )
            if bunkerPosition[2] == 2{
                scene.rootNode.addChildNode(createBunker(
                    x: bunkerPosition[0],
                    y: fieldSizeX - bunkerPosition[1],
                    z: 2)
                )
                scene.rootNode.addChildNode(createBunker(
                    x: fieldSizeY - bunkerPosition[0],
                    y: bunkerPosition[1],
                    z: 2)
                )
            }
        }
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        
        // configure the view
        scnView.backgroundColor = UIColor.darkGray
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        scnView.addGestureRecognizer(panGesture)
        
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(PanCodeViewController.panView(_:)))  //Swift2.2以前
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(PanCodeViewController.panView(sender:)))  //Swift3
        
        ///////////////////////
        btnLookOverView(UIButton())
//        btnSubjectiveView(UIButton())

    }
    
    
    // タップしたらカメラを移動する
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
//        print("view tapped")
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        if hitResults.count > 0 {
            let result = hitResults[0] as SCNHitTestResult
            
            
            var tappedNode = result.node
            if tappedNode.name == "fieldNode"{
                print("################################")
                debugPrint(tappedNode)
                print("localNormal", result.localNormal)
                print("localCoordinates", result.localCoordinates)
                print("worldNormal", result.worldNormal)
                print("worldCoordinates", result.worldCoordinates)
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1
                
                subjectiveCameraNode.position = Utility.addVector3(vector1: result.worldCoordinates, vector2: SCNVector3(x: 0, y: 1.5, z: 0))
                
                SCNTransaction.commit()
            }
        }
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        let p = sender.translation(in: scnView)
        
        let _acceleration: Float = 10000
        let vec = SCNVector3(x: 0, y: Float(p.x)/_acceleration, z: 0)
        
        
        subjectiveCameraNode.eulerAngles = Utility.addVector3(vector1: subjectiveCameraNode.eulerAngles, vector2: vec)
        
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
//        let scnView = self.view as! SCNView
//        print("#############################################################")
//        print("scnView.pointOfView?.name          :", scnView.pointOfView?.name ?? "None")
//        print("scnView.pointOfView?.position      :", scnView.pointOfView?.position ?? "None")
//        print("scnView.pointOfView?.eulerAngles   :", scnView.pointOfView?.eulerAngles ?? "None")
//        print("scnView.pointOfView?.rotation      :", scnView.pointOfView?.rotation ?? "None")
//        print("scnView.pointOfView?.camera.zFar   :", scnView.pointOfView?.camera?.zFar ?? "None")
//        print("scnView.pointOfView?.camera.xFov   :", scnView.pointOfView?.camera?.xFov ?? "None")
//        print("scnView.pointOfView?.camera.yFov   :", scnView.pointOfView?.camera?.yFov ?? "None")
//        print("#############################################################")
//        print("lookOverCameraNode?.name           :", lookOverCameraNode.name ?? "None")
//        print("lookOverCameraNode?.position       :", lookOverCameraNode?.position ?? "None")
//        print("lookOverCameraNode?.eulerAngles    :", lookOverCameraNode?.eulerAngles ?? "None")
//        print("lookOverCameraNode?.rotation       :", lookOverCameraNode?.rotation ?? "None")
//        print("lookOverCameraNode?.camera.zFar    :", lookOverCameraNode?.camera?.zFar ?? "None")
//        print("lookOverCameraNode?.camera.xFov    :", lookOverCameraNode?.camera?.xFov ?? "None")
//        print("lookOverCameraNode?.camera.yFov    :", lookOverCameraNode?.camera?.yFov ?? "None")
        print("#############################################################")
        print("subjectiveCameraNode?.name         :", subjectiveCameraNode.name ?? "None")
        print("subjectiveCameraNode?.position     :", subjectiveCameraNode?.position ?? "None")
        print("subjectiveCameraNode?.eulerAngles  :", subjectiveCameraNode?.eulerAngles ?? "None")
        print("subjectiveCameraNode?.rotation     :", subjectiveCameraNode?.rotation ?? "None")
        print("subjectiveCameraNode?.camera.zFar  :", subjectiveCameraNode?.camera?.zFar ?? "None")
        print("subjectiveCameraNode?.camera.xFov  :", subjectiveCameraNode?.camera?.xFov ?? "None")
        print("subjectiveCameraNode?.camera.yFov  :", subjectiveCameraNode?.camera?.yFov ?? "None")
        print("#############################################################")
        print("subjectiveCameraNode?.name         :", subjectiveCameraNode.markerNode.name ?? "None")
        print("subjectiveCameraNode?.position     :", subjectiveCameraNode?.markerNode.position ?? "None")
        print("subjectiveCameraNode?.eulerAngles  :", subjectiveCameraNode?.markerNode.eulerAngles ?? "None")
        print("subjectiveCameraNode?.rotation     :", subjectiveCameraNode?.markerNode.rotation ?? "None")
//        print("subjectiveCameraNode?.camera.zFar  :", subjectiveCameraNode?.markerNode.camera?.zFar ?? "None")
//        print("subjectiveCameraNode?.camera.xFov  :", subjectiveCameraNode?.markerNode.camera?.xFov ?? "None")
//        print("subjectiveCameraNode?.camera.yFov  :", subjectiveCameraNode?.markerNode.camera?.yFov ?? "None")
        print("#############################################################")
        
        
        
    }
    
    
}
