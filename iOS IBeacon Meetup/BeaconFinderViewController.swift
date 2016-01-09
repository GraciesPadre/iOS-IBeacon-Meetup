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
    @IBOutlet weak var doneLookingButton: UIButton!
    @IBOutlet weak var lookForBeaconsButton: UIButton!
    @IBOutlet weak var beaconStatusLabel: UILabel!
    
    private var peripheralManager: CBPeripheralManager?
    
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
        LocationUtilities.getLocationManager(withDelegate: self).stopRangingBeaconsInRegion(BeaconUtilities.getBeaconRegion())
        LocationUtilities.getLocationManager(withDelegate: self).stopMonitoringForRegion(BeaconUtilities.getBeaconRegion())
    }
    
    @IBAction func lookForBeaconButtonTapped(sender: AnyObject)
    {
        lookForBeaconsButton.enabled = false
        LocationUtilities.getLocationManager(withDelegate: self).startMonitoringForRegion(BeaconUtilities.getBeaconRegion())
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
        switch BluetoothUtilities.obtainBluetoothState(peripheral)
        {
        case .Success:
            lookForBeaconsButton.enabled = true
            
        case .Failure(let failureMessage):
            BluetoothUtilities.presentBluetoothError(failureMessage, onViewController: self)
        }
    }
}

extension BeaconFinderViewController : CLLocationManagerDelegate
{
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion)
    {
        print("Started monitoring for beacon region: \(region)")
        
        LocationUtilities.getLocationManager(withDelegate: self).startRangingBeaconsInRegion(region as! CLBeaconRegion)
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
