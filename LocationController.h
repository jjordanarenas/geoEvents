//
//  LocationController.h
//  GeoEvents
//
//  Created by Jorge Jordán Arenas on 30/09/11.
//  Copyright 2011 Insane Platypus Games. All rights reserved.

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface  LocationController : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

+ (LocationController *)sharedInstance;

-(void) start;
-(void) stop;
-(BOOL) locationKnown;

@property (nonatomic, retain) CLLocation *currentLocation;

@end
