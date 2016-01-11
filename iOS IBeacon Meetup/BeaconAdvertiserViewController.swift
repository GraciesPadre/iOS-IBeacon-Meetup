//
//  BeaconAdvertiserViewController.swift
//  iOS IBeacon Meetup
//
//  Created by John Dumais on 1/8/16.
//  Copyright © 2016 John Dumais. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class BeaconAdvertiserViewController : UIViewController
{
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var majorIdLabel: UILabel!
    @IBOutlet weak var minorIdLabel: UILabel!
    @IBOutlet weak var advertiseSwitch: UISwitch!
    
    private var bluetoothAvailable = false
    private var locationServicesAuthorizationStatus : CLAuthorizationStatus = .NotDetermined
    
    private var peripheralManager: CBPeripheralManager?
    private var locationManager : CLLocationManager?
    
    override func viewDidLoad()
    {
        uuidLabel.text = "UUID: " + BeaconUtilities.beaconUuid!.UUIDString
        majorIdLabel.text = String(format: "Major ID: %d", BeaconUtilities.beaconMajorId)
        minorIdLabel.text = String(format: "Minor ID: %d", BeaconUtilities.beaconMinorId)
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        locationManager = LocationUtilities.getLocationManager(withDelegate: self)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        maybeEnableAdvertiseButton()
    }
    
    private func maybeEnableAdvertiseButton()
    {
        if bluetoothAvailable && locationServicesAuthorizationStatus == .AuthorizedAlways
        {
            advertiseSwitch.enabled = true
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        stopAdvertising()
        peripheralManager = nil
        locationManager = nil
    }
    
    @IBAction func advertiseSwitchChangedState(sender: AnyObject)
    {
        if advertiseSwitch.on
        {
            startAdvertising()
            
            return
        }
        
        stopAdvertising()
        statusLabel.text = "Not advertising"
        statusLabel.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    private func startAdvertising()
    {
        stopAdvertising()
        
        let peripheralData = NSDictionary(dictionary: BeaconUtilities.getBeaconRegion().peripheralDataWithMeasuredPower(nil))
        peripheralManager!.startAdvertising(peripheralData as? [String : AnyObject])
    }
    
    private func stopAdvertising()
    {
        peripheralManager!.stopAdvertising()
    }
    
    @IBAction func iDontWannaBeABeaconButtonTapped(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension BeaconAdvertiserViewController : CLLocationManagerDelegate
{
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        locationServicesAuthorizationStatus = status
        
        if status != .AuthorizedAlways
        {
            statusLabel.text = "Location services not available"
        }
        else
        {
            statusLabel.text = "Location services available"
        }
        
        maybeEnableAdvertiseButton()
    }
}

extension BeaconAdvertiserViewController : CBPeripheralManagerDelegate
{
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager)
    {
        switch BluetoothUtilities.obtainBluetoothState(peripheral)
        {
        case .Success:
            bluetoothAvailable = true
            maybeEnableAdvertiseButton()
            
        case .Failure(let failureMessage):
            BluetoothUtilities.presentBluetoothError(failureMessage, onViewController: self)
        }
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?)
    {
        if error == nil
        {
            statusLabel.text = "Advertising"
            statusLabel.backgroundColor = UIColor.greenColor()
        }
        else
        {
            statusLabel.text = error?.localizedDescription
            statusLabel.backgroundColor = UIColor.redColor()
        }
    }
}


