//
//  GameViewController.swift
//  Game Practice
//
//  Created by Роман Поспелов on 15.09.2020.
//  Copyright © 2020 Roman Pospelov. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scnView: SCNView!
    
    // Set animation duration
    var duration: TimeInterval = 5
    
    // Score count
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // create a new scene
    let scene = SCNScene(named: "art.scnassets/ship.scn")!
    
    // Gesture recognizer
    var tapGesture: UITapGestureRecognizer!
    
    // The ship
    var ship: SCNNode!
    
    // Computed property
    var getShip: SCNNode? {
        scene.rootNode.childNode(withName: "ship", recursively: true)
    }
    
    func removeShip() {
        getShip?.removeFromParentNode()
    }
    
    func spanShip() {
        ship = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.clone()
        
        // Add ship to the scene
        scene.rootNode.addChildNode(ship)
        
        // Position the ship
        let x = Int.random(in: -25 ... 25)
        let y = Int.random(in: -25 ... 25)
        let z = -105
        let position = SCNVector3(x, y, z)
        ship.position = position
        
        // Look at position
        let lookAtPosition = SCNVector3(2 * x, 2 * y, 2 * z)
        ship.look(at: lookAtPosition)

        // Animate the ship
        ship.runAction(.move(to: SCNVector3(), duration: duration)) {
            print(#line, #function, "Animation ended")
            self.removeShip()
            DispatchQueue.main.async {
                self.scnView.removeGestureRecognizer(self.tapGesture)
                self.scoreLabel.text = "Game Over!\nScore: \(self.score)"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove the ship
        removeShip()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
//        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // animate the 3d object
//        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        spanShip()
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.25
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                self.ship.removeAllActions()
                self.removeShip()
                print(#line, #function, "Ship removed")
                
                // Increase the tempo
                self.duration *= 0.9
//                self.duration = 10
                
                // Increase the score
                self.score += 1
                
                self.spanShip()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
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

}
