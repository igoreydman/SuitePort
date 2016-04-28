//
//  MainViewController.swift
//  SuitePort
//
//  Created by Igor E on 4/27/16.
//  Copyright © 2016 IgorEydman. All rights reserved.
//

import UIKit
import Foundation
import SpeechKit

class MainViewController: UIViewController, SKTransactionDelegate {
    
    let locatonList = ["moon", "earth", "mars"]
    var myLocation :String?
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textFound: UILabel!
    
    @IBAction func recordTapped(sender: AnyObject) {
        recordButton.setTitle("Listening", forState: .Normal)
        let session = SKSession(URL: NSURL(string: "nmsps://NMDPTRIAL_igoratsuiteport_gmail_com20160428150234@sslsandbox.nmdp.nuancemobility.net:443"), appToken: "85f54358cbcdbfd0c4e508eb7f11d9accc11e7a1ddfedeb4fa02a6673eb1cbc3a60e1b71dbda419fc0498b3f5b64eb2776d3c853d1a707cba9ad32e75efeaa04")
        session.recognizeWithType(SKTransactionSpeechTypeDictation,
                                  detection: .Short,
                                  language: "eng-USA",
                                  delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let url = NSURL(string: "http://suiteport.mybluemix.net/")
        let request = NSURLRequest(URL: url!)
        
        webView.loadRequest(request)
        
    }

    func transaction(transaction: SKTransaction!, didReceiveRecognition recognition: SKRecognition!) {
        //var result = recognition.text
        textLabel.text = recognition.text.lowercaseString
        
        for location in locatonList {
            if (textLabel.text!.rangeOfString("\(location)") != nil) {
                print("\(location)")
                textFound.text = location
            } else {
                print("I'm not sure what you're looking for. There seems to be a problem connecting to Suite Port. Please try asking take me to mars or what is the weather")
            }
        }
        
        ////TODO - Change Icon to flashing
        recordButton.setTitle("Listen", forState: .Normal)
        //print(result)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

