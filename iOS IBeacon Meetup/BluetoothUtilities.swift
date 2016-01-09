//
//  BluetoothUtilities.swift
//  iOS IBeacon Meetup
//
//  Created by John Dumais on 1/8/16.
//  Copyright © 2016 John Dumais. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothUtilities
{
    enum BlueToothAvailabilityQueryResult
    {
        case Success
        case Failure(String)
    }
    
    class func obtainBluetoothState(peripheralManager : CBPeripheralManager) -> (BlueToothAvailabilityQueryResult)
    {
        switch (peripheralManager.state)
        {
        case .PoweredOff:
            return .Failure("You must turn Bluetooth on in order to use the beacon feature.")
            
        case .Resetting:
            return .Failure("Bluetooth is not available at this time, please try again in a moment.")
            
        case .Unauthorized:
            return .Failure("This application is not authorized to use Bluetooth.  Please enable it in the Settings app.")
            
        case .Unknown:
            return .Failure("Bluetooth is not available at this time, please try again in a moment.")
            
        case .Unsupported:
            return .Failure("Your device does not support Bluetooth. You will not be able to use the beacon feature.")
            
        case .PoweredOn:
            return .Success
        }
    }
    
    class func presentBluetoothError(errorMessage: String, onViewController viewController : UIViewController)
    {
        let alert = UIAlertController(title: "Bluetooth Issue",
            message: errorMessage,
            preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
}