//
//  FindStationsViewController.swift
//  FindStations
//
//  Created by Cameron Erdogan on 9/25/16.
//  Copyright © 2016 Cameron Erdogan. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class FindStationsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lastUpdated: UILabel!
    
    var dataManager : StationDataManager?
    let locationManager = CLLocationManager()
    var annotations  = [StationAnnotation]()
    
    private var didLocateUser = false
    private let reuseIdentifier = "stationPinView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataManager = StationDataManager()
        
        dataManager?.fetchStations()
        //grab data here in case web request comes back null
        reloadData()
        dataManager?.requestWebData(reloadData)
        
        //location manager setup (to get user's current location)
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        //setup mapview
        mapView.delegate = self 
        mapView.showsUserLocation = true
        
        NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
        
    }
    
    func updateData(){
        dataManager?.requestWebData(reloadData)
    }
    
    @IBAction func reloadButtonPressed(sender: AnyObject) {
        dataManager?.updateWebData(reloadData)
    }
    
    @IBAction func centerMap(sender: AnyObject) {
        if didLocateUser{
            centerMap()
        }
    }
    
    //center on user when we first update user's coordinate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if didLocateUser == false && locationManager.location != nil{
        
            //zoomin in real close
            centerMap()
            
            didLocateUser = true
        }
    }
    
    func centerMap(){
        var region = mapView.region
        region.span.latitudeDelta = 0.01;
        region.span.longitudeDelta = 0.01;
        mapView.setRegion(region, animated: false)
        mapView.setCenterCoordinate(locationManager.location!.coordinate, animated: false)
    }
    
    func reloadData() {
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
        

        //get rid of the old ones
        dispatch_async(dispatch_get_global_queue(0, 0), {
                        //add the new ones
            for station in self.dataManager!.stations!{
                let annotation = StationAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)
                annotation.title = station.name
//                annotation.subtitle = "\(station.status!.num_bikes_available)/\(station.capacity) bikes available"
                annotation.subtitle = "\(station.num_bikes_available)/\(station.capacity) bikes available"
                annotation.station = station
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapView.addAnnotation(annotation)
                })
            }
        })
        
        
        
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKindOfClass(MKUserLocation.self){
            return nil
        }
        
        if annotation.isKindOfClass(StationAnnotation.self){
            
            let stationAnnotation = annotation as! StationAnnotation
            
            var pinView : MKPinAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView
            
            if pinView == nil{
                pinView = MKPinAnnotationView(annotation: stationAnnotation, reuseIdentifier: reuseIdentifier)
                
                //maps color between red - green depending on how many bikes are available
                //unfortunately this is only available iOS 9 and above
//                if #available(iOS 9.0, *) {
//                    pinView!.pinTintColor = stationAnnotation.station?.pinColorForStation()
//                }
                pinView!.animatesDrop = true
                pinView!.canShowCallout = true
                pinView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
                
            }
            else{
                pinView!.annotation = annotation
            }
            
            if #available(iOS 9.0, *) {
                pinView!.pinTintColor = stationAnnotation.station?.pinColorForStation()
            }

            
            return pinView
            
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let annotation = view.annotation{
            if annotation.isKindOfClass(StationAnnotation){
                let stationAnnotation = annotation as! StationAnnotation
                
                performSegueWithIdentifier("StationStatusDetail", sender: stationAnnotation)
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "StationStatusDetail"{
            let destination = segue.destinationViewController as! StationStatusDetailViewController
            let stationAnnotation = sender as! StationAnnotation
            destination.station = stationAnnotation.station
        }
        
    }
    

}
