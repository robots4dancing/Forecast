//
//  ViewController.swift
//  Forecast
//
//  Created by Valerie Greer on 3/20/17.
//  Copyright © 2017 Shane Empie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let hostName = "https://api.darksky.net/forecast/"
    
    //MARK: - Information Retrieval Methods
    
    func getFile() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = hostName
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
            let museumArray = jsonResult as! [[String:Any]]
            masterMuseumArray.removeAll()
            for museumDictionary in museumArray {
                guard let museumName = museumDictionary["commonname"] as? String else {
                    continue
                }
                guard let museumStreet = museumDictionary["location_1_address"] as? String else {
                    continue
                }
                guard let museumCity = museumDictionary["location_1_city"] as? String else {
                    continue
                }
                guard let museumState = museumDictionary["location_1_state"] as? String else {
                    continue
                }
                guard let museumZip = museumDictionary["location_1_zip"] as? String else {
                    continue
                }
                guard let location = museumDictionary["location_1"] as? [String:Any] else {
                    continue
                }
                guard let point = location["coordinates"] as? [Double]? else {
                    continue
                }
                guard let museumLon = point?[0] else {
                    continue
                }
                guard let museumLat = point?[1] else {
                    continue
                }
                
                let newMuseum = Museum(museumName: museumName, museumStreet: museumStreet, museumCity: museumCity, museumState: museumState, museumZip: museumZip, museumLon: museumLon, museumLat: museumLat)
                masterMuseumArray.append(newMuseum)
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .reload, object: nil)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

