//
//  StationDataManager.swift
//  FindStations
//
//  Created by Cameron Erdogan on 9/26/16.
//  Copyright © 2016 Cameron Erdogan. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import SwiftyJSON

class StationDataManager: NSObject {
    
    //these are updated with the fetchStations() method
    var stations : [Station]?
    var stationStatuses : [StationStatus]?
    var didSuccessfullyUpdate = false
    let stationInfoURL = "https://gbfs.citibikenyc.com/gbfs/en/station_information.json"
    let statusInfoURL = "https://gbfs.citibikenyc.com/gbfs/en/station_status.json"
    
    let managedContext : NSManagedObjectContext
    
    
    private var _statusesJson : JSON?
    private var _stationsJson : JSON?
    private var _dataUpdatedCallback : (() -> Void)?
    
    override init(){
        
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        super.init()
    }

    
    //argument is a callback that only gets called if we successfully
    //update web data into core data. happens in createDataRelationships
    func requestWebData(dataUpdatedCallback: () -> Void){
        print ("requesting web data")
        _dataUpdatedCallback = dataUpdatedCallback
        
        //url request for station info
        Alamofire.request(.GET, stationInfoURL).responseJSON { response in
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                self._stationsJson = json["data"]["stations"]
                self.createDataRelationships()
                
            case .Failure(let error):
                print(error)
            }
            
        }
        
        Alamofire.request(.GET, statusInfoURL).responseJSON { response in
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                self._statusesJson = json["data"]["stations"]
                self.createDataRelationships()
                
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func updateWebData(dataUpdatedCallback: () -> Void){
        print ("requesting web data")
        _dataUpdatedCallback = dataUpdatedCallback
        
        Alamofire.request(.GET, statusInfoURL).responseJSON { response in
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                self._statusesJson = json["data"]["stations"]
                self.updateStationData()
                
            case .Failure(let error):
                print(error)
            }
        }
    }

    
    func fetchStations(){
        
        let fetchStationRequest = NSFetchRequest(entityName: "Station")
        do{
            let results = try managedContext.executeFetchRequest(fetchStationRequest)
            stations = results as? [Station]
            print("fetched \(stations?.count) stations")
        }
        catch let error as NSError{
            print("Could not fetch stations\(error), \(error.userInfo)")
        }
        
//        let fetchStationStatusesRequest = NSFetchRequest(entityName: "StationStatus")
//        do{
//            let results = try managedContext.executeFetchRequest(fetchStationStatusesRequest)
//            stationStatuses = results as? [StationStatus]
//            print("fetched \(stationStatuses?.count) statuses")
//        }
//        catch let error as NSError{
//            print("Could not fetch stations\(error), \(error.userInfo)")
//        }
        
    }
    
    //-------------------------
    // private functions
    //-------------------------
    
    //need to call this in both callbacks because we dont know which will return first
    //will only excecute once both jsons are populated
    private func createDataRelationships(){

        if _statusesJson != nil && _stationsJson != nil{
            
            //should fetch and delete what we have in core data first
            clearPersistentData()
            
            //create a dictionary of station statuses so we can quickly access them
            //when we go through stations
            var statusesDict = [String : JSON]()
            let statuses = _statusesJson!
            for(_, s):(String, JSON) in statuses{
                let station_id = s["station_id"].string!
                
                statusesDict[station_id] = s
            }
            
            //go through all of the stations, create appropirate coredata objects
            let stations = _stationsJson!
            
            for (_, stationJson):(String, JSON) in stations{
                
                let stationEntity = NSEntityDescription.entityForName("Station", inManagedObjectContext: managedContext)
                let station = Station(entity: stationEntity!, insertIntoManagedObjectContext: managedContext)
                
                station.id = stationJson["station_id"].string
                station.name = stationJson["name"].string
                station.latitude = stationJson["lat"].double!
                station.longitude = stationJson["lon"].double!
                station.capacity = Int16(stationJson["capacity"].int!)
                
                //extract status info and create appropirate coredata
                //ALTERNATIVELY
                //could lazily query for station only when we want to delve deeper
                //i like this better because it means we only need to query the web at
                //one point in time every session
                if let statusJson = statusesDict[station.id!]{
//                    let statusEntity = NSEntityDescription.entityForName("StationStatus", inManagedObjectContext: managedContext)
//                    let status = StationStatus(entity: statusEntity!, insertIntoManagedObjectContext: managedContext)
                    
//                    status.id = statusJson["station_id"].string
                    station.is_installed = Bool(statusJson["is_installed"].int!)
                    station.is_renting = Bool(statusJson["is_renting"].int!)
                    station.is_returning = Bool(statusJson["is_returning"].int!)
                    station.num_bikes_available = Int16(statusJson["num_bikes_available"].int!)
                    station.num_docks_available = Int16(statusJson["num_docks_available"].int!)
                    station.num_bikes_disabled = Int16(statusJson["num_bikes_disabled"].int!)
                    station.num_docks_disabled = Int16(statusJson["num_docks_disabled"].int!)
//                    status.station = station
                }
            }
            
            do{
                try managedContext.save()
            }catch let error as NSError{
                print("could not save \(error), \(error.userInfo)")
            }
            
            //set these to nil, otherwise we'll think we
//            _stationsJson = nil
            _statusesJson = nil
            
            //update our local stations
            //do I need to do this? I already have the stations above, could just load into array here
            //this is less code for now
            fetchStations()
            
            if let callback = _dataUpdatedCallback{
                callback()
            }
            didSuccessfullyUpdate = true
        }
    }
    
    //this assumes we've already initially pulled station info
    private func updateStationData(){
        
        if _statusesJson != nil && _stationsJson != nil{
            
            //create a dictionary of station statuses so we can quickly access them
            //when we go through stations
            var statusesDict = [String : JSON]()
            let statuses = _statusesJson!
            for(_, s):(String, JSON) in statuses{
                let station_id = s["station_id"].string!
                
                statusesDict[station_id] = s
            }
            
            //go through all of the stations, create appropirate coredata objects
            let stations = _stationsJson!
            
            let fetchStationRequest = NSFetchRequest(entityName: "Station")
            fetchStationRequest.includesPropertyValues = false
            do{
                let results = try managedContext.executeFetchRequest(fetchStationRequest) as? [Station]
                if let s = results{
                    for station in s{
                        if let statusJson = statusesDict[station.id!]{
                            station.is_installed = Bool(statusJson["is_installed"].int!)
                            station.is_renting = Bool(statusJson["is_renting"].int!)
                            station.is_returning = Bool(statusJson["is_returning"].int!)
                            station.num_bikes_available = Int16(statusJson["num_bikes_available"].int!)
                            station.num_docks_available = Int16(statusJson["num_docks_available"].int!)
                            station.num_bikes_disabled = Int16(statusJson["num_bikes_disabled"].int!)
                            station.num_docks_disabled = Int16(statusJson["num_docks_disabled"].int!)
                            
                        }
                    }
                }
            }
            catch let error as NSError{
                print("Could not fetch stations to delete\(error), \(error.userInfo)")
            }
            
            
            
            do{
                try managedContext.save()
            }catch let error as NSError{
                print("could not save \(error), \(error.userInfo)")
            }
            
            //set these to nil, otherwise we'll think we
            _stationsJson = nil
            _statusesJson = nil
            
            //update our local stations
            //do I need to do this? I already have the stations above, could just load into array here
            //this is less code for now
            fetchStations()
            
            if let callback = _dataUpdatedCallback{
                callback()
            }
            didSuccessfullyUpdate = true
        }

        
    }
    
    //delete what we currently have in core data persistent storage
    //usually do this right before we update everything from web request
    private func clearPersistentData(){
        //this is the <= iOS 8 way
        //batchDeleteRequests were introducted in iOS 9, which would make this easier on memory
        
        //fetch stations, mark each one for deletion
        let fetchStationRequest = NSFetchRequest(entityName: "Station")
        fetchStationRequest.includesPropertyValues = false
        do{
            let results = try managedContext.executeFetchRequest(fetchStationRequest) as? [Station]
            if let s = results{
                for station in s{
                    managedContext.deleteObject(station)
                }
 
            }
        }
        catch let error as NSError{
            print("Could not fetch stations to delete\(error), \(error.userInfo)")
        }
        
        
//        //fetch statuses, mark each one for deletion
//        let fetchStationStatusesRequest = NSFetchRequest(entityName: "StationStatus")
//        fetchStationStatusesRequest.includesPropertyValues = false
//        do{
//            let results = try managedContext.executeFetchRequest(fetchStationStatusesRequest) as? [StationStatus]
//            if let s = results{
//                for status in s{
//                    managedContext.deleteObject(status)
//                }
//            }
//        }
//        catch let error as NSError{
//            print("Could not fetch stations\(error), \(error.userInfo)")
//        }
        
        //try saving context to complete deletion
        do{
            try managedContext.save()
            print ("cleared stations and statuses")
        }catch let error as NSError{
            print("could not save \(error), \(error.userInfo)")
        }
        
    }
    
    //--------------

}
