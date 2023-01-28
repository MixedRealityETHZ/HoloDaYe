//
//  POIViewController.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import ARCL
import ARKit
import MapKit
import SceneKit
import UIKit
import CoreLocation
import SwiftSocket

@available(iOS 15.0, *)
/// Displays Points of Interest in ARCL
class POIViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet weak var nodePositionLabel: UILabel!

    @IBOutlet var contentView: UIView!
    let sceneLocationView = SceneLocationView()

    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?

    var updateUserLocationTimer: Timer?
    var updateInfoLabelTimer: Timer?

    var centerMapOnUserLocation: Bool = true
    var routes: [MKRoute]?
    var peakValueMap: [MKPointAnnotation]?
    
    var peakValue: [LocationNode]!
    var selectPeakLayer: LocationNode?
    var selectMapPoint: LocationNode?
    var altLayer:LocationNode?
    
    var offset: Double!
    
    // for search on map
    var placeMark: CLPlacemark!
    var selectPin: MKPlacemark? = nil
    private var completer: MKLocalSearchCompleter = MKLocalSearchCompleter()

    var showMap = false {
        didSet {
            guard let mapView = mapView else {
                return
            }
            mapView.isHidden = !showMap
        }
    }
    
    var northClibration: Bool!
    var showAllPeaks: Bool!

    /// Whether to display some debugging data
    /// This currently displays the coordinate of the best location estimate
    /// The initial value is respected
    let displayDebugging = false

    var adjustNorthByTappingSidesOfScreen: Bool!
    let addNodeByTappingScreen = false

    class func loadFromStoryboard() -> POIViewController {
        return UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ARCLViewController") as! POIViewController
        // swiftlint:disable:previous force_cast
    }


    override func viewDidLoad() {
        super.viewDidLoad()

//        // swiftlint:disable:next discarded_notification_center_observer
//        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification,
//                                               object: nil,
//                                               queue: nil) { [weak self] _ in
//												self?.pauseAnimation()
//        }
//        // swiftlint:disable:next discarded_notification_center_observer
//        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
//                                               object: nil,
//                                               queue: nil) { [weak self] _ in
//												self?.restartAnimation()
//        }
        
//        print("Peakvalue in POIVC", peakValue as Any)
		updateInfoLabelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
			self?.updateInfoLabel()
		}

        // Set to true to display an arrow which points north.
        // Checkout the comments in the property description and on the readme on this.
        sceneLocationView.orientToTrueNorth = !northClibration
//        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly

        sceneLocationView.showAxesNode = false
        sceneLocationView.showFeaturePoints = displayDebugging
        sceneLocationView.locationNodeTouchDelegate = self
//        sceneLocationView.delegate = self // Causes an assertionFailure - use the `arViewDelegate` instead:
        sceneLocationView.arViewDelegate = self
        sceneLocationView.locationNodeTouchDelegate = self

        // Now add the route or location annotations as appropriate
        addSceneModels()

        contentView.addSubview(sceneLocationView)
        sceneLocationView.frame = contentView.bounds

        mapView.isHidden = !showMap

        if showMap {
            updateUserLocationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                self?.updateUserLocation()
            }
            
            
            //            routes?.forEach { mapView.addOverlay($0.polyline) }
            if showAllPeaks{
                peakValueMap?.forEach{ mapView.addAnnotation($0) }
            }
            
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        restartAnimation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        print(#function)
        pauseAnimation()
        super.viewWillDisappear(animated)
    }

    func pauseAnimation() {
        print("pause")
        sceneLocationView.pause()
    }

    func restartAnimation() {
        print("run")
        sceneLocationView.run()
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = contentView.bounds
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first,
            let view = touch.view else { return }

        if mapView == view || mapView.recursiveSubviews().contains(view) {
            centerMapOnUserLocation = false
        } else {
            let location = touch.location(in: self.view)

            if location.x <= 40 && adjustNorthByTappingSidesOfScreen {
                print("left side of the screen")
                sceneLocationView.moveSceneHeadingAntiClockwise()
            } else if location.x >= view.frame.size.width - 40 && adjustNorthByTappingSidesOfScreen {
                print("right side of the screen")
                sceneLocationView.moveSceneHeadingClockwise()
            } else if addNodeByTappingScreen {
                let image = UIImage(named: "pin")!
                let annotationNode = LocationAnnotationNode(location: nil, image: image)
                annotationNode.scaleRelativeToDistance = false
                annotationNode.scalingScheme = .normal
                DispatchQueue.main.async {
                    // If we're using the touch delegate, adding a new node in the touch handler sometimes causes a freeze.
                    // So defer to next pass.
                    self.sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
                }
            }
        }
    }
}

// MARK: - MKMapViewDelegate

@available(iOS 15.0, *)
extension POIViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 3
        renderer.strokeColor = UIColor.blue.withAlphaComponent(0.5)

        return renderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation),
           let pointAnnotation = annotation as? MKPointAnnotation else { return nil }

        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)

        if pointAnnotation == self.userAnnotation {
            marker.displayPriority = .required
            marker.glyphImage = UIImage(named: "user")
        } else {
            marker.displayPriority = .required
            marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
            marker.glyphImage = UIImage(named: "peak4")
        }

        return marker
    }
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        let pointAnnotation = annotation as? MKPointAnnotation
        searchForNode(latitude: (pointAnnotation?.coordinate.latitude)!, longitude: (pointAnnotation?.coordinate.longitude)!)
        
    }
    
    
}


// MARK: - Implementation

@available(iOS 15.0, *)
extension POIViewController {

    /// Adds the appropriate ARKit models to the scene.  Note: that this won't
    /// do anything until the scene has a `currentLocation`.  It "polls" on that
    /// and when a location is finally discovered, the models are added.
    func addSceneModels() {
        // 1. Don't try to add the models to the scene until we have a current location
        guard sceneLocationView.sceneLocationManager.currentLocation != nil else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.addSceneModels()
            }
            return
        }

        let box = SCNBox(width: 1, height: 0.2, length: 5, chamferRadius: 0.25)
        box.firstMaterial?.diffuse.contents = UIColor.gray.withAlphaComponent(0.5)

        // 2. If there is a route, show that
//        if let routes = routes {
//            sceneLocationView.addRoutes(routes: routes) { distance -> SCNBox in
//                let box = SCNBox(width: 1.75, height: 0.5, length: distance, chamferRadius: 0.25)
//
////                // Option 1: An absolutely terrible box material set (that demonstrates what you can do):
////                box.materials = ["box0", "box1", "box2", "box3", "box4", "box5"].map {
////                    let material = SCNMaterial()
////                    material.diffuse.contents = UIImage(named: $0)
////                    return material
////                }
//
//                // Option 2: Something more typical
//                box.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.7)
//                return box
//            }
//        } else {
            // 3. If not, then show the
        buildDemoData().forEach {
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
        }
//        }

        // There are many different ways to add lighting to a scene, but even this mechanism (the absolute simplest)
        // keeps 3D objects fron looking flat
        sceneLocationView.autoenablesDefaultLighting = true

    }

    /// Builds the location annotations for a few random objects, scattered across the country
    ///
    /// - Returns: an array of annotation nodes.
    func buildDemoData() -> [LocationNode] {
        let nodes: [LocationNode] = peakValue
//        var nodes: [LocationAnnotationNode] = []
//
//        let pikesPeakLayer = CATextLayer()
//        pikesPeakLayer.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
//        pikesPeakLayer.cornerRadius = 4
//        pikesPeakLayer.fontSize = 14
////        pikesPeakLayer.alignmentMode = .center
//        pikesPeakLayer.foregroundColor = UIColor.black.cgColor
//        pikesPeakLayer.backgroundColor = UIColor.white.cgColor

        // This demo uses a simple periodic timer to showcase dynamic text in a node.  In your implementation,
        // the view's content will probably be changed as the result of a network fetch or some other asynchronous event.

//        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            pikesPeakLayer.string = "Pike's Peak\n" + Date().description
//        }
//
//        let pikesPeak = buildLayerNode(latitude: 38.8405322, longitude: -105.0442048, altitude: 4705, layer: pikesPeakLayer)
//        nodes.append(pikesPeak)
        
//        let uetliberg = buildViewNode(latitude: 47.3499395, longitude: 8.4911947, altitude: 870.0, text: "Uetliberg")
//        nodes.append(uetliberg)
//        let Uitikon = buildViewNode(latitude: 47.37070605629712, longitude: 8.452770723847408, altitude: 300.0, text: "Uitikon")
//        nodes.append(Uitikon)

        return nodes
    }

    @objc
    func updateUserLocation() {
        guard let currentLocation = sceneLocationView.sceneLocationManager.currentLocation else {
            return
        }

        DispatchQueue.main.async { [weak self ] in
            guard let self = self else {
                return
            }

            if self.userAnnotation == nil {
                self.userAnnotation = MKPointAnnotation()
                self.mapView.addAnnotation(self.userAnnotation!)
            }

            UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
                self.userAnnotation?.coordinate = currentLocation.coordinate
            }, completion: nil)

            if self.centerMapOnUserLocation {
                UIView.animate(withDuration: 0.45,
                               delay: 0,
                               options: .allowUserInteraction,
                               animations: {
                                self.mapView.setCenter(self.userAnnotation!.coordinate, animated: false)
                }, completion: { _ in
                    self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                })
            }

            if self.displayDebugging {
                if let bestLocationEstimate = self.sceneLocationView.sceneLocationManager.bestLocationEstimate {
                    if self.locationEstimateAnnotation == nil {
                        self.locationEstimateAnnotation = MKPointAnnotation()
                        self.mapView.addAnnotation(self.locationEstimateAnnotation!)
                    }
                    self.locationEstimateAnnotation?.coordinate = bestLocationEstimate.location.coordinate
                } else if self.locationEstimateAnnotation != nil {
                    self.mapView.removeAnnotation(self.locationEstimateAnnotation!)
                    self.locationEstimateAnnotation = nil
                }
            }
        }
    }

    @objc
    func updateInfoLabel() {
        if let position = sceneLocationView.currentScenePosition {
            infoLabel.text = " x: \(position.x.short), y: \(position.y.short), z: \(position.z.short)\n"
        }

        if let eulerAngles = sceneLocationView.currentEulerAngles {
            infoLabel.text!.append(" Euler x: \(eulerAngles.x.short), y: \(eulerAngles.y.short), z: \(eulerAngles.z.short)\n")
        }

		if let eulerAngles = sceneLocationView.currentEulerAngles,
			let heading = sceneLocationView.sceneLocationManager.locationManager.heading,
			let headingAccuracy = sceneLocationView.sceneLocationManager.locationManager.headingAccuracy {
            let yDegrees = (((0 - eulerAngles.y.radiansToDegrees) + 360).truncatingRemainder(dividingBy: 360) ).short
			infoLabel.text!.append(" Heading: \(yDegrees)° • \(Float(heading).short)° • \(headingAccuracy)°\n")
		}

        let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: Date())
        if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
            let nodeCount = "\(sceneLocationView.sceneNode?.childNodes.count.description ?? "n/a") ARKit Nodes"
            infoLabel.text!.append(" \(hour.short):\(minute.short):\(second.short):\(nanosecond.short3) • \(nodeCount)")
        }
    }
    //MARK: build node
    func buildNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                   altitude: CLLocationDistance, imageName: String) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let image = UIImage(named: imageName)!
        return LocationAnnotationNode(location: location, image: image)
    }
    func buildViewNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                       altitude: CLLocationDistance, text: String) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        label.text = text
//        label.backgroundColor = .green
        label.layer.backgroundColor = UIColor(red: 0/255, green: 159/255, blue: 184/255, alpha: 1.0).cgColor
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        return LocationAnnotationNode(location: location, view: label)
    }

    func buildLayerNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                        altitude: CLLocationDistance, layer: CALayer) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        return LocationAnnotationNode(location: location, layer: layer)
    }

}

//@available(iOS 11.0, *)
//extension POIViewController{
//
//
//}

// MARK: - LNTouchDelegate
@available(iOS 15.0, *)
extension POIViewController: LNTouchDelegate {

    func annotationNodeTouched(node: AnnotationNode) {
		if let node = node.parent as? LocationNode {
			let coords = "\(node.location.coordinate.latitude.short)° \(node.location.coordinate.longitude.short)°"
			let altitude = "\((node.location.altitude + offset).short)m"
            let tag = searchMap(locationNode: node) ?? ""
//			let tag = node.tag ?? ""
			nodePositionLabel.text = " This node at \(coords), \(altitude) \(tag)"
            if altLayer != nil{
                sceneLocationView.removeLocationNode(locationNode: altLayer!)
            }
//            altLayer = buildAltLayer(node: node)
//            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: altLayer!)
            
            if showMap{
                let gotoLocation = CLLocationCoordinate2D(latitude: node.location.coordinate.latitude, longitude: node.location.coordinate.longitude)
                focusLocation(gotoLocation: gotoLocation)
//                let mapPoint = MKPointAnnotation()
//                mapPoint.coordinate = gotoLocation
//                mapView.selectAnnotation(mapPoint, animated: true)
                mapView.selectedAnnotations = []
                if !showAllPeaks{
                    let mapPoint = MKPointAnnotation()
                    mapPoint.coordinate = gotoLocation
//                    for annotation_ in mapView.annotations{
//                        if annotation_.coordinate.latitude == gotoLocation.latitude && annotation_.coordinate.longitude == gotoLocation.longitude{
//                            mapView.removeAnnotation(annotation_)
//                        }
//                    }
                    mapView.removeAnnotations(mapView.annotations)
                    mapView.addAnnotation(mapPoint)
//                    mapView.selectAnnotation(mapPoint, animated: true)
                    
                }
            }
            
            if(selectPeakLayer != nil){
                if node.location.coordinate.longitude == selectPeakLayer?.location.coordinate.longitude && node.location.coordinate.latitude == selectPeakLayer?.location.coordinate.latitude{
                    sceneLocationView.removeLocationNode(locationNode: selectPeakLayer!)
                    peakValue.removeLast()
                }
                else{
                    replaceNode(node: selectPeakLayer!)
                }
                selectPeakLayer = nil
            }
            if(selectMapPoint != nil){
                if node.location.coordinate.longitude == selectMapPoint?.location.coordinate.longitude && node.location.coordinate.latitude == selectMapPoint?.location.coordinate.latitude{
                    sceneLocationView.removeLocationNode(locationNode: selectMapPoint!)
                    peakValue.removeLast()
                }
                else{
                    replaceNode(node: selectMapPoint!)
                }
                selectMapPoint = nil
            }
//            selectPeakLayer = buildBigNode(node: node)
            sceneLocationView.removeLocationNode(locationNode: node)
//            selectPeakLayer = buildLayer(node: node)
            selectPeakLayer = buildImageNode(node: node, imageName: "peak5")
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: selectPeakLayer!)
            peakValue.append(selectPeakLayer!)
		}
    }

    func locationNodeTouched(node: LocationNode) {
        print("Location node touched - tag: \(node.tag ?? "")")
		let coords = "\(node.location.coordinate.latitude.short)° \(node.location.coordinate.longitude.short)°"
		let altitude = "\(node.location.altitude.short)m"
		let tag = node.tag ?? ""
		nodePositionLabel.text = " Location node at \(coords), \(altitude) - \(tag)"
    }

}

// MARK: - Helpers

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: execute)
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews

        subviews.forEach { recursiveSubviews.append(contentsOf: $0.recursiveSubviews()) }

        return recursiveSubviews
    }
    
}

//MARK: Utilities
@available(iOS 15.0, *)
extension POIViewController{
    func focusLocation(gotoLocation: CLLocationCoordinate2D) {
//        let rangeInMeters: Double = 5000   // <-- adjust as desired
//        let coordinateRegion = MKCoordinateRegion.init(center: gotoLocation,
//                                                       latitudinalMeters: rangeInMeters,
//                                                       longitudinalMeters: rangeInMeters)
//        mapView.setRegion(coordinateRegion, animated: true)
//        let mapNode = MKPointAnnotation()
//        mapNode.coordinate = gotoLocation
//        mapView.addAnnotation(mapNode)
        UIView.animate(withDuration: 0.45,
                       delay: 0,
                       options: .allowUserInteraction,
                       animations: {
                        self.mapView.setCenter(gotoLocation, animated: false)
        }, completion: { _ in
            self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        })
        centerMapOnUserLocation = false
    }
    
    func buildLayer(node: LocationNode) -> LocationNode{
        
            
        let selectPeakLayer = CATextLayer()
        selectPeakLayer.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        selectPeakLayer.cornerRadius = 20
        selectPeakLayer.fontSize = 10
        selectPeakLayer.alignmentMode = .center
        selectPeakLayer.foregroundColor = UIColor.white.cgColor
        selectPeakLayer.backgroundColor = UIColor(red: 51/255, green: 86/255, blue: 155/255, alpha: 1.0).cgColor
        selectPeakLayer.string = "\n🗻"
        
        let selectPeak = buildLayerNode(latitude: node.location.coordinate.latitude, longitude: node.location.coordinate.longitude, altitude: node.location.altitude, layer: selectPeakLayer)
        return selectPeak
    }
    
    func buildStarLayer(node: LocationNode) -> LocationNode{
        
            
        let selectPeakLayer = CATextLayer()
        selectPeakLayer.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        selectPeakLayer.cornerRadius = 20
        selectPeakLayer.fontSize = 10
        selectPeakLayer.alignmentMode = .center
        selectPeakLayer.foregroundColor = UIColor.white.cgColor
        selectPeakLayer.backgroundColor = UIColor(red: 51/255, green: 86/255, blue: 155/255, alpha: 1.0).cgColor
        selectPeakLayer.string = "\n⭐️"
        let selectPeak = buildLayerNode(latitude: node.location.coordinate.latitude, longitude: node.location.coordinate.longitude, altitude: node.location.altitude, layer: selectPeakLayer)
        return selectPeak
    }
    func buildAltLayer(node: LocationNode) -> LocationNode{
        
            
        let selectPeakLayer = CATextLayer()
        let altitude: String = "\((node.location.altitude + offset).short)m"
//        selectPeakLayer.frame = CGRect(x: 50, y: 0, width: 100, height: 50)
        selectPeakLayer.frame = CGRectMake(50, 0, 100, 50)
        selectPeakLayer.cornerRadius = 10
        selectPeakLayer.fontSize = 20
        selectPeakLayer.alignmentMode = .center
        selectPeakLayer.foregroundColor = UIColor.white.cgColor
        selectPeakLayer.backgroundColor = UIColor(red: 51/255, green: 86/255, blue: 155/255, alpha: 1.0).cgColor
        selectPeakLayer.string = altitude
        selectPeakLayer.isWrapped = true
        selectPeakLayer.contentsScale = sceneLocationView.contentScaleFactor
//        let rotation = CATransform3DMakeRotation(CGFloat(30.0 * .pi / 180.0), 0, 0, 1.0)
//        selectPeakLayer.transform = CATransform3DMakeRotation(.pi/2 , 0, 0, 1.0)
        
//        let altLabel = CATextLayer()
//        altLabel.frame = CGRectMake(50, 0, 40, 20)
//        altLabel.isWrapped = true

//        selectPeakLayer.
        let selectPeak = buildLayerNode(latitude: node.location.coordinate.latitude, longitude: node.location.coordinate.longitude, altitude: node.location.altitude, layer: selectPeakLayer)
        return selectPeak
    }
    
    func buildBigNode(node:LocationNode) -> LocationNode{
        let coordinate = CLLocationCoordinate2D(latitude: node.location.coordinate.latitude, longitude: node.location.coordinate.longitude)
        let location = CLLocation(coordinate: coordinate, altitude: node.location.altitude)
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        label.layer.backgroundColor = UIColor(red: 51/255, green: 86/255, blue: 155/255, alpha: 1.0).cgColor
        label.layer.cornerRadius = 15
        return LocationAnnotationNode(location: location, view: label)
    }
    func buildSmallNode(node:LocationNode) -> LocationNode{
        let coordinate = CLLocationCoordinate2D(latitude: node.location.coordinate.latitude, longitude: node.location.coordinate.longitude)
        let location = CLLocation(coordinate: coordinate, altitude: node.location.altitude)
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        label.layer.backgroundColor = UIColor(red: 51/255, green: 86/255, blue: 155/255, alpha: 1.0).cgColor
        label.layer.cornerRadius = 5
        return LocationAnnotationNode(location: location, view: label)
    }
    
    // find a node closest to the selected map point
    func searchForNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        for peakNode in peakValue{
        
            if peakNode.location.coordinate.latitude == latitude && peakNode.location.coordinate.longitude == longitude{
                if altLayer != nil{
                    sceneLocationView.removeLocationNode(locationNode: altLayer!)
                }
                if(selectPeakLayer != nil){
                    if peakNode.location.coordinate.longitude == selectPeakLayer?.location.coordinate.longitude && peakNode.location.coordinate.latitude == selectPeakLayer?.location.coordinate.latitude{
                        sceneLocationView.removeLocationNode(locationNode: selectPeakLayer!)
                        peakValue.removeLast()
                    }
                    else{
                        replaceNode(node: selectPeakLayer!)
                    }
                    selectPeakLayer = nil
                }
                if(selectMapPoint != nil){
                    if peakNode.location.coordinate.longitude == selectMapPoint?.location.coordinate.longitude && peakNode.location.coordinate.latitude == selectMapPoint?.location.coordinate.latitude{
                        sceneLocationView.removeLocationNode(locationNode: selectMapPoint!)
                        peakValue.removeLast()
                    }
                    else{
                        replaceNode(node: selectMapPoint!)
                    }
                    selectMapPoint = nil
                }
                sceneLocationView.removeLocationNode(locationNode: peakNode)
                selectMapPoint = buildImageNode(node: peakNode, imageName: "peak5")
                sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: selectMapPoint!)
                peakValue.append(selectMapPoint!)
                updatePositionLabel(node: selectMapPoint!)
                
//                altLayer = buildAltLayer(node: peakNode)
//                sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: altLayer!)
            }
        }
        return
        
    }
    // return last selected node to normal small node
    func replaceNode(node:LocationNode){
        let newnode = buildSmallNode(node: node)
        sceneLocationView.removeLocationNode(locationNode: node)
        peakValue.removeLast()
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: newnode)
        peakValue.append(newnode)
        
    }
    
    func updatePositionLabel(node:LocationNode){
        let coords = "\(node.location.coordinate.latitude.short)° \(node.location.coordinate.longitude.short)°"
        let altitude = "\((node.location.altitude + offset).short)m"
        let tag = searchMap(locationNode: node) ?? ""
        nodePositionLabel.text = " This node at \(coords), \(altitude), \(tag)"
    }
    func buildImageNode(node:LocationNode, imageName:String) -> LocationNode{
        let coordinate = CLLocationCoordinate2D(latitude: node.location.coordinate.latitude, longitude: node.location.coordinate.longitude)
        let location = CLLocation(coordinate: coordinate, altitude: node.location.altitude)
        let image = resizeImage(image: UIImage(named: imageName)!, targetSize: CGSizeMake(40, 40))
        
        return LocationAnnotationNode(location: location, image: image ?? UIImage(named: imageName)!)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func searchMap(locationNode: LocationNode) -> String?{
        let geoCoder = CLGeocoder()
        let location = locationNode.location
        geoCoder.reverseGeocodeLocation(location!) { (placeMarkers, error) -> Void in
            self.placeMark = placeMarkers?[0]
        }
//
        if placeMark != nil{
//            print(placeMark.addressDictionary)
            var name: String
            if (placeMark.addressDictionary!["Name"] != nil){
                name = placeMark.addressDictionary!["Name"] as! String
            }
            else{
                name = placeMark.addressDictionary!["Street"] as! String
            }
            
            let zip = placeMark.addressDictionary?["ZIP"] as! String
            let state = placeMark.addressDictionary?["State"] as! String
            if name == zip{
                name = "Unrecogenized Street Name"
            }
            let place: [String] = [name, zip, state]
            let result = place.joined(separator: ", ")
            print("Result", result)
            return result
        }
        else{return nil}
        
    }
    
//    func searchMapKit(locationNode:LocationNode){
//        let location  = locationNode.location
//        let myLatitude = String(format: "%f", location!.coordinate.latitude)
//        let myLongitude = String(format:"%f", location!.coordinate.longitude)
//        let searchTxt = [myLatitude, myLongitude].joined(separator: ",")
//        
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = searchTxt 
//    }
    
}

extension UIImage {
    func drawTextInImage(txt: String)->UIImage {
        //开启图片上下文
        UIGraphicsBeginImageContext(self.size)
        //图形重绘
        self.draw(in: CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height))
        //水印文字属性
        let att = [NSAttributedString.Key.foregroundColor:UIColor.red,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 60),NSAttributedString.Key.backgroundColor:UIColor.green]
        //水印文字大小
        let text = NSString(string: txt)
        let size =  text.size(withAttributes: att)
        //绘制文字
        text.draw(in: CGRect.init(x: self.size.width-450, y: self.size.height-80, width: size.width, height: size.height), withAttributes: att)
        //从当前上下文获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        
        return image!
        
    }
}

