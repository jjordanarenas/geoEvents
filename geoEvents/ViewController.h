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

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate> {
    
    MKMapView *mapView;
    MKUserLocation *userLocation;
    NSMutableArray *arrayItems;
    UIView *eventsSelectorView;
    float _currentZoom;
    int _countBirthdays;
    int _countDeaths;
    int _countHistoricEvents;
    UIView *buttonFilterView;
    UIView *buttonCalendarView;
    UIDatePicker *datePicker;
    UIPickerView *monthPicker;
}

@property(nonatomic, readonly) MKUserLocation *userLocation;
@property(nonatomic, strong) NSMutableArray *arrayItems;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *eventsSelectorView;
@property (strong, nonatomic) IBOutlet UIView *buttonFilterView;
@property (strong, nonatomic) IBOutlet UIView *buttonCalendarView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIPickerView *monthPicker;

- (IBAction) showFilterMenu:(id)sender;
- (IBAction) showCalendarFilterMenu:(id)sender;
- (IBAction) filterEvents:(id)sender;

@end
