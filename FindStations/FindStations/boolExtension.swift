//
//  boolExtension.swift
//  FindStations
//
//  Created by Cameron Erdogan on 9/28/16.
//  Copyright © 2016 Cameron Erdogan. All rights reserved.
//

import Foundation

extension Bool {
    init<T : IntegerType>(_ integer: T){
        self.init(integer != 0)
    }
}
