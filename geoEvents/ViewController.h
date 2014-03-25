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
#import "SMCalloutView.h"

#define METERS_PER_MILE 1609.344

@interface MapAnnotation : NSObject <MKAnnotation>
@property (nonatomic, copy) NSString *title, *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

@interface CustomMapView : MKMapView
@property (strong, nonatomic) SMCalloutView *calloutView;
@end

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate> {
    
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
    UIWebView *webView;
    UIToolbar *toolBar;
    //UINavigationBar *toolBar;
    UIToolbar *webToolBar;

//    UINavigationController *navController;
    UIActivityIndicatorView *activityIndicator;
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
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *marsView;
@property (nonatomic, strong) SMCalloutView *calloutView;
@property (nonatomic, strong) CustomMapView *bottomMapView;

//@property (nonatomic, strong) UINavigationController *navController;

@property (nonatomic, strong) MKPinAnnotationView *selectedPin;

- (IBAction) showFilterMenu:(id)sender;
- (IBAction) showCalendarFilterMenu:(id)sender;
- (IBAction) filterEvents:(id)sender;
- (IBAction)deselectAnnotation:(id)sender;
- (IBAction)dismissCustomView:(id)sender;
//- (void)dismissCustomView;

@end
