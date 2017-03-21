//
//  WeatherModel.swift
//  Forecast
//
//  Created by Valerie Greer on 3/20/17.
//  Copyright © 2017 Shane Empie. All rights reserved.
//

import Foundation

class WeatherModel: NSObject {
    
    var lat             :Double?
    var lon             :Double?
    var time            :Double?
    var icon            :String?
    var temp            :Int?
    var apparentTemp    :Int?
    
    var convertedTime :Date? {
        return Date(timeIntervalSince1970: time!)
    }
    
    convenience init(lat: Double, lon: Double, time: Double, icon: String, temp: Int, apparentTemp: Int) {
        
        self.init()
        self.lat = lat
        self.lon = lon
        self.icon = icon
        self.temp = temp
        self.apparentTemp = apparentTemp
        
    }
    
}
