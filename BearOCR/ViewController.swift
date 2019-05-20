//
//  ViewController.swift
//  BearOCR
//
//  Created by zly on 2019/5/6.
//  Copyright © 2019 zly. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let wordViewController = WordOCRViewController()
        self.navigationController?.pushViewController(wordViewController, animated: true)
        // Do any additional setup after loading the view.
    }

    @IBAction func wordPushAction(_ sender: Any) {
        let wordViewController = WordOCRViewController()
        self.navigationController?.pushViewController(wordViewController, animated: true)
    }
    
}

