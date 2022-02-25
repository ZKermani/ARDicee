//
//  ViewController.swift
//  ARDicee
//
//  Created by Zahra Sadeghipoor on 2/23/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    private var diceArray = [SCNNode]()
    
    // MARK: - App lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            
            // create a vritual plane using the detected plane dimensions
            let scnPlane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            // material for the node
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            scnPlane.materials = [material]
            
            // create a node using the position of the detected plane
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
            planeNode.geometry = scnPlane
            
        } else {
            return
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            // Check if an existing object was tapped
            if let nodeHitTest = sceneView.hitTest(touch.location(in: sceneView), options: nil).first {
                let nodeTapped = nodeHitTest.node
                if diceArray.contains(nodeTapped) {
                    roll(nodeTapped)
                    return
                }
            }
            
            // Check if a real horizontal plane was tapped
            if let planeHitTest = sceneView.hitTest(touch.location(in: sceneView), types: .estimatedHorizontalPlane).first {
                let position = SCNVector3(planeHitTest.worldTransform.columns.3.x,
                                          planeHitTest.worldTransform.columns.3.y,
                                          planeHitTest.worldTransform.columns.3.z)
                addDiceNode(at: position)
                return
            }
        } else {
            print("Error in detecting the touch")
        }
    }
    
    // MARK: - Dice methods
    func addDiceNode(at position: SCNVector3) {
        let scene = SCNScene(named: "diceCollada.scn")!
        if let node = scene.rootNode.childNode(withName: "Dice", recursively: true) {
            node.position = position
            diceArray.append(node)
            roll(node)
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    
    func roll(_ dice: SCNNode) {
        if diceArray.contains(dice) {
            let rotateX = Float(arc4random_uniform(4) + 1) * Float.pi / 2
            let rotateZ = Float(arc4random_uniform(4) + 1) * Float.pi / 2
            dice.runAction(SCNAction.rotateBy(x: CGFloat(rotateX * 5),
                                              y: 0,
                                              z: CGFloat(rotateZ * 5),
                                              duration: 0.5)
            )
        }
    }
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice)
            }
        }
    }
    @IBAction func refresshPressed(_ sender: UIBarButtonItem) {
        rollAll()
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func trashPressed(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
}
