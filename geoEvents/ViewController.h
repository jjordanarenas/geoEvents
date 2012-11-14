//
//  ViewController.h
//  geoEvents
//
//  Created by Jorge Jordán Arenas on 17/08/12.
//  Copyright (c) 2012 Jorge Jordán Arenas. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "CoreLocation/CLGeoCoder.h"

#define METERS_PER_MILE 1609.344

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
    
    MKMapView *mapView;
    MKUserLocation *userLocation;
    NSMutableArray *arrayItems;
    UIView *eventsSelectorView;
    
}

@property(nonatomic, readonly) MKUserLocation *userLocation;
@property(nonatomic, strong) NSMutableArray *arrayItems;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *eventsSelectorView;

- (IBAction) showFilterMenu:(id)sender;
- (IBAction) filterEvents:(id)sender;

@end
