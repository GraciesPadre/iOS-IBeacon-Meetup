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
    
    private var bluetoothAvailable = false
    private var locationServicesAuthorizationStatus : CLAuthorizationStatus = .NotDetermined
    
    private var peripheralManager: CBPeripheralManager?
    private var locationManager : CLLocationManager?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        locationManager = LocationUtilities.getLocationManager(withDelegate: self)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        maybeEnableLookForBeaconsButton()
    }
    
    private func maybeEnableLookForBeaconsButton()
    {
        if bluetoothAvailable && locationServicesAuthorizationStatus == .AuthorizedAlways
        {
            lookForBeaconsButton.enabled = true
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        stopRangingAndMonitoring()
    }
    
    private func stopRangingAndMonitoring()
    {
        peripheralManager = nil
        
        locationManager!.stopRangingBeaconsInRegion(BeaconUtilities.getBeaconRegion())
        locationManager!.stopMonitoringForRegion(BeaconUtilities.getBeaconRegion())
        locationManager = nil
    }
    
    @IBAction func lookForBeaconButtonTapped(sender: AnyObject)
    {
        lookForBeaconsButton.enabled = false
        locationManager!.startMonitoringForRegion(BeaconUtilities.getBeaconRegion())
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
            bluetoothAvailable = true
            maybeEnableLookForBeaconsButton()
            
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
        
        locationManager!.startRangingBeaconsInRegion(region as! CLBeaconRegion)
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
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        locationServicesAuthorizationStatus = status
        
        if status != .AuthorizedAlways
        {
            beaconStatusLabel.text = "Location services not available"
        }
        else
        {
            beaconStatusLabel.text = "Location services available"
        }
        
        maybeEnableLookForBeaconsButton()
    }
}
