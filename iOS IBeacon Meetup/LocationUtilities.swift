//
//  LocationUtilities.swift
//  iOS IBeacon Meetup
//
//  Created by John Dumais on 1/8/16.
//  Copyright © 2016 John Dumais. All rights reserved.
//

import Foundation
import CoreLocation

class LocationUtilities
{
    class func getLocationManager(withDelegate delegate : CLLocationManagerDelegate) -> CLLocationManager
    {
        let locationManager = CLLocationManager()
            
        locationManager.delegate = delegate
        
        if locationManager.respondsToSelector("requestAlwaysAuthorization") == true
        {
            locationManager.requestAlwaysAuthorization()
        }
        
        return locationManager
    }
}