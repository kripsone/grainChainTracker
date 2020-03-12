//
//  ViewController.swift
//  GrainChain1
//
//  Created by José Cadena on 07/03/20.
//  Copyright © 2020 GranChain. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var vwMap: GMSMapView!
    @IBOutlet weak var btnStart: UIButton!
    
    enum btnStatus:String {
        case start = "Iniciar"
        case end = "Finalizar"
    }
    var status:btnStatus = .start
    let locationManager = LocationManager.shared
    var currentPosition:CLLocationCoordinate2D?
    var path = GMSMutablePath()
    var locationList: [CLLocation] = []
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    var startTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        setupGeoLocalization()
        vwMap.clear()
    }
    
    // MARK: - InitViews - Ask Permissions
    
    func initView(){
        btnStart.addBorderColorRounded(width: 1, color: #colorLiteral(red: 0.1779083172, green: 1, blue: 0.6394527331, alpha: 0.8470588235), round: 5)
    }
    
    func setupGeoLocalization(){
        locationManager.delegate = self
        vwMap.isMyLocationEnabled = true
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                return
        case .denied, .restricted:
            let alert = UIAlertController(title: "Location Services disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {(_) in
                self.locationManager.startUpdatingLocation()
            })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    // MARK: - Update Position - Set Markers
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else{return}
        currentPosition = last.coordinate
        let camera = GMSCameraPosition.camera(withLatitude: last.coordinate.latitude, longitude: last.coordinate.longitude, zoom: 18)
        vwMap.camera = camera
        vwMap.animate(to: camera)
        for newLocation in locations {
            //let howRecent = newLocation.timestamp.timeIntervalSinceNow
            //guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                let measurementFormatter = MeasurementFormatter()
                measurementFormatter.locale = Locale(identifier: "es_MX")
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
            }
            if currentPosition != nil && status != .start {
                drawRoute()
                locationList.append(newLocation)
            }
        }
    }
    
    func drawMarker(){
        guard currentPosition != nil else{return}
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: currentPosition!.latitude, longitude: currentPosition!.longitude)
        marker.icon = UIImage(named: status.rawValue)
        marker.map = vwMap
    }
    
    func drawRoute(){
        path.add(currentPosition!)
        let line = GMSPolyline(path: path)
        line.strokeColor = #colorLiteral(red: 0.9100526571, green: 0.2088722587, blue: 0.4248515368, alpha: 1)
        line.strokeWidth = 5.0
        line.map = vwMap
    }
    
    
    //MARK: - Save
    func saveRoute(_ name:String){
        let newRun = Run(context: CoreDataStack.context)
        newRun.distance = Float(distance.value)
        newRun.name = name
        newRun.endTime = Date()
        newRun.startTime = startTime
        for location in locationList {
          let locationObject = Location(context: CoreDataStack.context)
          locationObject.latitude = location.coordinate.latitude
          locationObject.longitude = location.coordinate.longitude
          newRun.addToLocations(locationObject)
        }
        CoreDataStack.saveContext()
    }
    
    func enterName(){
        let alert = UIAlertController(title: "Guardar ruta", message: "Ingresa un nombre para guardar", preferredStyle: .alert)
        weak var edtEmail:UITextField?
        alert.addTextField { (textField) in
            textField.placeholder = "Nombre"
            edtEmail = textField
            edtEmail?.keyboardType = .emailAddress
        }
        
        let btnSave = UIAlertAction(title: "Guardar", style: .default) { (_) in
            if !edtEmail!.text!.isEmpty {
                self.saveRoute(edtEmail!.text!)
                self.stopRun()
            }else{
                Helpers.showAlertOk(vc: self, title: "Error", msg:"Asegúrate de ingresar un nombre")
            }
            edtEmail = nil
        }
        let btnCancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(btnCancel)
        alert.addAction(btnSave)
        self.present(alert, animated: true, completion: nil)
    }
    
    func stopRun(){
        drawMarker()
        status = .start
        btnStart.setTitle(status.rawValue, for: [])
    }
    
    // MARK: - Button Actions
    @IBAction func clickRoute(_ sender: Any) {
        if status == .start{
            locationList.removeAll()
            path.removeAllCoordinates()
            startTime = Date()
            vwMap.clear()
            drawMarker()
            status = .end
            btnStart.setTitle(status.rawValue, for: [])
        }else{
            enterName()
        }
    }
}

