//
//  ViewController.swift
//  Weather
//
//  Created by Admin on 08/02/17.
//  Copyright © 2017 Arun. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class ViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var condition1Label: UILabel!
    @IBOutlet weak var condition2Label: UILabel!
    @IBOutlet weak var condition3Label: UILabel!
    
    
    @IBOutlet weak var img1View: UIImageView!
    @IBOutlet weak var img2View: UIImageView!
    @IBOutlet weak var img3View: UIImageView!
    
    
    @IBOutlet weak var degreeValue: UIButton!
    
    @IBOutlet weak var degree1Label: UILabel!
    @IBOutlet weak var degree2Label: UILabel!
    @IBOutlet weak var degree3Label: UILabel!
    
    
    
    var degreec = [Int]()
    var degreef = [Int]()
    var condition = [String]()
    var imgURL = [String]()
    var city: String!
    var exists: Bool = true
    var unit:Bool = true
    let locationManager = CLLocationManager()
    var index :Int!
    var lati :Double!
    var longi :Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func locationButton(_ sender: UIButton) {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        CLGeocoder().reverseGeocodeLocation(locationManager.location!) { (placemarks, error) -> Void in
            if (error != nil){
                return
            }
            if (placemarks?.count)!>0{
                let pm = (placemarks?[0])! as CLPlacemark
                self.searchBar.text = pm.locality!
                self.searchBarSearchButtonClicked(self.searchBar)
                
            }
            else{
            }
        }
//        let location = CLLocation(latitude: self.lati, longitude: self.longi)
//        geoTag.reverseGeocodeLocation(location) { (placemarks, error) in
//            if error == nil && placemarks.count > 0 {
//                self.placeMark = placemarks.last as? CLPlacemark
//                self.cityLabel.isHidden = false
//                self.cityLabel.text = "\(self.placeMark!.locality)"
//            }
//        }

    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let urlRequest : URLRequest!
                urlRequest = URLRequest(url: URL(string : "http://api.apixu.com/v1/forecast.json?key=c5f88c73778641f19d8193725170802&q=\(searchBar.text!.replacingOccurrences(of: " ", with: "%20"))&days=3")!)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                    
                    if let current = json["current"] as? [String : AnyObject] {
                        if let temp = current["temp_c"] as? Int {
                            self.degreec.append(temp)
                        }
                        if let temp = current["temp_f"] as? Int {
                            self.degreef.append(temp)
                        }
                        if let condition = current["condition"] as? [String: AnyObject]{
                            self.condition.append(condition["text"] as! String)
                            let icon = condition["icon"] as! String
                            self.imgURL.append("http:\(icon)")
                        }
                    }
                    if let forecast = json["forecast"] as? [String : AnyObject] {
                        if let forecastday = forecast["forecastday"] as? [[String : AnyObject]]{

                            for index in 1..<forecastday.count{
                                if let day = forecastday[index]["day"] as? [String : AnyObject]{
                                    if let temp = day["avgtemp_c"] as? Int{
                                        self.degreec.append(temp)
                                    }
                                    if let temp = day["avgtemp_f"] as? Int{
                                        self.degreef.append(temp)
                                    }
                                    if let condition = day["condition"] as? [String: AnyObject]{
                                        let text = condition["text"] as! String
                                        self.condition.append("\(text)")
                                        let icon = condition["icon"] as! String
                                        self.imgURL.append("http:\(icon)")
                                    }
                                }
                            }
                        }
                    }
                    
                    if let location = json["location"] as? [String : AnyObject]{
                        self.city = location["name"] as! String
                    }
                    
                    if let _ = json["error"] {
                        self.exists = false
                    }
                    
                    DispatchQueue.main.sync {
                        if self.exists{
                            self.degree1Label.isHidden = false
                            self.degree2Label.isHidden = false
                            self.degree3Label.isHidden = false
                            self.condition1Label.isHidden = false
                            self.condition2Label.isHidden = false
                            self.condition3Label.isHidden = false
                            self.cityLabel.isHidden = false
                            self.degree1Label.text = "\(self.degreec[0].description)°C"
                            self.cityLabel.text = self.city
                            self.condition1Label.text = self.condition[0]
                            self.degree2Label.text = "\(self.degreec[1].description)°C"
                            self.condition2Label.text = self.condition[1]
                            self.degree3Label.text = "\(self.degreec[2].description)°C"
                            self.condition3Label.text = self.condition[2]
                            self.img1View.downloadImage(from: self.imgURL[0])
                            self.img2View.downloadImage(from: self.imgURL[1])
                            self.img3View.downloadImage(from: self.imgURL[2])
                        } else {
                            self.degree1Label.isHidden = true
                            self.degree2Label.isHidden = true
                            self.degree3Label.isHidden = true
                            self.cityLabel.text = "NO CITY FOUND"
                            self.condition1Label.isHidden = true
                            self.condition2Label.isHidden = true
                            self.condition3Label.isHidden = true
                            self.exists = true
                        }
                    }
                    
                }catch let jsonError{
                    print(jsonError.localizedDescription)
                }
            }
        }
        condition.removeAll()
        degreec.removeAll()
        degreef.removeAll()
        imgURL.removeAll()
        task.resume()
            
        }
    
    @IBAction func changeUnit(_ sender: Any) {
        if unit {
            self.degree1Label.text = "\(self.degreef[0].description)°F"
            self.degree2Label.text = "\(self.degreef[1].description)°F"
            self.degree3Label.text = "\(self.degreef[2].description)°F"
            unit = false
        }
        else{
            self.degree1Label.text = "\(self.degreec[0].description)°C"
            self.degree2Label.text = "\(self.degreec[1].description)°C"
            self.degree3Label.text = "\(self.degreec[2].description)°C"
            unit = true
        }
    }
    
    }
extension UIImageView{
    func downloadImage(from url:String){
        let urlRequest = URLRequest(url: URL(string : url)!)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil{
                DispatchQueue.main.async {
                    self.image = UIImage(data: data!)
                }
            
            }
        }
        task.resume()
    }
}
