//
//  WordOCRViewController.swift
//  BearOCR
//
//  Created by zly on 2019/5/6.
//  Copyright © 2019 zly. All rights reserved.
//

import UIKit
import DKImagePickerController
import AipOcrSdk
import JXPhotoBrowser

class WordOCRViewController: UIViewController {

    @IBOutlet weak var selectImageView: UIImageView!
    @IBOutlet weak var resultTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // 百度sdk key
        AipOcrService.shard()?.auth(withAK: "your ak", andSK: "your sk")
        let tapGes:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapAction))
        selectImageView.addGestureRecognizer(tapGes)
        selectImageView.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    var dataSource:Array<UIImage> = [];
    @objc func imageTapAction() {
        // 数据源
        let dataSource = JXLocalDataSource(numberOfItems: {
            // 共有多少项
            return self.dataSource.count
        }, localImage: { index -> UIImage? in
            // 每一项的图片对象
            return self.dataSource[index]
        })
        // 打开浏览器
        JXPhotoBrowser(dataSource: dataSource).show(pageIndex: 0)
    }


    @IBAction func selectImage(_ sender: Any) {
        let pickerController = DKImagePickerController()
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            
            assets.first?.fetchOriginalImage(completeBlock: { (image, info) in
                self.selectImageView.image = OpenCVWrapper.detect(image!);
                self.dataSource.removeAll()
                self.dataSource.append(self.selectImageView.image!)
                self.recognizeText(image: image!)
            })
        }
        
        self.present(pickerController, animated: true) {}
        
    }
    
    func recognizeText(image: UIImage) {
        
        let queue = DispatchQueue.init(label: "com.zly.ocr")
        let option = ["language_type": "CHN_ENG", "detect_direction": "true"]
        queue.async {
            AipOcrService.shard()?.detectTextAccurate(from: image, withOptions: option, successHandler: { (result:Any?) in
                DispatchQueue.main.async {
                    
                    var message : String = ""
                    var resultDic = result as? Dictionary<String, AnyObject?>
                    if ((resultDic?["words_result"]) != nil) {
                        let words_result = resultDic?["words_result"]
                        if words_result is Dictionary<String, AnyObject> {
                            for each in words_result as! Dictionary<String, AnyObject> {
                                if let item = each.value as? Dictionary<String, AnyObject>{
                                    if(item["words"] != nil){
                                        let words = item["words"] as? String
                                        message = message + "\(each.key): \(words ?? ""))" + "\n"
                                    }
                                } else {
                                    message = message + "\(each.key): \(each.value)" + "\n"
                                }
                                
                            }
                        } else if words_result is Array<Any> {
                            
                            for each in words_result as! Array<AnyObject>{
                                if let item = each as? Dictionary<String, AnyObject>{
                                    if(item["words"] != nil){
                                        let words = item["words"] as? String
                                        message = message + "\(words ?? "")" + "\n"
                                    }
                                } else {
                                    message = message + "\(each)" + "\n"
                                }
                            }
                        }
                    } else {
                        message = message + String(describing: result)
                    }
                    self.resultTextView?.text =  message
                }
            }, failHandler: { (error) in
                
            })
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
