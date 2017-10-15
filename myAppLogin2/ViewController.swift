//
//  ViewController.swift
//  myAppLogin2
//
//  Created by 江禮安 on 2017/10/12.
//  Copyright © 2017年 江禮安. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let app = UIApplication.shared.delegate as! AppDelegate  //找AppDelegate的資源變數

    @IBOutlet weak var loginResult: UILabel!//登入錯誤訊息
    
    @IBOutlet weak var account: UITextField!//帳號輸入框
    
    @IBOutlet weak var passwd: UITextField!//密碼輸入框
    
    @IBOutlet weak var passwdRepeat: UITextField!//再次輸入密碼框
    
    @IBOutlet weak var warning: UILabel!//新增會員密帳 錯誤訊息
    
    let queue = DispatchQueue(label:"tw.org.iii.q1", attributes: .concurrent)
    
    var checkOK = false  //新增的帳號密碼是否符合條件
    
    
    
    
    @IBAction func login(_ sender: Any) {
        //會員(帳號密碼)登入 . 出現對話框  alert 建構子
        
        let alert = UIAlertController(title: "~歡迎光臨~", message: "請輸入帳號密碼", preferredStyle: .alert)
        //增加文字輸入框：帳號
        alert.addTextField { (textAccount) in
            textAccount.placeholder = "輸入帳號"
        }
        //增加文字輸入框：密碼
        alert.addTextField { (textPasswd) in
            textPasswd.placeholder = "輸入密碼"
            textPasswd.isSecureTextEntry = true
        }
        //增加對話框按鈕
        let okAction =  UIAlertAction(title: "登入", style: .default) {
            (action) in
            
            //當使用者輸入帳密，按下ok之後會做的事
            let account = alert.textFields![0].text
            let passwd = alert.textFields![1].text
            
            //呼叫自訂方法 判斷帳號密碼正確與否
            self.dologin(account: account!, passwd: passwd!)
        }
        alert.addAction(okAction)  //對話框加入按鈕功能
        
        present(alert, animated: true)  //present，對話框 執行的指令
    }
    
    private func dologin(account:String, passwd:String) {
        //登入之前 驗證帳密其中之一為空字串，登入失敗
        if account == "" || passwd == "" { return
        }else{
            let url3 = URL(string: "http://localhost:8888/3.php")
            var req = URLRequest(url: url3!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
            
            //將帳密訊息寫入HTTP body，送出資料透過URLRequest
            req.httpBody = "account=\(account)&passwd=\(passwd)".data(using: .utf8)
            req.httpMethod = "POST"
            
            //session的組態設定
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            //用datatask執行任務內容
            let task = session.dataTask(with: req) {
                (data, response, error) in
                
                guard error == nil else {return}  //守門員
                
                //回傳資料用utf8解碼
                let result = String(data: data!, encoding: String.Encoding.utf8)
                print("登入是否成功 傳回的結果")
                print(result!)//背景執行完畢就畫面跳轉，不然就回應錯誤
                DispatchQueue.main.sync {
                    if result == "1" {
                        self.app.account = account
                        if let vc2 =
                            self.storyboard?.instantiateViewController(withIdentifier: "second"){
                            self.show(vc2, sender: self)}
                    }else{ self.loginResult.text = "登入錯誤" }
                }
            }
            task.resume()  //任務執行
        }
    }
    
    
    @IBAction func accountCheck(_ sender: Any) {
        //確認 帳號的 唯一性UITextField
        let account2 = account.text
        queue.async {
            let url = URL(string: "http://localhost:8888/2.php")
            
            //建立一個urlRequest。httpBody寫入帳密資料。httpMethod為POST
            //逾時連線60秒
            var  req = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
            
            //將帳密訊息寫入HTTP body
            req.httpBody = "account=\(account2!)".data(using: .utf8)
            req.httpMethod = "POST"
            //以上是做設定，送出資料透過URLRequest
            print("-------------------")
            print(req.httpBody!)
            
            //session的組態設定
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            //用datatask執行任務內容
            let task = session.dataTask(with: req) {
                (data, response, error) in
                
                guard error == nil else {return} //守門員
                
                //回傳資料用utf8解碼
                let result = String(data: data!, encoding: String.Encoding.utf8)
                print("確認帳號唯一性:0代表可以註冊")
                print(result!)
                DispatchQueue.main.async {
                    if result == "1" {
                        self.warning.text = "此帳號已經被註冊"
                    }else{
                        self.warning.text = "此帳號可以註冊"
                        self.checkOK = true
                    }
                }
            }
            task.resume()  //任務執行
        }
    }
    
    //新增會員帳密
    @IBAction func addMember(_ sender: Any) {
        //帳號輸入框 為空白時，有提示和文字框得焦
        if account.text == "" {
            warning.text = "請輸入帳號";account.becomeFirstResponder();return }
        
        //密碼輸入框 為空白時，有提示和文字框得焦
        if passwd.text == "" {
            warning.text = "請輸入密碼";passwd.becomeFirstResponder();return }
        
        //密碼複雜性未達標時，有提示和文字框得焦
        if !isPasswordValid(self.passwd.text!) {
            warning.text = "請輸入含有英數符號六碼以上";
            passwd.becomeFirstResponder();return }
        
        //密碼兩次不相符時，有提示和文字框得焦
        if passwd.text != passwdRepeat.text {
            warning.text = "請輸入相同密碼" ;
            passwdRepeat.becomeFirstResponder();return }
        
        //帳號密碼符合以上判斷後，就新增資料寫進資料庫
        if (passwd.text == passwdRepeat.text) && checkOK {
            add(account: account.text!, passwd: passwd.text!)
        }else { return }
    }
    
    //密碼複雜性驗證 - 正規表示式 regex
    private func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{6,}")
        return passwordTest.evaluate(with: password)
    }
    
    
    private func add(account: String, passwd: String) {
        let url = URL(string: "http://localhost:8888/4.php")
        
        //建立一個urlRequest。httpBody寫入帳密資料。httpMethod為POST
        //逾時連線60秒
        var  req = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        
        //將帳密訊息寫入HTTP body，送出資料透過URLRequest
        req.httpBody = "account=\(account)&passwd=\(passwd)".data(using: .utf8)
        req.httpMethod = "POST"
        
        //session的組態設定
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        //用datatask執行任務內容
        let task = session.dataTask(with: req) {
            (data, response, error) in
            
            guard error == nil else {return}  //守門員
            
            //回傳資料用utf8解碼
            let result = String(data: data!, encoding: String.Encoding.utf8)
            print("新增會員是否成功 傳回的結果")
            print(result!)
            DispatchQueue.main.async {
                if  result! == "1" {
                    self.app.account = account
                    if let vc2 =
                        self.storyboard?.instantiateViewController(withIdentifier: "second"){
                        self.show(vc2, sender: self)}
                }else{ return }
            }
        }
        task.resume()  //任務執行
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //密碼輸入框 為 不可見
        passwd.isSecureTextEntry = true
        passwdRepeat.isSecureTextEntry = true
        
        //三種顏色的數值
        let color1 = UIColor(red:0, green:0.95, blue:0.55, alpha:0.6)
        let color2 = UIColor(red:0.6, green:0.7, blue:0.8, alpha:0.2)
        let color3 = UIColor(red:0, green:0.55, blue:0.95, alpha:0.7)
        
        //漸層 建構式
        let gradient = CAGradientLayer()
        gradient.frame = self.view.frame
        gradient.colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        
        //背景 設計為漸層顏色
        self.view.layer.insertSublayer(gradient,at:0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

