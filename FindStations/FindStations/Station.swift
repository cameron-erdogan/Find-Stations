//
//  Station.swift
//  FindStations
//
//  Created by Cameron Erdogan on 9/28/16.
//  Copyright © 2016 Cameron Erdogan. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Station: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    func pinColorForStation() -> UIColor{
//        if let thisStatus = status{
            var greenHue : CGFloat = 0
            var saturation : CGFloat = 0
            var brightness : CGFloat = 0
            var alpha : CGFloat = 0
            UIColor.greenColor().getHue(&greenHue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            var redHue : CGFloat = 0
            UIColor.redColor().getHue(&redHue, saturation: nil, brightness: nil, alpha: nil)
            
            //function of available bikes / capacity
            //1 maps to green, 0 maps to red
            //map values in between linearly
//            let percentFilled = CGFloat(thisStatus.num_bikes_available) / CGFloat(capacity)
            let percentFilled = CGFloat(num_bikes_available) / CGFloat(capacity)
            let pinHue = redHue + percentFilled * (greenHue - redHue)
            
            return UIColor(hue:  pinHue, saturation: 1, brightness: 1, alpha: 1.0)
//        }
        
        return UIColor.redColor()
    }
}
