//
//  SettingsViewController.swift
//  ARKit+CoreLocation
//
//  Created by Eric Internicola on 2/19/19.
//  Copyright © 2019 Project Dent. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit
import SwiftSocket
import ARCL



@available(iOS 15.0, *)
class SettingsViewController: UIViewController {

    @IBOutlet weak var showMapSwitch: UISwitch!
    @IBOutlet weak var northCalibration: UISwitch!
//    @IBOutlet weak var showRouteDirections: UISwitch!
    @IBOutlet weak var showAllPeaks: UISwitch!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var searchResultTable: UITableView!
    @IBOutlet weak var socketText: UITextView!
    @IBOutlet weak var refreshControl: UIActivityIndicatorView!

    @IBOutlet weak var search: UIButton!
    var locationManager = CLLocationManager()

    var mapSearchResults: [MKMapItem]?
    
//    var response = "47.3499395,8.4911947,870.0,47.37070605629712,8.452770723847408,300.0"
    var peakValue: [LocationAnnotationNode] = []
    var testNode :MKPointAnnotation?
    var peakValueMap: [MKPointAnnotation] = []
    
        // Socket swift prams
//    let host = "10.5.34.3"
//    let host = "10.5.176.209"
    let host = "192.168.166.80"
    let port = 54000
    var client: TCPClient?
    var connected: Result!
    var isDataSent: Bool = false
    
    let offset = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide some views
        addressText.isHidden = true
        search.isHidden = true

        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()

        locationManager.requestWhenInUseAuthorization()

        addressText.delegate = self
        
        // Socket connection
        client = TCPClient(address: host, port: Int32(port))
        
        connected = client!.connect(timeout:5)
        switch connected {
            case .success:
            appendToTextField(string: "Connected to server")
                print("connected to socket")
            case .failure:
                appendToTextField(string: "Connection failed. Please refresh...")
                print("fail to connected")
            case .none:
                appendToTextField(string: "connection failed - none")
                print("fail to connected - none")
        }
        northCalibration.isOn = false
        // test data transfer
//        dataTransfer()
//        print("Peakvalue in Setting", peakValue as Any)
        let latitude = locationManager.location?.coordinate.latitude ?? 0
        let longitude = locationManager.location?.coordinate.longitude ?? 0
        let altitude = locationManager.location?.altitude ?? 0
        print("latitude", latitude, "longitude", longitude, "altitude", altitude)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

//    @IBAction
//    func toggledSwitch(_ sender: UISwitch) {
//        if sender == showPointsOfInterest {
//            showRouteDirections.isOn = !sender.isOn
//            searchResultTable.reloadData()
//        } else if sender == showRouteDirections {
//            showPointsOfInterest.isOn = !sender.isOn
//            searchResultTable.reloadData()
//        }
//    }

    @IBAction
    func tappedSearch(_ sender: Any) {
        guard let text = addressText.text, !text.isEmpty else {
            return
        }
        searchForLocation()
    }
    
//    @IBAction
//    func printAction(){
//        appendToTextField(string: "Calculating...")
//    }
    
    @IBAction
    func connectSocket(){
        refreshTextField()
        guard let client = client else { return }
        switch connected {
        case .success:
//                refreshControl.startAnimating()
            let data = get_all()
            print("Sensor data: ", data)
            if send(string: data, using: client){
                appendToTextField(string: "Data Sent")
                appendToTextField(string: "Calculating...")
            }
//            if let response = sendRequest(string: data, using: client) {
////                print(response)
//                dataTransfer(response: response)
//            }
        case .failure(let error):
            print(String(describing: error))
            appendToTextField(string: "Connection failed. Please refresh...")
            //        client.close()
        case .none:
            print("connection failed - none")
        }
    }
    @IBAction
    func receiveData(){
        guard let client = client else { return }
        switch connected!{
        case .success:
            let now = NSDate()
            let  timeInterval: TimeInterval  = now.timeIntervalSince1970
            let  timeStamp =  Int (timeInterval)
            //        if let response = sendRequest(string: data, using: client) {
            //            //                print(response)
            //            dataTransfer(response: response)
            //        }
            var data: String = ""
            while true{
                if let response = readResponse(from: client){
                    data = data + response
                    if (data[data.index(data.endIndex, offsetBy: -2)]) == "a"{
                        //                    print("get last")
                        dataTransfer(response: String(data.dropLast()))
                        break
                    }
                }
                let loop = NSDate()
                let timeInterval_loop: TimeInterval  = loop.timeIntervalSince1970
                let timeStamp_loop = Int(timeInterval_loop)
                //            print(timeStamp_loop - timeStamp)
                if (timeStamp_loop - timeStamp) >= 20{
                    appendToTextField(string: "Time out, please refresh")
                    break
                }
            }
    
        case .failure:
            return
        }
    }
    
    @IBAction
    func refreshManul(){
        client?.close()
        refreshTextField()
        peakValue = []
        peakValueMap =  []
        connected = client!.connect(timeout:5)
        switch connected!{
        case .success:
            print("ready")
            appendToTextField(string: "Reconnected")
        case.failure:
            connected = client!.connect(timeout:5)
            appendToTextField(string: "Fail to Refresh")
        }
//        isDataSent = false
    }
    
    
}

// MARK: - UITextFieldDelegate

@available(iOS 15.0, *)
extension SettingsViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if string == "\n" {
            DispatchQueue.main.async { [weak self] in
                self?.searchForLocation()
            }
        }

        return true
    }

}

// MARK: - DataSource

@available(iOS 15.0, *)
extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
//        if showPointsOfInterest.isOn {
//            return 1
//        }
//        guard let mapSearchResults = mapSearchResults else {
//            return 0
//        }
//
//        return mapSearchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if showPointsOfInterest.isOn {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenARCell", for: indexPath)
        guard let openARCell = cell as? OpenARCell else {
            return cell
        }
        openARCell.parentVC = self

        return openARCell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
//            guard let mapSearchResults = mapSearchResults,
//                indexPath.row < mapSearchResults.count,
//                let locationCell = cell as? LocationCell else {
//                return cell
//            }
//            locationCell.locationManager = locationManager
//            locationCell.mapItem = mapSearchResults[indexPath.row]
//
//            return locationCell
//        }
    }
}

// MARK: - UITableViewDelegate

@available(iOS 15.0, *)
extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let mapSearchResults = mapSearchResults, indexPath.row < mapSearchResults.count else {
            return
        }
        let selectedMapItem = mapSearchResults[indexPath.row]
        getDirections(to: selectedMapItem)
    }

}

// MARK: - CLLocationManagerDelegate

@available(iOS 15.0, *)
extension SettingsViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
}

// MARK: - Implementation

@available(iOS 15.0, *)
extension SettingsViewController {

    func createARVC() -> POIViewController {
        let arclVC = POIViewController.loadFromStoryboard()
        arclVC.showMap = showMapSwitch.isOn
        arclVC.northClibration = northCalibration.isOn
        arclVC.adjustNorthByTappingSidesOfScreen = northCalibration.isOn
        arclVC.showAllPeaks = showAllPeaks.isOn
        arclVC.offset = offset

        return arclVC
    }

    func getDirections(to mapLocation: MKMapItem) {
        refreshControl.startAnimating()

        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = mapLocation
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)

        directions.calculate(completionHandler: { response, error in
            defer {
                DispatchQueue.main.async { [weak self] in
                    self?.refreshControl.stopAnimating()
                }
            }
            if let error = error {
                return print("Error getting directions: \(error.localizedDescription)")
            }
            guard let response = response else {
                return assertionFailure("No error, but no response, either.")
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }

                let arclVC = self.createARVC()
                arclVC.routes = response.routes
                self.navigationController?.pushViewController(arclVC, animated: true)
            }
        })
    }

    /// Searches for the location that was entered into the address text
    func searchForLocation() {
        guard let addressText = addressText.text, !addressText.isEmpty else {
            return
        }

//        showRouteDirections.isOn = true
//        toggledSwitch(showRouteDirections)

        refreshControl.startAnimating()
        defer {
            self.addressText.resignFirstResponder()
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = addressText

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            defer {
                DispatchQueue.main.async { [weak self] in
                    self?.refreshControl.stopAnimating()
                }
            }
            if let error = error {
                return assertionFailure("Error searching for \(addressText): \(error.localizedDescription)")
            }
            guard let response = response, response.mapItems.count > 0 else {
                return assertionFailure("No response or empty response")
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.mapSearchResults = response.sortedMapItems(byDistanceFrom: self.locationManager.location)
                self.searchResultTable.reloadData()
            }
        }
    }
}

extension MKLocalSearch.Response {

    func sortedMapItems(byDistanceFrom location: CLLocation?) -> [MKMapItem] {
        guard let location = location else {
            return mapItems
        }

        return mapItems.sorted { (first, second) -> Bool in
            guard let d1 = first.placemark.location?.distance(from: location),
                let d2 = second.placemark.location?.distance(from: location) else {
                    return true
            }

            return d1 < d2
        }
    }
    
}

//MARK: Socket data transfer
@available(iOS 15.0, *)
extension SettingsViewController {
    private func sendRequest(string: String, using client: TCPClient) -> String? {
        
        refreshControl.startAnimating()
        switch client.send(string: string) {
        case .success:
            refreshControl.stopAnimating()
//            appendToTextField(string: "Sending data...")
            
            return readResponse(from: client)
            
        case .failure(let error):
            appendToTextField(string: String(describing: error))
//            print(String(describing: error))
            return nil
        }
        
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(300000, timeout: -1) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }
    
    
    private func send(string: String, using client: TCPClient) -> Bool{
        switch client.send(string: string) {
        case .success:
            appendToTextField(string: "Sending data...")
            return true
        case .failure(let error):
            refreshControl.stopAnimating()
            appendToTextField(string: "!!! Fail to send data, please refresh")
//            appendToTextField(string: String(describing: error))
            print(String(describing: error))
            return false
        }
    }
    
    
    func get_all() -> String{
        let latitude = locationManager.location?.coordinate.latitude ?? 0
        let longitude = locationManager.location?.coordinate.longitude ?? 0
        let altitude = locationManager.location?.altitude ?? 0
        
        let list = [latitude.description, longitude.description, altitude.description]
        //        print(list)
        let string = list.joined(separator: ",")
        //        print(string)
        return string
    }
    private func appendToTextField(string: String) {
        socketText.text = socketText.text.appending("\n\(string)")
    }
    private func refreshTextField(){
        socketText.text = String("")
    }
    
    
}

    
@available(iOS 15.0, *)
extension SettingsViewController {
        //TODO: 可视化
    func buildViewNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                       altitude: CLLocationDistance, text: String) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        label.text = text
//        label.backgroundColor = .green
        label.layer.backgroundColor = UIColor(red: 51/255, green: 86/255, blue: 155/255, alpha: 1.0).cgColor
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        return LocationAnnotationNode(location: location, view: label)
    }
    func buildMapNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                      text: String) -> MKPointAnnotation{
        let mapNode = MKPointAnnotation()
        mapNode.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapNode.title = text
        return mapNode
        
    }
    
    
    func dataTransfer(response : String){
//        response =
        var nodes: [LocationAnnotationNode] = []
        var mapNodes: [MKPointAnnotation] = []
        let data = response.components(separatedBy: ",")
        let len = data.count
        print("response data lens: " , len)
        let num_nodes = Int(len/3 - 1)
        for i in 0...num_nodes{
            let latitude = Double(data[i*3]) ?? 0
            let longitude = Double(data[i*3+1]) ?? 0
            let altitude_ = Double(data[i*3+2]) ?? 0
            let altitude = altitude_ - offset
            print("node: ", i, "latitude", latitude, "longitude:", longitude, "altitude:", altitude+offset)
            
            let node = buildViewNode(latitude: latitude, longitude: longitude, altitude: altitude, text: "")
            let mapNode = buildMapNode(latitude: latitude, longitude: longitude, text: "")
            nodes.append(node)
            mapNodes.append(mapNode)
        }
        peakValue = nodes
        peakValueMap = mapNodes
//        let testNode = MKPointAnnotation()
//        testNode.coordinate = CLLocationCoordinate2D(latitude: 47.413702, longitude: 8.402363)
//        peakValueMap = [testNode]
        print("Finished")
        appendToTextField(string: "Finished")
    }
}

