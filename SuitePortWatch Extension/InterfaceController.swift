//
//  InterfaceController.swift
//  SuitePortWatch Extension
//
//  Created by Igor E on 5/4/16.
//  Copyright © 2016 IgorEydman. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    // WatchKit setup
    let watchSession = WCSession.defaultSession()
    
    @IBOutlet var recordButton: WKInterfaceButton!
    
    @IBAction func recordTapped() {
        self.presentTextInputControllerWithSuggestions(["Take me to Mars", "Take me to Earth", "Take me to the Moon", "Where am I?", "What is the weather?"], allowedInputMode: WKTextInputMode.Plain) { (output) -> Void in
            var result = output
        }

    }
    
    // Initiate Apple Watch session
    func initWCSession() {
        watchSession.delegate = self
        watchSession.activateSession()
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Initiate session
        initWCSession()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
