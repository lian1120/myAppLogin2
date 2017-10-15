//
//  p4VC.swift
//  myAppLogin2
//
//  Created by 江禮安 on 2017/10/13.
//  Copyright © 2017年 江禮安. All rights reserved.
//

import UIKit
import CoreML  //機器學習

class p4VC: UIViewController,UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate {
    
    //UITableViewDataSource
    //UITableViewDelegate
    //UINavigationControllerDelegate
    
    let app = UIApplication.shared.delegate as! AppDelegate  //找AppDelegate的資源變數
    
    @IBOutlet weak var tableView: UITableView!  //TableView outlet
    
    var n = 0  //tableView的筆數
    
    var items:[String] = []  //tableView的內容

    //拿到MySQL的資料，然後填入tableView
     func getData() {
        let url = URL(string: "http://localhost:8888/8.php")//目標網址
        do {
            let data = try Data(contentsOf: url!)  //用Data(contentsOf: )拿資料
            
            //從PHP送來 JSON資料，解析JSON資料為[[String:String]]
            if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                for row in json as! [[String:String]] {
                    self.n += 1
                    self.items.append("\(row["id"]!):\(row["account"]!)")
                    //print("p4VC=>\(row["id"]!):\(row["account"]!)")
                }
            }
        }catch {
            print("failure")
        }
    }
        
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return n  //tableView的筆數
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! p4TVCell  //cell強制轉型為p4TVCell
        
        cell.contentLabel?.text = items[indexPath.row]  //row的內容 為 items的某一筆
        cell.img.image = UIImage(named: "pin")
        return cell  //tableView的內容
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "選擇一個吧!"  //tableView標頭
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "我是底層!"  //tableView表格底層
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //使用者選擇某一筆資料之後，會做的事情
        //取得對手的GPS位置
        
        
        //取得帳號 做為索引
        let account2 =  items[indexPath.row].split(separator: ":").map(String.init)
        //print("p4VC.被選的->\(account2[1])")
        let url = URL(string: "http://localhost:8888/6.php")
        
        //建立一個urlRequest。httpBody拿到帳密資料。httpMethod為POST
        var  req = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        
        //將帳密訊息寫入HTTP body
        req.httpBody = "account=\(account2[1])".data(using: .utf8)
        req.httpMethod = "POST"
        //以上是做設定，送出資料透過URLRequest
        
        //session的組態設定
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        //用datatask執行任務內容
        let task = session.dataTask(with: req) {
            (data, response, error) in
            
            guard error == nil else {return} //守門員
            
            //回傳資料用utf8解碼
            
            let result = String(data: data!, encoding: String.Encoding.utf8)
            let latlng = result?.characters.split(separator: ",").map(String.init)
            DispatchQueue.main.sync {
                self.app.adversaryLat = Double(latlng![0])!
                self.app.adversaryLng = Double(latlng![1])!
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "p3VC"){self.show(vc, sender: self)}else{}
            }
        }
        task.resume()  //任務執行
    }
    
    
    
    
    //機器學習
    var model: Inceptionv3!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var classifier: UILabel!
    
    @IBAction func doCamera(_ sender: Any) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        
        present(cameraPicker, animated: true)
    }
    
    @IBAction func doLibrary(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        model = Inceptionv3()
    }
    
    
    
    
    override func viewDidLoad() {
        getData()
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//自訂延伸類別，實作image picker controller delegete
extension p4VC: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        classifier.text = "Analyzing Image..."
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
        
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        imageView.image = newImage
        
        
        guard let prediction = try? model.prediction(image: pixelBuffer!) else {
            return
        }
        
        classifier.text = "I think this is a \(prediction.classLabel)."
    }
}
