//
//  ViewController.swift
//  arruler
//
//  Created by Thiago Antonio Ramalho on 16/01/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private var dotNodesList = [SCNNode]()
    
    private var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //show debug options
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    fileprivate func resetIfNeeded() {
        if dotNodesList.count > 1 {
            
            for dotNode in dotNodesList {
                dotNode.removeFromParentNode()
            }
            
            textNode.removeFromParentNode()
            dotNodesList.removeAll()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if  let touchLocation = touches.first?.location(in: sceneView) {
            
            guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) else {return}
            
            let results = sceneView.session.raycast(query)
            
            if let safeResult = results.first {
                
                resetIfNeeded()
                
                addDot(safeResult)
                
            }
        }
    }
    
    fileprivate func addDot(_ safeResult: ARRaycastResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(
            safeResult.worldTransform.columns.3.x,
            safeResult.worldTransform.columns.3.y,
            safeResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodesList.append(dotNode)
        
        if dotNodesList.count > 1 {
            calculate()
        }
    }
    
    fileprivate func calculate() {
        guard let start = dotNodesList.first else { return }
        guard let end = dotNodesList.last else {return }
        
        print(start)
        print(end)
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        
        
        updateText(text: "\(abs(distance))", position: end.position)
    }
    
    private func updateText(text: String, position: SCNVector3) {
                
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, 0)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
        
    }
    
}
