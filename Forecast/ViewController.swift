//
//  ViewController.swift
//  Forecast
//
//  Created by Valerie Greer on 3/20/17.
//  Copyright © 2017 Shane Empie. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    let hostName = "https://api.darksky.net/forecast/"
    let key = "19d246fb61762451ba26d890edf46390"
    var currentWeather = WeatherModel()
    var locationMgr = CLLocationManager()
    var searchLat                   :Double!
    var searchLon                   :Double!
    
    @IBOutlet var weatherIcon       :UIImageView!
    @IBOutlet var weatherSearchBar  :UISearchBar!
    @IBOutlet var tempLabel         :UILabel!
    @IBOutlet var feelsLikeLabel    :UILabel!
    @IBOutlet var dateLabel         :UILabel!
    
    //MARK: - Interactivity Methods
    
    @IBAction func searchPressed(button: UIButton) {
        
        addressSearch()
    }
    
    func updateDisplay() {
        
        tempLabel.alpha = 1.0
        feelsLikeLabel.alpha = 1.0
        dateLabel.alpha = 1.0
        tempLabel.text = String(describing: currentWeather.temp!)
        feelsLikeLabel.text = String(describing: currentWeather.apparentTemp!)
        dateLabel.text = String(describing: currentWeather.convertedTime!)
        
    }
    
    func setWeatherIcon (wIcon: String) {
        
        switch wIcon {
        case "clear-day":
            weatherIcon.image = UIImage(named: "clearDay")
        case "clear-night":
            weatherIcon.image = UIImage(named: "clearNight")
        case "rain":
            weatherIcon.image = UIImage(named: "rain")
        case "snow":
            weatherIcon.image = UIImage(named: "snow")
        case "wind":
            weatherIcon.image = UIImage(named: "wind")
        case "cloudy":
            weatherIcon.image = UIImage(named: "cloudy")
        case "partly-cloudy-day":
            weatherIcon.image = UIImage(named: "partlyCloudyDay")
        case "partly-cloudy-night":
            weatherIcon.image = UIImage(named: "partlyCloudyNight")
        default: break
        }
        
    }
    
    //MARK: - Geocoding Methods
    
    func addressSearch() {
        
        weatherSearchBar.resignFirstResponder()
        guard let searchText = weatherSearchBar.text else {
            
            return
            
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchText) { (placemarks, error) in
            if let error = error {
                
                print("Got error \(error.localizedDescription)")
                
            } else {
                let location = placemarks?.first?.location
                let coordinate = location?.coordinate
                self.searchLat = coordinate?.latitude
                self.searchLon = coordinate?.longitude
                print("\(self.searchLat),\(self.searchLon)")
                self.getFile()
                
            }
            
        }
        
    }
    
    //MARK: - JSON Retrieval Methods
    
    func getFile() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = "\(hostName)\(key)/\(searchLat!),\(searchLon!)"
        print("urlString is \(urlString)")
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let receivedData = data else {
                
                print("No Data")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
                
            }
            if receivedData.count > 0 && error == nil {
                
                print("Received Data:\(receivedData)")
                let dataString = String.init(data: receivedData, encoding: .utf8)
                print("Got Data String:\(dataString!)")
                self.parseJson(data: receivedData)
                
            } else {
                
                print("Got Data of Length 0")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            }
            
        }
        
        task.resume()
        
    }
    
    func parseJson(data: Data) {
        
        do {
            
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            print("JSON:\(jsonResult)")
            let currentWeatherJson = jsonResult as! [String:Any]
            currentWeather.lat = currentWeatherJson["latitude"] as? Double
            currentWeather.lon = currentWeatherJson["longitude"] as? Double
            let time = currentWeatherJson["currently"] as? [String:Any]
            currentWeather.time = time?["time"] as? Double
            let icon = currentWeatherJson["currently"] as? [String:Any]
            currentWeather.icon = icon?["icon"] as? String
            let temp = currentWeatherJson["currently"] as? [String:Any]
            currentWeather.temp = temp?["temperature"] as? Int
            let apparentTemp = currentWeatherJson["currently"] as? [String:Any]
            currentWeather.apparentTemp = apparentTemp?["apparentTemperature"] as? Int
            print("Lat: \(currentWeather.lat), Lon: \(currentWeather.lon)")
            print("Date: \(currentWeather.convertedTime), Icon: \(currentWeather.icon)")
            print("Temp: \(currentWeather.temp), Feels Like: \(currentWeather.apparentTemp)")
            DispatchQueue.main.async {
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.updateDisplay()
                self.setWeatherIcon(wIcon: self.currentWeather.icon!)
                
            }
            
        } catch {
            
            print("JSON Parsing Error")
            
        }
        
        DispatchQueue.main.async {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
        
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tempLabel.alpha = 0.0
        feelsLikeLabel.alpha = 0.0
        dateLabel.alpha = 0.0
        weatherIcon.image = UIImage(named: "logo")
        setupLocationMonitoring()
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLoc = locations.last!
        searchLat = lastLoc.coordinate.latitude
        searchLon = lastLoc.coordinate.longitude
        print("\(searchLat),\(searchLon)")
        getFile()
        manager.stopUpdatingLocation()
        
    }
    
    //MARK: - Location Authorization Methods
    
    func turnOnLocationMonitoring() {
        
        locationMgr.startUpdatingLocation()
        
    }
    
    func setupLocationMonitoring() {
        locationMgr.delegate = self
        locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                turnOnLocationMonitoring()
            case .denied, .restricted:
                print("Hey turn us back on in Settings!")
            case .notDetermined:
                if locationMgr.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) {
                    locationMgr.requestAlwaysAuthorization()
                }
            }
        } else {
            print("Hey Turn Location On in Settings!")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        setupLocationMonitoring()
    }
    
}

