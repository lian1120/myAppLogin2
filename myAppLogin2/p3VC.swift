//
//  p3VC.swift
//  myAppLogin2
//
//  Created by 江禮安 on 2017/10/12.
//  Copyright © 2017年 江禮安. All rights reserved.
//

import UIKit
import MapKit//地圖
import CoreLocation//定位

class p3VC: UIViewController,CLLocationManagerDelegate {
    
    //兩點坐標，進行導航
    
    let app = UIApplication.shared.delegate as! AppDelegate  //找AppDelegate的資源變數
    
    let lmgr = CLLocationManager()//地圖管理員
    
    let queue = DispatchQueue(label: "q1", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent)//背景執行緒
    
    var adversaryLat:Double = 0.0, adversaryLng:Double = 0.0//對手的經緯度
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adversaryLat = app.adversaryLat
        adversaryLng = app.adversaryLng
        //print("p3VC=> \(adversaryLat) : \(adversaryLng)")
        //獲得允許 使用者GPS位置
        lmgr.requestAlwaysAuthorization()
        lmgr.delegate = self
        lmgr.startUpdatingLocation()//開始更新使用者所在位置經緯度
    }

    //不間斷的更新現在的GPS位置
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if locations.count > 0 {
            let lat = locations.first?.coordinate.latitude
            let lng = locations.first?.coordinate.longitude
            print("update start: \(lat!), \(lng!)")
            goDir(lat:lat!, lng:lng!)
            lmgr.stopUpdatingLocation() //stop
        }
    }
    
    func goDir(lat:CLLocationDegrees, lng:CLLocationDegrees) {
        //print("start: \(lat), \(lng)")
        //呼叫內建地圖。兩點坐標，進行地圖導航
        let start = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let end = CLLocationCoordinate2D(latitude: adversaryLat, longitude: adversaryLng)
        //CLLocationCoordinate2D.init(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
        let start2 = MKPlacemark(coordinate: start)
        let end2 = MKPlacemark(coordinate: end)
        //MKPlacemark.init(coordinate: CLLocationCoordinate2D) =>Initializes and returns a placemark object using the specified coordinate.
        
        let item1 = MKMapItem(placemark: start2)
        let item2 = MKMapItem(placemark: end2)
        //MKMapItem.init(placemark: MKPlacemark) =>Initializes and returns a map item object using the specified placemark object.
        
        let ps = [item1, item2]
        let mode = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
        
        MKMapItem.openMaps(with: ps, launchOptions: mode)
        //MKMapItem.openMaps(with mapItems: [MKMapItem], launchOptions: [String : Any]? = nil) -> Bool
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
