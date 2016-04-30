//
//  MainViewController.swift
//  SuitePort
//
//  Created by Igor E on 4/27/16.
//  Copyright © 2016 IgorEydman. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import SpeechKit

class MainViewController: UIViewController, AVSpeechSynthesizerDelegate, SKTransactionDelegate {
    
    let locatonList = ["moon", "earth", "mars"]
    var myLocation :String?
    
    // Text to speech setup
    let speechSynthesizer = AVSpeechSynthesizer()
    var speechVoice : AVSpeechSynthesisVoice?
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textFound: UILabel!
    
    @IBAction func talkPressed(sender: AnyObject) {
        let utterance = "This is a talking test, do you hear me?"
        sayThis(utterance)
    }
    
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
        
        // Web setup
        let url = NSURL(string: "http://suiteport.mybluemix.net/")
        let request = NSURLRequest(URL: url!)
        
        webView.addSubview(textLabel)
        webView.addSubview(textFound)
        webView.addSubview(recordButton)
        webView.loadRequest(request)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Text to speech set up cont'd
        
        speechSynthesizer.delegate = self
        
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            if "en-AU" == voice.language {
                self.speechVoice = voice
                break;
            }
        }
        sayThis(" ")
        
        
    }
    
    func transaction(transaction: SKTransaction!, didReceiveRecognition recognition: SKRecognition!) {
        //var result = recognition.text
        textLabel.text = recognition.text.lowercaseString
        
        if (textLabel.text!.rangeOfString("weather") != nil) || (textLabel.text!.rangeOfString("whether") != nil){
            
            if myLocation != nil {
                // get weather information for location
                print("weather woohoo!")
                textFound.text = "weather"
            } else {
                let utterance = "We are unable to determine your location, try going to a new location"
                sayThis(utterance)
                textFound.text = "weather not found"
            }
        } else if ((textLabel.text!.rangeOfString("location") != nil) || (textLabel.text!.rangeOfString("where") != nil)) {
            if myLocation != nil {
                let utterance = "you are currently at \(myLocation!)"
                    sayThis(utterance)
                textFound.text = "you are currently at \(myLocation!)"
            } else {
                let utterance = "We are unable to determine your location, try going to a new location"
                sayThis(utterance)
                textFound.text = "location not found"
            }
        } else {
            
            for location in locatonList {
                if (textLabel.text!.rangeOfString("\(location)") != nil) {
                    print("\(location)")
                    textFound.text = location
                    locationCheck(location)
                    //myLocation = location
                    
                    // change location
                    changeLocation(myLocation!)
                    let utterance = "Taking you to \(myLocation)"
                    sayThis(utterance)
                } else {
                    print("I'm not sure what you're looking for. There seems to be a problem connecting to Suite Port. Please try asking take me to mars or what is the weather")
                }
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
    
    // Speech boilerplate
    // Called before speaking an utterance
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didStartSpeechUtterance utterance: AVSpeechUtterance) {
        print("About to say '\(utterance.speechString)'");
    }
    
    // Called when the synthesizer is finished speaking the utterance
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        print("Finished saying '\(utterance.speechString)");
    }
    
    // This method is called before speaking each word in the utterance.
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let startIndex = utterance.speechString.startIndex.advancedBy(characterRange.location)
        let endIndex = startIndex.advancedBy(characterRange.length)
        print("Will speak the word '\(utterance.speechString.substringWithRange(startIndex..<endIndex))'");
    }
    
    func sayThis(utterance: String) {
        let speechUtterance = AVSpeechUtterance(string: utterance)
        speechUtterance.voice = self.speechVoice
        speechUtterance.rate = 0.5
        speechUtterance.volume = 0.75
        speechUtterance.pitchMultiplier = 1.25
        speechUtterance.preUtteranceDelay = 0.0
        speechUtterance.postUtteranceDelay = 0.0
        speechSynthesizer.speakUtterance(speechUtterance)
    }
    
    func changeLocation(myLocation: String) {
        
        // Setup the session to make REST GET call.  Notice the URL is https NOT http!!
        let postEndpoint: String = "https://suiteport.mybluemix.net/alexa/request"
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: postEndpoint)!
        let postParams : [String : AnyObject] = ["location" : "\(myLocation)"]
        
        
        // Create the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            print(postParams)
        } catch {
            print("bad things happened")
        }
        
        // Make the POST call and handle it in a completion handler
        session.dataTaskWithRequest(request, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            if let postString = NSString(data:data!, encoding: NSUTF8StringEncoding) as? String {
                // Print what we got from the call
                print("POST: " + postString)
                self.performSelectorOnMainThread("updatePostLabel:", withObject: postString, waitUntilDone: false)
            }
            
        }).resume()
    }
    
    func locationCheck(location: String) {
        switch location {
        case "earth":
            myLocation = "earth"
            break
        case "mars":
            myLocation = "mars"
            break
        case "moon":
            myLocation = "the moon"
            break
        default :
            // no  location found!
            break
        }
    }
}

