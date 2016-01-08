//
//  BeaconFinderViewController.swift
//  iOS IBeacon Meetup
//
//  Created by John Dumais on 1/6/16.
//  Copyright © 2016 John Dumais. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class BeaconFinderViewController : UIViewController
{
    enum BlueToothAvailabilityQueryResult
    {
        case Success
        case Failure(String)
    }
    
    @IBOutlet weak var doneLookingButton: UIButton!
    @IBOutlet weak var lookForBeaconsButton: UIButton!
    @IBOutlet weak var beaconStatusLabel: UILabel!
    
    private var peripheralManager: CBPeripheralManager?
    private var locationManager : CLLocationManager?
    private var beaconRegion : CLBeaconRegion?
    
    static let beaconUuid = NSUUID(UUIDString: "1390B79D-30F1-48D1-8C32-AA5DBA7BC178")
    static let beaconMajorId : CLBeaconMajorValue = 62
    static let beaconMinorId : CLBeaconMinorValue = 93
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        stopRangingAndMonitoring()
    }
    
    private func stopRangingAndMonitoring()
    {
        peripheralManager = nil
        getLocationManager().stopRangingBeaconsInRegion(getBeaconRegion())
        getLocationManager().stopMonitoringForRegion(getBeaconRegion())
    }
    
    @IBAction func lookForBeaconButtonTapped(sender: AnyObject)
    {
        lookForBeaconsButton.enabled = false
        getLocationManager().startMonitoringForRegion(getBeaconRegion())
    }
    
    private func getLocationManager() -> CLLocationManager
    {
        if locationManager == nil
        {
            locationManager = CLLocationManager()
            
            locationManager?.delegate = self
            
            if locationManager?.respondsToSelector("requestAlwaysAuthorization") == true
            {
                locationManager?.requestAlwaysAuthorization()
            }
        }
        
        return locationManager!
    }
    
    private func getBeaconRegion() -> CLBeaconRegion
    {
        if beaconRegion == nil
        {
            beaconRegion = CLBeaconRegion(proximityUUID: BeaconFinderViewController.beaconUuid!, major: BeaconFinderViewController.beaconMajorId, minor: BeaconFinderViewController.beaconMinorId, identifier: "")
            beaconRegion?.notifyEntryStateOnDisplay = false
            beaconRegion?.notifyOnEntry = true
            beaconRegion?.notifyOnExit = true
        }
        
        return beaconRegion!
    }
    
    @IBAction func doneLookingButtonTapped(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension BeaconFinderViewController: CBPeripheralManagerDelegate
{
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager)
    {
        switch obtainBluetoothState()
        {
        case .Success:
            lookForBeaconsButton.enabled = true
            
        case .Failure(let failureMessage):
            presentBluetoothError(failureMessage)
        }
    }
    
    private func obtainBluetoothState() -> (BlueToothAvailabilityQueryResult)
    {
        switch (peripheralManager!.state)
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
    
    private func presentBluetoothError(errorMessage: String)
    {
        let alert = UIAlertController(title: "Bluetooth Issue",
            message: errorMessage,
            preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
}

extension BeaconFinderViewController : CLLocationManagerDelegate
{
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion)
    {
        print("Started monitoring for beacon region: \(region)")
        
        getLocationManager().startRangingBeaconsInRegion(getBeaconRegion())
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion)
    {
        if beacons.count > 0
        {
            let beacon = beacons.last
            
            switch beacon!.proximity
            {
            case CLProximity.Immediate:
                beaconStatusLabel.text = String(format: "Immediate, %ld", beacon!.rssi)
                beaconStatusLabel.backgroundColor = UIColor.greenColor()
                
            case CLProximity.Near:
                beaconStatusLabel.text = String(format: "Near, %ld", beacon!.rssi)
                beaconStatusLabel.backgroundColor = UIColor.yellowColor()
                
            case CLProximity.Far:
                beaconStatusLabel.text = String(format: "Far, %ld", beacon!.rssi)
                beaconStatusLabel.backgroundColor = UIColor.redColor()
                
            default:
                beaconStatusLabel.text = "Cannot determine proximity"
                beaconStatusLabel.backgroundColor = UIColor.groupTableViewBackgroundColor()
            }
        }
        else
        {
            beaconStatusLabel.text = "Not ranging"
            beaconStatusLabel.backgroundColor = UIColor.groupTableViewBackgroundColor()
        }
    }
}
