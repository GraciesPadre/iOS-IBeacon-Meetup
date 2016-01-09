//
//  BeaconUtilities.swift
//  iOS IBeacon Meetup
//
//  Created by John Dumais on 1/8/16.
//  Copyright © 2016 John Dumais. All rights reserved.
//

import Foundation
import CoreLocation

class BeaconUtilities
{
    static let beaconUuid = NSUUID(UUIDString: "1390B79D-30F1-48D1-8C32-AA5DBA7BC178")
    static let beaconMajorId : CLBeaconMajorValue = 62
    static let beaconMinorId : CLBeaconMinorValue = 93
    
    private static var beaconRegion : CLBeaconRegion?
    
    class func getBeaconRegion() -> CLBeaconRegion
    {
        if beaconRegion == nil
        {
            beaconRegion = CLBeaconRegion(proximityUUID: beaconUuid!, major: beaconMajorId, minor: beaconMinorId, identifier: "")
            beaconRegion?.notifyEntryStateOnDisplay = false
            beaconRegion?.notifyOnEntry = true
            beaconRegion?.notifyOnExit = true
        }
        
        return beaconRegion!
    }
}
