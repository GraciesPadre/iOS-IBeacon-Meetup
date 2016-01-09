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
    static private var locationManager : CLLocationManager?
    
    class func getLocationManager(withDelegate delegate : CLLocationManagerDelegate) -> CLLocationManager
    {
        if locationManager == nil
        {
            locationManager = CLLocationManager()
            
            if locationManager?.respondsToSelector("requestAlwaysAuthorization") == true
            {
                locationManager?.requestAlwaysAuthorization()
            }
        }
        
        locationManager?.delegate = delegate
        
        return locationManager!
    }

}