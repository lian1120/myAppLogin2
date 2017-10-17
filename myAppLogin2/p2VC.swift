//
//  p2VC.swift
//  myAppLogin2
//
//  Created by 江禮安 on 2017/10/12.
//  Copyright © 2017年 江禮安. All rights reserved.
//

import UIKit
import CoreLocation//這頁要寫：取得使用者所在經緯度，然後上傳lat,lng到資料庫

class p2VC: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,CLLocationManagerDelegate {
    //實作pickerView協定
    let app = UIApplication.shared.delegate as! AppDelegate  //找AppDelegate的資源變數
    
    @IBOutlet weak var name: UILabel!//歡迎光臨：OO帳號 使用
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    let imageArray:[String] = ["🍎","🍀","🐮","🐼","🐔","🎅","🚍","💖","👑","👻"]
    var dataArray1:[Int] = []
    var dataArray2:[Int] = []
    var dataArray3:[Int] = []
    
    @IBOutlet weak var result: UILabel!//拉霸之後顯示結果
    
    //拉霸
    @IBAction func skip(_ sender: Any) {
        //滾動三個component，使用亂數決定 要顯示哪一個圖案
        pickerView.selectRow(Int(arc4random()%97)+3, inComponent: 0, animated: true)
        pickerView.selectRow(Int(arc4random()%97)+3, inComponent: 1, animated: true)
        pickerView.selectRow(Int(arc4random()%97)+3, inComponent: 2, animated: true)
        
        //判斷三個component的selectedRow的數字，如果三個都相同就是Bingo
        if(dataArray1[pickerView.selectedRow(inComponent: 0)] == dataArray2[pickerView.selectedRow(inComponent: 1)] &&
            dataArray2[pickerView.selectedRow(inComponent: 1)] == dataArray3[pickerView.selectedRow(inComponent: 2)]) {
            
            result.text = "Bingo!!"
        } else {
            result.text = ""
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3  //有三個元素components
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100  //在一個元素component中有百個row
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100.0  //設定元素的寬
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 100.0  //設定元素row的高
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let picker = UILabel()  //指定三個元素的row的內容
        if component == 0 {
            picker.text = imageArray[Int(dataArray1[row])]//由亂數決定Emoji
        }else if component == 1 {
            picker.text = imageArray[Int(dataArray2[row])]
        }else {
            picker.text = imageArray[Int(dataArray3[row])]
        }
        picker.font = UIFont(name: "Arial-BoldMT", size: 100)  //設定字型大小
        picker.textAlignment = NSTextAlignment.center  //設定對齊為置中
        return picker
    }
  
    
    
    
    var id = ""//修改帳密需要有id
    
    @IBOutlet weak var accountLabel: UILabel!//帳號標籤
    
    @IBOutlet weak var account: UITextField!//帳號輸入框
    
    @IBOutlet weak var passwdLabel: UILabel!//密碼標籤
    
    @IBOutlet weak var passwd: UITextField!//密碼輸入框
    
    @IBOutlet weak var passwdRLabel: UILabel!//再確認密碼標籤
    
    @IBOutlet weak var passwdR: UITextField!//再確認密碼輸入框
    
    @IBOutlet weak var warning: UILabel!//有錯誤 提示訊息
    
    @IBOutlet weak var confirm: UIButton!//確定 按鈕的屬性outlet
    
    let queue = DispatchQueue(label:"tw.org.iii.q2", attributes: .concurrent)
    
    var checkOK = false, checkOK2 = false, checkpasswdR = false
    
    //修改按鈕：顯示帳密輸入框 與 取得帳號的id
    @IBAction func modify(_ sender: Any) {
        let account2 = app.account  //取得使用者的帳號
        queue.async {
            let url = URL(string: "http://localhost:8888/1.php")
            
            //建立一個urlRequest。httpBody寫入id資料。httpMethod為POST
            var  req = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
            
            //將帳號訊息寫入HTTP body
            req.httpBody = "account=\(account2)".data(using: .utf8)
            req.httpMethod = "POST"
            
            //session的組態設定
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            //用datatask執行任務內容
            let task = session.dataTask(with: req) {
                (data, response, error) in
                guard error == nil else {return} //守門員
                
                //回傳資料用utf8解碼
                let result = String(data: data!, encoding: String.Encoding.utf8)
                DispatchQueue.main.async {
                    self.id = result!  //從PHP取得的id
                }
            }
            task.resume()  //任務執行
        }
        
        //原本是隱藏，按下後顯示修改的欄位和按鈕
        account.text = app.account
        passwd.text = ""
        passwdR.text = ""
        accountLabel.isHidden = false
        account.isHidden = false
        passwdLabel.isHidden = false
        passwd.isHidden = false
        passwdRLabel.isHidden = false
        passwdR.isHidden = false
        confirm.isHidden = false
        warning.isHidden = false
    }
    
    @IBAction func accountCheck(_ sender: Any) {
        let account2 = account.text!
        if account.text != name.text {  //確認 帳號的 唯一性UITextField
            queue.async {
                let url = URL(string: "http://localhost:8888/2.php")
                
                //建立一個urlRequest。httpBody寫入帳密資料。httpMethod為POST
                var  req = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
                
                //將帳密訊息寫入HTTP body
                req.httpBody = "account=\(account2)".data(using: .utf8)
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
                    DispatchQueue.main.async {
                        if result == "1" {
                            self.warning.text = "已經被註冊"
                        }else{
                            self.warning.text = "可以註冊"
                            self.checkOK = true
                        }
                    }
                }
                task.resume()  //任務執行
            }
        }else{ checkOK = true }
    }
    
    @IBAction func passwdCheck(_ sender: Any) {
        if isPasswordValid(passwd.text!) {
            checkOK2 = true
        }else{
            warning.text = "請輸入含有英數符號六碼以上"
        }
    }
    
    //密碼複雜性驗證 - 正規表示式 regex 條件：包含英數符號至少六位數
    private func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{6,}")
        return passwordTest.evaluate(with: password)
    }
    
    @IBAction func passwdRCheck(_ sender: Any) {
        if passwd.text != passwdR.text {
            warning.text = "請輸入相同密碼"
            passwdR.becomeFirstResponder()
        }else {
            checkpasswdR = true
        }
    }
    
    //修改帳號密碼 傳送到PHP 儲存在MySQL
    @IBAction func confirm(_ sender: Any) {
        if checkOK && checkOK2 && checkpasswdR {  //判斷三種狀態是否為true
            let id2 = id  //取得必要的資料
            let account2 = account.text!
            let passwd2 = passwd.text!
            queue.async {
                let url = URL(string: "http://localhost:8888/5.php")
                
                //建立一個urlRequest。httpBody寫入帳密資料。httpMethod為POST
                var  req = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
                
                //將帳密訊息寫入HTTP body
                req.httpBody = "id=\(id2)&account=\(account2)&passwd=\(passwd2)".data(using: .utf8)
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
                    DispatchQueue.main.async {
                        if result == "1" {
                            self.warning.text = "修改完成"
                        }else{
                            self.warning.text = "修改失敗"
                        }
                    }
                }
                task.resume()  //任務執行
            }
        }
    }
    
    
    
    
    private let lmgr = CLLocationManager()//地圖管理員
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for loc in locations {
            //已經取得 現在所在的坐標
            //loc.altitude 高度；海拔,  loc.horizontalAccuracy 水平精確
            let lat = loc.coordinate.latitude
            let lng = loc.coordinate.longitude
            sendLatLngToServer(lat:lat, lng:lng)//呼叫方法 上傳坐標到伺服器
            print("p2VC上傳:\(lat)，\(lng)")
        }
    }
    
    //上傳GPS到伺服器，更新使用者現在所在的坐標
    private func sendLatLngToServer(lat:CLLocationDegrees, lng:CLLocationDegrees) {
        let account2 = app.account
        
        queue.async {
            let url = URL(string: "http://localhost:8888/7.php")
            
            //建立一個urlRequest。
            var  req = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
            
            //將帳號與坐標位置寫入HTTP body。送出資料透過httpMethod為POST
            req.httpBody = "account=\(account2)&lat=\(lat)&lng=\(lng)".data(using: .utf8)
            req.httpMethod = "POST"
            
            //session的組態設定
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            //用datatask執行任務內容
            let task = session.dataTask(with: req) {
                (data, response, error) in
                guard error == nil else {return} //守門員
                
                //回傳資料用utf8解碼
                let result = String(data: data!, encoding: String.Encoding.utf8)
                DispatchQueue.main.async {
                    if result == "1" {
                        self.warning.text = ""  //"已上傳GPS到伺服器"
                        self.lmgr.stopUpdatingLocation()//要結束GPS更新
                    }else{
                        self.warning.text = ""  //"無上傳GPS到伺服器"
                    }
                }
            }
            task.resume()  //任務執行
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //顯示使用者的帳號。隱藏修改帳密按鈕。
        name.text = app.account
        accountLabel.isHidden = true
        account.isHidden = true
        warning.isHidden = true
        passwdLabel.isHidden = true
        passwd.isHidden = true
        passwdRLabel.isHidden = true
        passwdR.isHidden = true
        warning.isHidden = true
        confirm.isHidden = true
        passwd.isSecureTextEntry = true
        passwdR.isSecureTextEntry = true
        
        
        for _ in 0..<100 {  //產生0~10的亂數一百個
            dataArray1.append(Int(arc4random_uniform(100)%10))
            dataArray2.append(Int(arc4random_uniform(100)%10))
            dataArray3.append(Int(arc4random_uniform(100)%10))
        }
        result.text = ""
        
        
        //在背景中，GPS抓現在所在的位置。詢問使用者給權限
        lmgr.requestAlwaysAuthorization()
        //GPS定位的管理員 委託viewcontroller 實作
        lmgr.delegate = self
        //方法呼叫，開始更新GPS的數值
        lmgr.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
