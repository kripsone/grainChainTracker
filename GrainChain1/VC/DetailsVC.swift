//
//  DetailsVC.swift
//  GrainChain1
//
//  Created by José Cadena on 09/03/20.
//  Copyright © 2020 GranChain. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData

class DetailsVC: UIViewController {

    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var vwMap: GMSMapView!
    
    var run:Run!

    override func viewDidLoad() {
        super.viewDidLoad()
        lblTime.text = run.name
        lblDistance.text = calculateDistante()
        lblTime.text = "Duración: \(Helpers.calculateDurations(start: run.startTime!, end: run.endTime!))"
        title = "Detalles de carrera"
        loadMAp()
        btnShare.addBorderColorRounded(width: 1, color: #colorLiteral(red: 0.1779083172, green: 1, blue: 0.6394527331, alpha: 0.8470588235), round: 5)
        btnDelete.addBorderColorRounded(width: 1, color: #colorLiteral(red: 0.1779083172, green: 1, blue: 0.6394527331, alpha: 0.8470588235), round: 5)
    }
    
    func calculateDistante()->String{
        return String(format: "%.2f", CGFloat(run.distance / 1000)) + " Km"
    }
    
    func loadMAp(){
        let path = GMSMutablePath()
        guard let locations = run.locations, locations.count > 0 else {return}
        let latitudes = locations.map({location -> Double in
            let location = location as! Location
            return location.latitude
        })
        
        let longitudes = locations.map({location -> Double in
            let location = location as! Location
            return location.longitude
        })
        
        
        let bounds = GMSCoordinateBounds()
        for index in 0..<locations.count{
            let camera = GMSCameraPosition.camera(withLatitude: latitudes[index], longitude: longitudes[index], zoom: 16.0)
            vwMap.camera = camera
            path.add(CLLocationCoordinate2D(latitude: latitudes[index], longitude: longitudes[index]))
        }
        
        if latitudes.first != nil{
            drawMarker(true, CLLocationCoordinate2D(latitude: latitudes.first! , longitude: longitudes.first!))
        }
            
        if latitudes.last != nil{
            drawMarker(false, CLLocationCoordinate2D(latitude: latitudes.last! , longitude: longitudes.last!))
        }
        
        let line = GMSPolyline(path: path)
        line.strokeColor = #colorLiteral(red: 0.9100526571, green: 0.2088722587, blue: 0.4248515368, alpha: 1)
        line.strokeWidth = 5.0
        line.map = vwMap
        let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
        vwMap.animate(with: update)
        
    }
    
    func drawMarker(_ start:Bool, _ point:CLLocationCoordinate2D){
        let marker = GMSMarker()
        marker.position = point
        if start{
            marker.icon = #imageLiteral(resourceName: "Iniciar")
        }else{
            marker.icon = #imageLiteral(resourceName: "Finalizar")
        }
        marker.map = vwMap
    }
    
    func makeImage()->UIImage{
        UIGraphicsBeginImageContext(vwMap.frame.size)
        vwMap.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    // MARK: - Button Action
    
    @IBAction func clickShare(_ sender: Any) {
        let image = makeImage()
        let imageToShare = [image, "Mi distancia recorrida fue de: \(calculateDistante()).","#FitnessIsMyPassion"] as [AnyObject]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func clickDelete(_ sender: Any) {
        //let fetchDelete = CoreDataStack.context.delete(run)
        do {
            CoreDataStack.context.delete(run)
            try CoreDataStack.context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            Helpers.showAlertOk(vc: self, title: "Error", msg: "Ha ocurrido un error")
        }
    }
    
    
}
