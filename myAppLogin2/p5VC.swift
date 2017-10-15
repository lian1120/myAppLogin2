//
//  p5VC.swift
//  myAppLogin2
//
//  Created by 江禮安 on 2017/10/15.
//  Copyright © 2017年 江禮安. All rights reserved.
//

import UIKit
import Speech

class p5VC: UIViewController,SFSpeechRecognizerDelegate {
    
    //語音輸入。speech:說話能力、言詞、言論、演說、演講
    //zh ->語系，TW->地區，locale:(事情發生的）現場，場所
    var audioEngine = AVAudioEngine()  //語音引擎
    var request = SFSpeechAudioBufferRecognitionRequest()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-TW"))
    var recognitionTask:SFSpeechRecognitionTask? = nil
    
    @IBOutlet weak var sendMessageAttribute: UIButton!  //傳送訊息的按鈕屬性值
    
    @IBOutlet weak var messageArea: UITextView!  //語音留言的文字輸出框
    
    @IBOutlet weak var previously: UITextView!  //先前的留言輸出框
    
    @IBOutlet weak var isWho: UITextField!  //要留言給誰，文字輸入框
    
    
    //按鈕，功能為開始接收聲音
    @IBAction func startSpeech(_ sender: Any) {
        if audioEngine.isRunning {
            //中斷語音
            audioEngine.stop()
            request.endAudio()
            audioEngine.reset()  //清除先前的記憶體內容
        }else{
            //開始錄音
            sendMessageAttribute.isHidden = false  //不隱藏 傳送按鈕
            audioEngine = AVAudioEngine()  //重新建立語音引擎
            startRecording()  //自訂方法，開始接收聲音
        }
    }
    
    
    func startRecording() {
        //處理目前正在辨識中的任務
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        //Measurement：測量、尺寸、大小
        //notify：通知、報告
        //Deactivation：沒有啟動、無觸發
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            print()
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            
            //每按一次語音辨識，是不同的request，所以都要重新建立
            //Partial:部分的，局部的
            request = SFSpeechAudioBufferRecognitionRequest()  //建構式
            request.shouldReportPartialResults = true  //屬性
            
            let inputNode = audioEngine.inputNode
            
            //這是背景執行
            speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
                //如果有結果，將"結果"轉換為字串，並且顯示在testLabel
                if result != nil {
                    self.messageArea.text = result?.bestTranscription.formattedString
                }
            })
            
            //錄音進來。這段很重要。
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format:recordingFormat) {
                (buffer, when) in
                self.request.append(buffer)
            }
            
            audioEngine.prepare()
            do {
                try audioEngine.start()
            }catch{
                print("error2:\(error)")
            }
            
        }catch {
            print("error1:\(error)")
        }
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
        print(messageArea.description)
    
    }
    
    
    
    
    
    
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        sendMessageAttribute.isHidden = true  //隱藏 傳送按鈕
        //使用者授權 權限
        SFSpeechRecognizer.requestAuthorization { (status) in
            switch status {
            case .authorized :
                print("OK")
            case .denied :
                print("cancel")
            default:
                print("xx")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
