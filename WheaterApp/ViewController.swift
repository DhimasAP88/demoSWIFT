//
//  ViewController.swift
//  WheaterApp
//
//  Created by BlackMamba on 20/09/18.
//  Copyright © 2018 BlackMamba. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class ViewController: UIViewController {

    @IBOutlet var page: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var jktBtn: UIButton!
    @IBOutlet weak var bdgBtn: UIButton!
    @IBOutlet weak var srbBtn: UIButton!
    
    @IBOutlet weak var temperatur: UILabel!
    @IBOutlet weak var cuaca: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var wheaterIcon: UIImageView!
    
    @IBOutlet weak var wheaterIconDay: UIImageView!
    @IBOutlet weak var wheaterIconNight: UIImageView!
    @IBOutlet weak var wheaterDayTxt: UILabel!
    @IBOutlet weak var wheaterNigthTxt: UILabel!
    @IBOutlet weak var imageday: UIWebView!
    @IBOutlet weak var imagenight: UIWebView!
    
    var isFarenheit = false
    var celciusDegree = 0
    
    let apikey = "p6uZmdpo7rj0DAg37Lm5GPHn0u4jyMKi"
    let host = "https://dataservice.accuweather.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label1.text = "-"
        clearBackgroundBtn()
        srbBtn.layer.cornerRadius = 5
        srbBtn.layer.borderWidth = 1
        srbBtn.layer.borderColor = UIColor.white.cgColor
        
        bdgBtn.layer.cornerRadius = 5
        bdgBtn.layer.borderWidth = 1
        bdgBtn.layer.borderColor = UIColor.white.cgColor
        
        jktBtn.layer.cornerRadius = 5
        jktBtn.layer.borderWidth = 1
        jktBtn.layer.borderColor = UIColor.white.cgColor
        
        imageday.backgroundColor = UIColor.clear
        imagenight.backgroundColor = UIColor.clear
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wheater.jpg")!)
        
        
    }

    @IBAction func jakartaBtn(_ sender: Any) {
        clearBackgroundBtn()
        label1.text = "Jakarta"
        setBackgroundClr(uiBtn: jktBtn)
        requestGeoposition(latLongitude: "-6.117664,106.906349")
    }
    
    @IBAction func bandungBtn(_ sender: Any) {
        clearBackgroundBtn()
        label1.text = "Bandung"
        setBackgroundClr(uiBtn: bdgBtn)
        requestGeoposition(latLongitude: "-6.914744,107.609810")
    }
    
    @IBAction func surabayaBtn(_ sender: Any) {
        clearBackgroundBtn()
        label1.text = "Surabaya"
        setBackgroundClr(uiBtn: srbBtn)
        requestGeoposition(latLongitude: "-7.250445,112.768845")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setBackgroundClr(uiBtn: UIButton){
        uiBtn.backgroundColor = UIColor(rgb: 0x65d36e)
        uiBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
    }

    private func clearBackgroundBtn() {
        srbBtn.backgroundColor = UIColor.clear
        srbBtn.setTitleColor(UIColor.blue, for: UIControlState.normal)
        
        bdgBtn.backgroundColor = UIColor.clear
        bdgBtn.setTitleColor(UIColor.blue, for: UIControlState.normal)
        
        jktBtn.backgroundColor = UIColor.clear
        jktBtn.setTitleColor(UIColor.blue, for: UIControlState.normal)
        
    }
    
    
    
    
    private func requestGeoposition(latLongitude: String) {
        
        let url = host + "/locations/v1/cities/geoposition/search?apikey=" + apikey + "&q=" + latLongitude
        Alamofire.request(url).responseJSON { response in

            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                if let jsondata = json as? [String: Any], let data = jsondata["Key"] as? String {
                    self.requestCurrentCondition(uniqueId: data)
                }
            }
        }
    }
    
    private func requestCurrentCondition(uniqueId: String){
        let url = host + "/currentconditions/v1/" + uniqueId + "?apikey=" + apikey
        Alamofire.request(url).responseJSON { response in
            
            if let json = response.result.value {
                
                print("JSON: \(json)") // serialized json response
                let jsondata = json  as? [[String: AnyObject]]
                
                if (jsondata == nil) {
                    let error = json as? [String: Any]
                    let error1 = error!["Message"] as? String
                    self.showAlert(message: error1!)
                } else {
                    self.requestDailyForcast(uniqueId: uniqueId)
                    for day in jsondata! {
                        
                        if  let day1 = day as? [String: Any], let resultDay1 = day1["WeatherText"] as? String {
                            self.cuaca.text = resultDay1
                        }
                        
                        if  let day1 = day as? [String: Any], let data = day1["Temperature"] as? [String: AnyObject], let subject = data["Metric"] as? [String: AnyObject], let addr = subject["Value"] as? Double {
                            self.celciusDegree = Int(addr)
                            self.temperatur.text = String(Int(addr)) + "°C"
                        }
                        
                        if  let day1 = day as? [String: Any], let date1 = day1["LocalObservationDateTime"] as? String {
                            let formatter:DateFormatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
                            let formaterDate = formatter.date(from: date1)
                            
                            formatter.dateFormat = "dd/MMM/yyyy HH:mm"
                            let dateString:String = formatter.string(from: formaterDate!)
                            
                            self.dateTime.text = dateString
                        }
                        
                        if let day1 = day as? [String: Any], let data = day1["WeatherIcon"] as? Int {
                            let urlIcon = "https://vortex.accuweather.com/adc2010/m/images/icons/600x212/slate/"+String(format: "%02d", data)+".png"
                            self.wheaterIcon.sd_setImage(with: URL(string: urlIcon), placeholderImage: UIImage(named: "sun.png"))
                        }
                    }
                }
                
                
            }
        }
    }
    
    private func requestDailyForcast(uniqueId: String){
        var iconday = 0
        var iconnight = 0
        let url = host + "/forecasts/v1/daily/1day/" + uniqueId + "?apikey=" + apikey
        Alamofire.request(url).responseJSON{ response in
            if let json = response.result.value {
                print("JSON: \(json)")
                let jsondata = json as? [String: AnyObject]
                if (jsondata == nil) {
                    let error = json as? [String: Any]
                    let error1 = error!["Message"] as? String
                    self.showAlert(message: error1!)
                } else {
                    let dailyforcase = jsondata!["DailyForecasts"] as? [[String: AnyObject]]
                    for daily in dailyforcase! {
                        let today = daily as? [String: Any]
                        let dayweather = today!["Day"] as? [String: Any]
                        iconday = (dayweather?["Icon"] as? Int)!
                        let phraseday = dayweather!["IconPhrase"] as? String
                        
                        let nightweather = today!["Night"] as? [String: Any]
                        iconnight = (nightweather!["Icon"] as? Int)!
                        let phrasenight = nightweather!["IconPhrase"] as? String
                        
                        
                        
                        let urlimageday = "https://vortex.accuweather.com/adc2010/images/slate/icons/" + String(iconday) + ".svg"
                        if let url = NSURL(string: urlimageday) {
                            let request: NSURLRequest = NSURLRequest(url: url as URL)
                            self.imageday.loadRequest(request as URLRequest)
                        }
                        self.wheaterDayTxt.text = phraseday
                        
                        self.wheaterNigthTxt.text = phrasenight
                        let urlimagenight = "https://vortex.accuweather.com/adc2010/images/slate/icons/" + String(iconnight) + ".svg"
                        if let url = NSURL(string: urlimagenight) {
                            let request: NSURLRequest = NSURLRequest(url: url as URL)
                            self.imagenight.loadRequest(request as URLRequest)
                        }
                    }
                }
            }
        }
    }

    @IBAction func changeDegree(_ sender: Any) {
        if (isFarenheit) {
            self.temperatur.text = String(self.celciusDegree) + "°C"
            isFarenheit = false
        } else {
            let fahrenheitTemperature = self.celciusDegree * 9 / 5 + 32
            self.temperatur.text = String(fahrenheitTemperature) + "°F"
            isFarenheit = true
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Service Unavailable", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

