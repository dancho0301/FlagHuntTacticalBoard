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
//    @IBOutlet var cursorView: UIView!

    let DEBUG = false
    
    var scene            : SCNScene!
    
    // カメラ
    var lookOverCameraNode      : SCNNode!
    var subjectiveCameraNode    : SubjectiveCameraNode!
    
    var cameraPosition          = SCNVector3(x: 2, y: 1.4, z: 6)
    
    var cameraXFov              : Float!   = 0
    var cameraYFov              : Float!   = 0
    
    var cameraAngle             = SCNVector3(x: 0, y: -Float(M_PI), z: 0)
    
    var testNode                : SCNNode!
    
    var fieldSizeX              : Int = 24
    var fieldSizeY              : Int = 32
    var fieldNode : SCNNode!
    
    var lockCamera = false
    var defaultFov = 0.0
    
    // 俯瞰ビュー
    @IBAction func btnLookOverView(_ sender: Any) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        scnView.pointOfView? = lookOverCameraNode
        scnView.pointOfView?.constraints = [SCNLookAtConstraint(target: fieldNode)]
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
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        scnView.pointOfView? = subjectiveCameraNode
        SCNTransaction.commit()
    }
    
    func initSubjectiveCamera(){
        subjectiveCameraNode = SubjectiveCameraNode(position: cameraPosition, angle: cameraAngle)
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
            [9, 4, 1], [9, 9, 1], [9, 14, 1], [9, 17, 2],
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
    
    func getStartArea() -> Array<Array<Int>>{
        let startArea = [
            [4, 21], [4, 22], [4, 23],
            [5, 21], [5, 22], [5, 23],
            [6, 21], [6, 22], [6, 23]
        ]
        return startArea
    }

    func getFlagArea() -> Array<Array<Int>>{
        let flagArea = [
            [14, 2, 1], [14, 3, 1], [14, 4, 1],
            [15, 2, 1], [15, 3, 2], [15, 4, 1],
            [15, 19, 1], [15, 20, 1], [15, 21, 1]
        ]
        return flagArea
    }


    /////////////////////////////////////
    // バンカーの作成
    /////////////////////////////////////
    func createBunker (x: Float, y: Float, z: Float) -> SCNNode{
        let bunkerNode = BunkerNode()
        bunkerNode.position = SCNVector3Make(y, z - 0.5, x)
        
        // ２段めのバンカーはオレンジにする
        // 俯瞰視点でわかりやすいように。
        if z == 2 {
            bunkerNode.setUpperBunker()
        }

        return bunkerNode
    }

    func createStartArea (x: Float, y: Float) -> SCNNode{
        let startNode = SCNNode()
        let startGeometry = SCNPyramid(width: 1, height: 0.1, length: 1)
        startGeometry.firstMaterial?.diffuse.contents = UIColor.yellow
        startNode.geometry = startGeometry
        startNode.position = SCNVector3Make(y, 0.05, x)

        return startNode
    }

    func createFlagArea (x: Float, y: Float, z: Float) -> SCNNode{
        let flagNode = SCNNode()
        let flagGeometry = SCNPyramid(width: 1, height: 0.1, length: 1)
        flagGeometry.firstMaterial?.diffuse.contents = UIColor.red
        flagNode.geometry = flagGeometry
        flagNode.position = SCNVector3Make(y, 0.05, x)
        
        
        if z == Float(2){
            let flagNode2 = SCNNode()
            let flagGeometry2 = SCNCylinder(radius: 0.1, height: 10)
            flagGeometry2.firstMaterial?.diffuse.contents = UIColor.red
            flagNode2.geometry = flagGeometry2
            flagNode2.opacity = 0.5
            flagNode.addChildNode(flagNode2)
        }
        return flagNode
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
        lightNode.position = SCNVector3(x: 15, y: 20, z: 15)
        scene.rootNode.addChildNode(lightNode)
        
        // フィールドの設定
        fieldNode = FieldNode(x: fieldSizeX, y: fieldSizeY)
        
        
        ///////////////////////////////////////////////////////////////
        if DEBUG {
            // デバッグ用のポール（あとで消す）
            let testNode1 = SCNNode()
            let testNode1Geometry = SCNBox(width: 1, height: 10, length: 1, chamferRadius: 0)
            testNode1Geometry.firstMaterial?.diffuse.contents = UIColor.red
            testNode1.geometry = testNode1Geometry
            testNode1.position = SCNVector3(x: 0.5, y: 0, z: 0.5)
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
        }
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
                x: Float(bunkerPosition[0]) + 0.5,
                y: Float(fieldSizeX - bunkerPosition[1]) - 0.5,
                z: 1)
            )
            scene.rootNode.addChildNode(createBunker(
                x: Float(fieldSizeY - bunkerPosition[0]) - 0.5,
                y: Float(bunkerPosition[1]) + 0.5,
                z: 1)
            )
            if bunkerPosition[2] == 2{
                scene.rootNode.addChildNode(createBunker(
                    x: Float(bunkerPosition[0]) + 0.5,
                    y: Float(fieldSizeX - bunkerPosition[1]) - 0.5,
                    z: 2)
                )
                scene.rootNode.addChildNode(createBunker(
                    x: Float(fieldSizeY - bunkerPosition[0]) - 0.5,
                    y: Float(bunkerPosition[1]) + 0.5,
                    z: 2)
                )
            }
        }
        
        // スタートエリア
        let startAreaArray = getStartArea()
        startAreaArray.forEach(){
            let startAreaPosition = $0
            scene.rootNode.addChildNode(createStartArea(
                x: Float(startAreaPosition[0]) + 0.5,
                y: Float(fieldSizeX - startAreaPosition[1]) - 0.5
                )
            )
            scene.rootNode.addChildNode(createStartArea(
                x: Float(fieldSizeY - startAreaPosition[0]) - 0.5,
                y: Float(startAreaPosition[1]) + 0.5
                )
            )
        }
        
        // フラッグエリア
        let flagAreaArray = getFlagArea()
        flagAreaArray.forEach(){
            let flagAreaPosition = $0
            scene.rootNode.addChildNode(createFlagArea(
                x: Float(flagAreaPosition[0]) + 0.5,
                y: Float(fieldSizeX - flagAreaPosition[1]) - 0.5,
                z: Float(flagAreaPosition[2])
                )
            )
            scene.rootNode.addChildNode(createFlagArea(
                x: Float(fieldSizeY - flagAreaPosition[0]) - 0.5,
                y: Float(flagAreaPosition[1]) + 0.5,
                z: Float(flagAreaPosition[2])
                )
            )
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

        menuBar.frame = CGRect(x: 0, y: 0, width: 130, height: 60)

    }
    
    
    // タップしたらカメラを移動する
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
//        print("view tapped")
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        if hitResults.count > 0 {
            let result = hitResults[0] as SCNHitTestResult
            
            
            let tappedNode = result.node
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
