//
//  WeatherModel.swift
//  Forecast
//
//  Created by Valerie Greer on 3/20/17.
//  Copyright © 2017 Shane Empie. All rights reserved.
//

import Foundation

class WeatherModel: NSObject {
    
    var lat             :Double!
    var lon             :Double!
    var icon            :String!
    var temp            :Double!
    var apparentTemp    :Double!
    
    convenience init(lat: Double, lon: Double, icon: String, temp: Double, apparentTemp: Double) {
        
        self.init()
        self.lat = lat
        self.lon = lon
        self.icon = icon
        self.temp = temp
        self.apparentTemp = apparentTemp
        
    }
    
}
