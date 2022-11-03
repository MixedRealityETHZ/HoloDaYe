//
//  ViewController.swift
//  app-demo
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import CoreMotion
//import LocoKitCore


class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, CLLocationManagerDelegate {


    let locationManager = CLLocationManager()
    var currentLocation:CLLocation!
    var lock = NSLock()
    
    let motionManager = CMMotionManager()
    var timer: Timer!
    
    
    // MARK: - IBOutlets

    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
//    ARSCNView is a SceneKit view that includes a ARSession Object
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!

        // Set the scene to the view
//        sceneView.scene = scene
        
        // MARK: - Localization
        locationManager.delegate = self
        // location accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Get localizaiton again after moving some distance
        locationManager.distanceFilter = 10
        // Authorization
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        print("Localization")
        
        // MARK: - Motion
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startDeviceMotionUpdates()

        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ViewController.motionupdate), userInfo: nil, repeats: true)
        
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
     //MARK: - CLlocationDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lock.lock()
        currentLocation = locations.last                        //注意：获取集合中最后一个位置（最新的位置）
        print("latitude：\(currentLocation.coordinate.latitude)")
        print("longitude：\(currentLocation.coordinate.longitude)")
        print("altitude: \(currentLocation.altitude)")
        lock.unlock()
 
    }
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("localization error\(error)")
    }
    
    
    //MARK: - CMMotion update
    // to objective c
    @objc func motionupdate() {
        if let accelerometerData = motionManager.accelerometerData {
            print("Accelerometer: \(accelerometerData)")
        }
        if let gyroData = motionManager.gyroData {
            print("Gyroscope: \(gyroData)")
        }
//        if let magnetometerData = motionManager.magnetometerData {
//            print(magnetometerData)
//        }
        if let deviceMotion = motionManager.deviceMotion {
            print("Device Motion: \(deviceMotion)")
        }
    }

}
