//
//  ViewController.m
//  geoEvents
//
//  Created by Jorge Jordán Arenas on 17/08/12.
//  Copyright (c) 2012 Jorge Jordán Arenas. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "GeoEvent.h"
#import "MyLocation.h"
#import "MyAnnotationButton.h"
#import "GADBannerView.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIButton *eventsButton;
@property (nonatomic, weak) IBOutlet UIButton *birthdayButton;
@property (nonatomic, weak) IBOutlet UIButton *deathButton;
@property (nonatomic, weak) IBOutlet UIButton *filterButton;
@property (nonatomic, weak) IBOutlet UIButton *calendarButton;
@property (nonatomic, weak) IBOutlet UIView *viewFilterButton;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *tapCloseFilters;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panCloseFiltersRecognizer;

@end

@implementation ViewController

@synthesize eventsButton = _eventsButton;
@synthesize birthdayButton = _birthdayButton;
@synthesize deathButton = _deathButton;
@synthesize filterButton = _filterButton;
@synthesize calendarButton = _calendarButton;
@synthesize mapView;
@synthesize eventsSelectorView;
@synthesize userLocation;
@synthesize arrayItems;
@synthesize locationManager;
@synthesize buttonFilterView;
@synthesize buttonCalendarView;
@synthesize datePicker;
@synthesize monthPicker;

@synthesize scrollView;
@synthesize marsView;
@synthesize calloutView;
@synthesize bottomMapView;
@synthesize tap;
@synthesize tapCloseFilters;
@synthesize panRecognizer;
@synthesize panCloseFiltersRecognizer;

@synthesize selectedPin;


AppDelegate *appDelegate;

// Lite
////////GADBannerView *bannerView_;

static NSString *const TYPE_BIRTHDAY = @"BIRTHDAY";
static NSString *const TYPE_DEATH = @"DEATH";
static NSString *const TYPE_EVENT = @"EVENT";
static NSString *const TYPE_BIRTHDAY_ES = @"NACIMIENTO";
static NSString *const TYPE_DEATH_ES = @"FALLECIMIENTO";
static NSString *const TYPE_EVENT_ES = @"EVENTO HISTÓRICO";

static NSString *const LOCALE_ENGLISH = @"en";
static NSString *const LOCALE_SPANISH = @"es";

static NSString *const ENGLISH_BIRTHDAY_TEXT = @"Birth";
static NSString *const ENGLISH_DEATH_TEXT = @"Death";
static NSString *const ENGLISH_EVENT_TEXT = @"Historical event";

static NSString *const ENGLISH_BIRTHDAY_BUTTON = @"Births";
static NSString *const ENGLISH_DEATH_BUTTON = @"Deaths";
static NSString *const ENGLISH_EVENT_BUTTON = @"Historical events";

static NSString *const SPANISH_BIRTHDAY_TEXT = @"Nacimiento";
static NSString *const SPANISH_DEATH_TEXT = @"Fallecimiento";
static NSString *const SPANISH_EVENT_TEXT = @"Evento histórico";

static float WIKIPEDIA_BUTTON_SIZE = 30;

UIColor *greenColor;
UIColor *redColor;
UIColor *violetColor;
UIColor *blackColor;
UIColor *orangeColor;

BOOL cityLocated = FALSE;
BOOL connectionAlerted = FALSE;
BOOL buttonMenuSelected = FALSE;
BOOL buttonCalendarMenuSelected = FALSE;
BOOL buttonCloseWebView = FALSE;
BOOL shouldShowDeaths = TRUE;
BOOL shouldShowBirthdays = TRUE;
BOOL shouldShowEvents = TRUE;
BOOL calendarMustRefresh = TRUE;
BOOL isPanning = FALSE;
BOOL showingFilters = FALSE;

CLGeocoder *geocoder;

NSUserDefaults *settings;

NSDate *currentDate;
NSDateFormatter *dateFormatter;

NSArray *arrayDate;

NSMutableArray *arrayMonths;
NSMutableArray *arrayDays;
NSMutableArray *arrayDaysFebruary;
NSMutableArray *arrayDays30;
NSMutableArray *arrayDays31;

NSString *userCity;
NSString *userLocale;
NSString *urlSelected;
NSString *monthSelected;
NSString *daySelected;
NSString *dateSelected;
NSString *urlBackup = @"";

UIImage *imgBirthDayOn;
UIImage *imgBirthDayOff;
UIImage *imgDeathOn;
UIImage *imgDeathOff;
UIImage *imgEventOn;
UIImage *imgEventOff;
UIImage *imgWikipedia;
UIImage *imgShare;
UIImage *imgFilter;
UIImage *imgClose;

UIView *customView;
UITextView *textView;
UILabel *labelTypeEvent;

UINavigationController* navigationController;

UIBarButtonItem *toolbarButton;
UIBarButtonItem *webToolbarButton;
UIBarButtonItem *eventTypeButton;

int dayInteger = 0;
int monthInteger = 0;

double METERSPERMILE_ZOOMIN = 5000;
double METERSPERMILE_ZOOMOUT = 3700000;

-(void) locateUser{
	CLLocationCoordinate2D zoomLocation;
	zoomLocation.latitude = userLocation.coordinate.latitude;
	zoomLocation.longitude = userLocation.coordinate.longitude;
	
	MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, METERSPERMILE_ZOOMIN*METERS_PER_MILE, METERSPERMILE_ZOOMIN*METERS_PER_MILE);
	
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    _currentZoom = -1;
    _countBirthdays = 0;
    _countDeaths = 0;
    _countHistoricEvents = 0;
    [self.mapView setRegion:adjustedRegion animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (calendarMustRefresh){
        daySelected = arrayDate[0];
        dayInteger = [daySelected intValue] - 1;
        monthSelected = arrayDate[1];
        monthInteger = [monthSelected intValue] - 1;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [arrayItems removeAllObjects];
    
    if(cityLocated==FALSE){
            
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [self.locationManager startUpdatingLocation];
            
    }
    
    if (calendarMustRefresh){
        [monthPicker selectRow:dayInteger inComponent:0 animated:TRUE];
        [monthPicker selectRow:monthInteger inComponent:1 animated:TRUE];
        calendarMustRefresh = FALSE;
    }
    
    // Create custom colors
    
    greenColor = [UIColor colorWithRed:76.0/255.0 green: 217.0/255.0 blue: 100.0/255.0 alpha: 1.0];
    redColor = [UIColor colorWithRed:252.0/255.0 green: 53.0/255.0 blue: 54.0/255.0 alpha: 1.0];
    violetColor = [UIColor colorWithRed:201.0/255.0 green: 105.0/255.0 blue: 224.0/255.0 alpha: 1.0];
    blackColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    orangeColor = [UIColor colorWithRed:255.0f/255.0f green:134.0f/255.0f blue:31.0f/255.0f alpha:1.0f];
    
    [self.birthdayButton setTitleColor:greenColor forState:UIControlStateNormal];
    [self.deathButton setTitleColor:redColor forState:UIControlStateNormal];
    [self.eventsButton setTitleColor:violetColor forState:UIControlStateNormal];
    
    [monthPicker reloadInputViews];
    [monthPicker reloadAllComponents];
    
    //webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width + 44, self.view.frame.size.height, self.view.frame.size.width)];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width + 44, self.view.frame.size.height, self.view.frame.size.width)];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];

  //  [self.navigationController pushViewController:self animated:YES];

   // toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width, self.view.frame.size.height, 44)];
    
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, 44)];
    /////toolBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, 44)];
    
     webToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width, self.view.frame.size.height, 44)];
    
  //  [self.navigationController pushViewController:self animated:TRUE];
    
    

    
    [toolBar setTintColor:blackColor];
    [webToolBar setTintColor:blackColor];
    
    labelTypeEvent = [[UILabel alloc] init];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake((self.view.frame.size.height / 2) - 22, (self.view.frame.size.width / 2) - 22, 44, 44);
    
    
    toolbarButton = [[UIBarButtonItem alloc] initWithImage:imgFilter style:UIBarButtonItemStyleDone target:self action:@selector(closeWebView)];
    
    /*toolBar = [[UINavigationBar alloc] init];
    [toolBar setBarStyle:UIBarStyleDefault];*/
    //[toolBar setb

    /////////eventTypeButton = [[UIBarButtonItem alloc] initWithTitle:@"blablablabla" style:UIBarButtonItemStyleDone target:self action:@selector(closeWebView)];
    
    
    
    
    //toolbarButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonSystemItemDone target:self action:@selector(closeWebView)];

    webToolbarButton = [[UIBarButtonItem alloc] initWithImage:imgClose style:UIBarButtonItemStyleDone target:self action:@selector(closeWebView)];
    
    //webToolbarButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonSystemItemDone target:self action:@selector(closeWebView)];

    
    //////[toolBar setItems:[NSArray arrayWithObjects:toolbarButton, eventTypeButton, nil]];
    [toolBar setItems:[NSArray arrayWithObjects:toolbarButton, nil]];
    [webToolBar setItems:[NSArray arrayWithObjects:webToolbarButton, nil]];
    
    
    ////////////////////////
    labelTypeEvent.text = @"";
    
    CGFloat textWidth =  [labelTypeEvent.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}].width;

    [labelTypeEvent setTextColor:violetColor];
    
    labelTypeEvent.frame = CGRectMake(0, 0, textWidth, 44);
    
    [labelTypeEvent setCenter:toolBar.center];
    
    [toolBar addSubview:labelTypeEvent];
    ////////////////////////
    
    
    [webView setDelegate:self];
    
    [webView setUserInteractionEnabled:YES];
    [webView addSubview:activityIndicator];
    [self.view addSubview:webView];
    [webView setHidden:YES];
    [self.view addSubview:toolBar];
    [self.view addSubview:webToolBar];
    
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(dismissCustomView:)];
    
    
    tap.numberOfTapsRequired = 1;
    self.view.multipleTouchEnabled = YES;
    tap.delaysTouchesBegan = YES;
    [tap setDelegate:self];
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCustomView:)];
    panCloseFiltersRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(closeWebView)];
    
    tap.delaysTouchesBegan = YES;
    [panRecognizer setDelegate:self];
    [panCloseFiltersRecognizer setDelegate:self];
    
    [tap requireGestureRecognizerToFail:panRecognizer];
    [tapCloseFilters requireGestureRecognizerToFail:panCloseFiltersRecognizer];
    
    [self.mapView addGestureRecognizer:tap];
    
    [self.mapView addGestureRecognizer:panRecognizer];
    
    tapCloseFilters = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(closeWebView)];
    
    
    tapCloseFilters.numberOfTapsRequired = 1;
    [tapCloseFilters setDelegate:self];

    // Set banner position
    // Lite
    ////////CGRect bannerFrame = bannerView_.frame;
    ////////bannerFrame.origin.y = self.mapView.frame.origin.x + toolBar.frame.size.height;//toolBar.frame.size.height;
    ////////bannerView_.frame = bannerFrame;

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void) closeWebView
{

    if (![webView isHidden]) { // Close webView

        CGRect webViewFrame = webView.frame;
        CGRect webToolBarFrame = webToolBar.frame;
    
        webViewFrame.origin.y = webViewFrame.size.height + 44;
        webToolBarFrame.origin.y = webViewFrame.size.height;
    
        //[UIView animateWithDuration:0.5
        [UIView animateWithDuration:0.3
        //[UIView animateWithDuration:0.9
                              delay:0.0
       //      usingSpringWithDamping: 0.55
        //      initialSpringVelocity: 0.0

      
                             options: UIViewAnimationCurveEaseOut
                     animations:^{
                         webView.frame = webViewFrame;
                         webToolBar.frame = webToolBarFrame;
                        
                     }
                     completion:^(BOOL finished){
                          [webView setHidden:YES];
                          //[toolbarButton setTitle:@"Filter"];
                         
                     }];
        [UIView commitAnimations];
       
        // Lite
        ////////[bannerView_ loadRequest:[GADRequest request]];
    } else {
        CGRect mapViewFrame = mapView.frame;
        CGRect toolBarFrame = toolBar.frame;
        
        if (!showingFilters) {
            
            // Show filters
            mapViewFrame.origin.x = monthPicker.frame.size.width + datePicker.frame.size.width;
            toolBarFrame.origin.x = monthPicker.frame.size.width + datePicker.frame.size.width;
            
            //[UIView animateWithDuration:0.5
            [UIView animateWithDuration:0.9
                                  delay:0.0
                  usingSpringWithDamping: 0.55
                  initialSpringVelocity: 0.0
             
                                options: UIViewAnimationCurveEaseOut
                             animations:^{
                                 mapView.frame = mapViewFrame;
                                 toolBar.frame = toolBarFrame;
                                 
                             }
                             completion:^(BOOL finished){
                             }];
            [UIView commitAnimations];
            showingFilters = YES;
            
            [customView setHidden:YES];
            
            [mapView setUserInteractionEnabled:NO];
            labelTypeEvent.text = @"";

            /*[mapView removeGestureRecognizer:tap];
            [mapView removeGestureRecognizer:panRecognizer];
            [mapView addGestureRecognizer:tapCloseFilters];
            [mapView addGestureRecognizer:panCloseFiltersRecognizer];*/
        } else {
            // Hide filters
            mapViewFrame.origin.x = 0;
            toolBarFrame.origin.x = 0;
            //[UIView animateWithDuration:0.5
            [UIView animateWithDuration:0.9
                                  delay:0.0
                 usingSpringWithDamping: 0.55
                  initialSpringVelocity: 0.0

                                options: UIViewAnimationCurveEaseOut
                             animations:^{
                                 mapView.frame = mapViewFrame;
                                 toolBar.frame = toolBarFrame;
                             }
                             completion:^(BOOL finished){
                             }];
            [UIView commitAnimations];
            showingFilters = NO;
            [self showCalendarFilterMenu:0];
            
           [mapView setUserInteractionEnabled:YES];

            
            // Lite
            ////////[bannerView_ loadRequest:[GADRequest request]];
        }
    }
}

-(void) showWebView
{
    CGRect webViewFrame = webView.frame;
    CGRect toolBarFrame = toolBar.frame;
    CGRect webToolBarFrame = webToolBar.frame;

    
    webViewFrame.origin.y = toolBarFrame.size.height;
    toolBarFrame.origin.y = 0;
    webToolBarFrame.origin.y = 0;
    
    //[UIView animateWithDuration:0.5
    [UIView animateWithDuration:0.3
   // [UIView animateWithDuration:0.9
                          delay:0.0
        // usingSpringWithDamping: 0.55
       //   initialSpringVelocity: 0.0
     
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         webView.frame = webViewFrame;
                         toolBar.frame = toolBarFrame;
                         webToolBar.frame = webToolBarFrame;
                         
                         //UIBarButtonItem *toolbarButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonSystemItemDone target:self action:@selector(closeWebView)];

                         

                     }
                     completion:^(BOOL finished){
                        // [toolbarButton setTitle:@"Close"];
                     }];
    [UIView commitAnimations];

        [webView setHidden:NO];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)currentLocation{
	
    if(cityLocated==FALSE){
        userLocation = currentLocation;
        //NSLog(@"*** Current User Location: %@ ", userLocation.location);
        
        //NSLog(@"*** HORIZONTAL ACCURACY: %f ", userLocation.location.horizontalAccuracy);
        
        if(self.mapView.annotations.count <= 1){
            CLLocationCoordinate2D zoomLocation;
            
            zoomLocation.latitude = userLocation.coordinate.latitude;
            zoomLocation.longitude = userLocation.coordinate.longitude;
            
            [self locateUser];
        }
	}
    
}

-(void) getGeoEvents {
    
    currentDate = [self.datePicker date];

    if([daySelected length] == 1){
        daySelected = [[NSString alloc] initWithFormat:@"%@%@", @"0", daySelected];
    }
    NSString* dateSelected = [[NSString alloc] initWithFormat:@"%@/%@", daySelected, monthSelected];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [arrayItems removeAllObjects];
    
    if (![userLocale isEqualToString:LOCALE_SPANISH]){
        userLocale = LOCALE_ENGLISH;
        
        [self.birthdayButton setTitle:ENGLISH_BIRTHDAY_BUTTON forState:UIControlStateNormal];
        [self.deathButton setTitle:ENGLISH_DEATH_BUTTON forState:UIControlStateNormal];
        [self.eventsButton setTitle:ENGLISH_EVENT_BUTTON forState:UIControlStateNormal];
    }
          
    arrayItems = [appDelegate readGeoEventsFromDatabaseFromDate:dateSelected language:userLocale];

    [self plotGeoEventPositionsFromArray];
    
}

- (void)plotGeoEventPositionsFromArray{
    
     NSLog(@"arrayItems.count %d", arrayItems.count);
    
    GeoEvent *geoEvent;
    NSString *address;
    NSString *itemType;
    NSString *image;
    CLLocationCoordinate2D coordinate;
    
    static NSString *const TYPE_BIRTHDAY = @"BIRTHDAY";
    static NSString *const TYPE_DEATH = @"DEATH";
    static NSString *const TYPE_EVENT = @"EVENT";
    
	for(int i = 0; i < arrayItems.count; i++){
        
        geoEvent = (GeoEvent *)[arrayItems objectAtIndex:i];
    
        address = [geoEvent description];
        itemType = [geoEvent type];

        coordinate.latitude = [[geoEvent latitude] doubleValue];
        coordinate.longitude = [[geoEvent longitude] doubleValue];
        
        if([itemType isEqualToString:TYPE_BIRTHDAY]){
            itemType = TYPE_BIRTHDAY_ES;
        }
        
        if([itemType isEqualToString:TYPE_DEATH]){
            itemType = TYPE_DEATH_ES;
        }
        
        if([itemType isEqualToString:TYPE_EVENT]){
            itemType = TYPE_EVENT_ES;
        }
   
        if (([itemType isEqualToString:TYPE_EVENT_ES] && shouldShowEvents) || ([itemType isEqualToString:TYPE_BIRTHDAY_ES] && shouldShowBirthdays) || ([itemType isEqualToString:TYPE_DEATH_ES] && shouldShowDeaths)) {
        MyLocation *annotation = [[MyLocation alloc] initWithName:itemType address:address itemType:itemType image:image coordinate:coordinate geoEvent:geoEvent];
        
		[self.mapView addAnnotation:annotation];
            }
	}
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [arrayItems removeAllObjects];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [activityIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) removeAnnotations {
    [self deleteAllEventType];
    [mapView removeAnnotations:[mapView annotations]];
}

- (void) mapView:(MKMapView *)argMapView regionDidChangeAnimated:(BOOL)animated {
    [self mapViewDidZoom:argMapView];

}

- (BOOL) mapViewDidZoom:(MKMapView*)argMapView  {
    if (_currentZoom == argMapView.visibleMapRect.size.width * argMapView.visibleMapRect.size.height) {
        return NO;
    }
    
    _currentZoom = mapView.visibleMapRect.size.width * mapView.visibleMapRect.size.height;
    return YES;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation {
	static NSString *identifier = @"MyLocation";
        MKPinAnnotationView *pin;
        MyAnnotationButton *myDetailButton;
        MyAnnotationButton *myShareButton;
    
        // Make sure we only create Pins for the Cameras. Ignore the current location annotation
        // so it returns the 'blue dot'
        if ([annotation isMemberOfClass:[MyLocation class]]) {
            // See if we can reduce, reuse, recycle
            pin = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            
            // If we have to, create a new view
            if (pin == nil) {
                pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            }else{
                pin.annotation = annotation;
            }
            
            if (pin) {
                
                pin.animatesDrop = NO;
                pin.canShowCallout = NO;
                
                if([[annotation itemType] isEqualToString:TYPE_BIRTHDAY] || [[annotation itemType] isEqualToString:TYPE_BIRTHDAY_ES]){
                    [pin setPinColor:MKPinAnnotationColorGreen];
                    _countBirthdays++;
                }
                if([[annotation itemType] isEqualToString:TYPE_DEATH] || [[annotation itemType] isEqualToString:TYPE_DEATH_ES]){
                    [pin setPinColor:MKPinAnnotationColorRed];
                    _countDeaths++;
                }
                if([[annotation itemType] isEqualToString:TYPE_EVENT] || [[annotation itemType] isEqualToString:TYPE_EVENT_ES]){
                    [pin setPinColor:MKPinAnnotationColorPurple];
                    _countHistoricEvents++;
                }
                
                urlSelected = [[annotation geoEvent] url];
                
                
                // Set up the Wikipedia button
                myDetailButton = [MyAnnotationButton buttonWithType:UIButtonTypeCustom];
                [myDetailButton setImage:imgWikipedia forState:UIControlStateNormal];
                myDetailButton.frame = CGRectMake(5, 5, WIKIPEDIA_BUTTON_SIZE, WIKIPEDIA_BUTTON_SIZE);
                myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                
                myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                
                myDetailButton.urlToShow = [[[annotation geoEvent] url] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [myDetailButton addTarget:self action:@selector(wikipediaButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
                
                myDetailButton.eventDescription = [[annotation geoEvent] description];
                myDetailButton.eventType = [[annotation geoEvent] type];
                pin.leftCalloutAccessoryView = myDetailButton;
                
                
                // Set up the share button
                myShareButton = [MyAnnotationButton buttonWithType:UIButtonTypeCustom];
    //            [myShareButton setImage:imgWikipedia forState:UIControlStateNormal];
                [myShareButton setImage:imgShare forState:UIControlStateNormal];
                myShareButton.frame = CGRectMake(0, 0, 40, 40);
                myShareButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                
                myShareButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                
                //myShareButton.urlToShow = [[[annotation geoEvent] url] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [myShareButton addTarget:self action:@selector(shareButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
                
                myShareButton.eventDescription =[[annotation geoEvent] description];
                pin.rightCalloutAccessoryView = myShareButton;
                
                selectedPin = pin;
            }
        }
    
        return pin;
    }

- (IBAction)deselectAnnotation:(id)sender
{
    if(customView != nil){
        [customView removeFromSuperview];
    }
}

- (void)wikipediaButtonTapped:(id)sender event:(id)event
{

    if (![urlBackup isEqualToString:[sender urlToShow]]){
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[sender urlToShow]]]];
        urlBackup = [sender urlToShow];
    }
    
    [self showWebView];
}

- (void)shareButtonTapped:(id)sender event:(id)event
{
    NSLog(@"Share button tapped");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mapView.delegate = self;

    if (!appDelegate){
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    if(!geocoder){
        geocoder = [[CLGeocoder alloc] init];
    }
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeAll;
    }
    
    [monthPicker reloadInputViews];
    [monthPicker reloadAllComponents];
    
    imgBirthDayOn = [UIImage imageNamed:@"birthday_on"];
    imgBirthDayOff = [UIImage imageNamed:@"birthday_off"];
    
    imgDeathOn = [UIImage imageNamed:@"deaths_on"];
    imgDeathOff = [UIImage imageNamed:@"deaths_off"];
    
    imgEventOn = [UIImage imageNamed:@"event_on"];
    imgEventOff = [UIImage imageNamed:@"event_off"];
    
    //imgWikipedia = [UIImage imageNamed:@"wikipedia_logo_button"];
    imgWikipedia = [UIImage imageNamed:@"wiki_logo"];
    
    imgShare = [UIImage imageNamed:@"share_image"];
    
    imgFilter = [UIImage imageNamed:@"filter_icon"];
    
    imgClose = [UIImage imageNamed:@"close"];
    
    [mapView showsUserLocation];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd\/MM"];
    
    currentDate = [NSDate date];
    
    dateSelected = [dateFormatter stringFromDate:currentDate];
    
    arrayDate = [dateSelected componentsSeparatedByString:@"/"];

    settings = [NSUserDefaults standardUserDefaults];
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    userLocale = language;

    [monthPicker setDataSource:self];
    monthPicker.delegate = self;
    
    CGRect scrollViewFrame = self.eventsSelectorView.frame;
    scrollViewFrame.origin.x = self.mapView.layer.frame.size.width;
    scrollViewFrame.size.width = 45;
    self.eventsSelectorView.frame = scrollViewFrame;
    //////self.eventsSelectorView.layer.cornerRadius = 8.0;

    CGRect buttonMenuViewFrame = self.buttonFilterView.frame;
    buttonMenuViewFrame.origin.x = self.mapView.layer.frame.size.width - (self.buttonFilterView.frame.size.width - 5);
    buttonMenuViewFrame.size.width = 40;
    self.buttonFilterView.frame = buttonMenuViewFrame;
    //self.buttonFilterView.layer.cornerRadius = 5.0;
 
    CGRect calendarViewFrame = self.monthPicker.frame;
    //calendarViewFrame.origin.x -= self.monthPicker.frame.size.width;
    calendarViewFrame.origin.x = 0;
    calendarViewFrame.origin.y = self.view.frame.size.width/2 - self.monthPicker.frame.size.height/2;
    self.monthPicker.frame = calendarViewFrame;
    //////self.monthPicker.layer.cornerRadius = 8.0;
    
    CGRect buttonCalendarViewFrame = self.buttonCalendarView.frame;
    buttonCalendarViewFrame.origin.x = - 5;
    self.buttonCalendarView.frame = buttonCalendarViewFrame;
    //self.buttonCalendarView.layer.cornerRadius = 5.0;
    
    arrayItems = [[NSMutableArray alloc] initWithCapacity:1];
    
    GeoEvent *geoEvent = [[GeoEvent alloc] initWithType:@"" longitude:@"" latitude:@"" country:@"" date:@"" description:@"" isCoupled:@"" generation:@"" language:@"" isCatched:@"" geoEventId:@""];
    
    [arrayItems addObject:geoEvent];
    
    if([userLocale isEqualToString:LOCALE_SPANISH]){
    arrayMonths = [[NSMutableArray alloc] initWithObjects:@"Enero", @"Febrero", @"Marzo", @"Abril", @"Mayo",
                   @"Junio", @"Julio", @"Agosto", @"Septiembre", @"Octubre", @"Noviembre",
                   @"Diciembre", nil];
    } else{
        arrayMonths = [[NSMutableArray alloc] initWithObjects:@"January", @"February", @"March", @"April", @"May",
                       @"June", @"July", @"August", @"September", @"October", @"November",
                       @"December", nil];
    }
    arrayDaysFebruary = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", nil];
    arrayDays30 = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", nil];
    arrayDays31 = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", nil];
    
    // Lite
    ////////NSLog( @"ADMOB version: %@", [GADRequest sdkVersion] );

    // Crear una vista del tamaño estándar en la parte inferior de la pantalla. GADBannerView
    // Lite
    ////////bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
    
    // Especificar el "identificador de bloque" del anuncio. Se trata del ID de editor de AdMob.
    // Lite
    ////////bannerView_.adUnitID = @"a150fbda1caeec3";
    
    // Hay que comunicar al módulo de tiempo de ejecución el UIViewController que debe restaurar después de llevar
    // al usuario donde vaya el anuncio y añadirlo a la jerarquía de vistas.
    // Lite
    ////////bannerView_.rootViewController = self;
    
    
    // Lite
    ////////[self.mapView addSubview:bannerView_];
    
    // Iniciar una solicitud genérica para cargarla con un anuncio.
    // Lite
    ////////[bannerView_ loadRequest:[GADRequest request]];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    //NSLog(@"Did Update Location = %f / %f", [newLocation coordinate].latitude, [newLocation coordinate].longitude);
    
    //NSLog(@"Current User Location = %f / %f", [[mapView userLocation] coordinate].latitude, [[mapView userLocation] coordinate].longitude);
    
    
    [geocoder reverseGeocodeLocation: newLocation completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         
         userCity = placemark.locality;
         [self getGeoEvents];
         [self.locationManager stopUpdatingLocation];
         cityLocated = TRUE;
     }];
    
}

- (IBAction) showFilterMenu:(id)sender{
    
    CGRect scrollViewFrame = eventsSelectorView.frame;
    CGRect buttonMenuViewFrame = self.buttonFilterView.frame;
    
    buttonMenuViewFrame.size.width = 40;
    scrollViewFrame.size.width = 45;
    labelTypeEvent.text = @"";

    if(buttonMenuSelected == FALSE){
        buttonMenuSelected = TRUE;
        scrollViewFrame.origin.x = self.mapView.layer.frame.size.width - scrollViewFrame.size.width + 5;

        buttonMenuViewFrame.origin.x = self.mapView.layer.frame.size.width - self.buttonFilterView.frame.size.width - scrollViewFrame.size.width + 10;
        
    } else{
        buttonMenuSelected = FALSE;
        scrollViewFrame.origin.x = self.mapView.layer.frame.size.width;
        buttonMenuViewFrame.origin.x =  self.mapView.layer.frame.size.width - self.buttonFilterView.frame.size.width + 5;

    }
    self.filterButton.enabled = FALSE;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         eventsSelectorView.frame = scrollViewFrame;
                         self.buttonFilterView.frame = buttonMenuViewFrame;
                     }
                     completion:^(BOOL finished){
                     }];
    [UIView commitAnimations];
    self.filterButton.enabled = TRUE;
    [customView setHidden:TRUE];
    
}

- (IBAction) showCalendarFilterMenu:(id)sender{
    
    //CGRect calendarViewFrame = self.monthPicker.frame;
    //CGRect buttonCalendarViewFrame = self.buttonCalendarView.frame;
    
    //buttonCalendarViewFrame.size.width = 40;
    //calendarViewFrame.size.width = 230;
    
    /*if(buttonCalendarMenuSelected == FALSE){
        buttonCalendarMenuSelected = TRUE;
        calendarViewFrame.origin.x = -3;
        
        buttonCalendarViewFrame.origin.x = calendarViewFrame.size.width - 8;
        
    } else{*/
        [self removeAnnotations];
        [self getGeoEvents];
       /* if(buttonMenuSelected){
            [self showFilterMenu:0];
        }
        */
        //[self.birthdayButton setImage:imgBirthDayOn forState:UIControlStateNormal];
       // shouldShowBirthdays = TRUE;
//        [self.birthdayButton setSelected:FALSE];
      //  [self.birthdayButton setSelected:!self.birthdayButton.selected];
    
        //[self.deathButton setImage:imgDeathOn forState:UIControlStateNormal];
        //shouldShowDeaths = TRUE;
        //[self.deathButton setSelected:FALSE];
        //[self.deathButton setSelected:!self.deathButton.selected];
    
        //[self.eventsButton setImage:imgEventOn forState:UIControlStateNormal];
        //shouldShowEvents = TRUE;
        //[self.eventsButton setSelected:FALSE];
        //[self.eventsButton setSelected:!self.eventsButton.selected];

        buttonCalendarMenuSelected = FALSE;
    
      /*  calendarViewFrame.origin.x = -self.monthPicker.frame.size.width;
        calendarViewFrame.origin.y = self.view.frame.size.width/2 - self.monthPicker.frame.size.height/2;
        buttonCalendarViewFrame.origin.x = -5;
        
       
 //   }*/
    /*self.calendarButton.enabled = FALSE;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.monthPicker.frame = calendarViewFrame;
                         self.buttonCalendarView.frame = buttonCalendarViewFrame;
                     }
                     completion:^(BOOL finished){
                     }];
    [UIView commitAnimations];
    self.calendarButton.enabled = TRUE;
     */
    [customView setHidden:TRUE];
     labelTypeEvent.text = @"";
}

- (IBAction) filterEventsByDate:(id)sender{
}

- (IBAction) filterEvents:(id)sender{
    
     int tag = [sender tag];

    [[NSURLCache sharedURLCache] removeAllCachedResponses];

     switch (tag) {
         case 10:
             
             if([self.birthdayButton isSelected]){
                 //[self.birthdayButton setImage:imgBirthDayOn forState:UIControlStateNormal];
                 
                 [self.birthdayButton setTitleColor:greenColor forState:UIControlStateNormal];
                 shouldShowBirthdays = TRUE;
             } else{
                 //[self.birthdayButton setImage:imgBirthDayOff forState:UIControlStateNormal];
                 
                 [self.birthdayButton setTitleColor:blackColor forState:UIControlStateNormal];
                  shouldShowBirthdays = FALSE;
             }
             if([userLocale isEqualToString:LOCALE_SPANISH]){
                 [self deleteEventType:TYPE_BIRTHDAY];
             }else{
                 [self deleteEventType:TYPE_BIRTHDAY];
             }
             [self.birthdayButton setSelected:!self.birthdayButton.selected];
             //[self.birthdayButton setSelected:!shouldShowBirthdays];
             
             break;
         case 12:
             
             if([self.eventsButton isSelected]){
                 //[self.eventsButton setImage:imgEventOn forState:UIControlStateNormal];
                 [self.eventsButton setTitleColor:violetColor forState:UIControlStateNormal];
                  shouldShowEvents = TRUE;
             } else{
                 //[self.eventsButton setImage:imgEventOff forState:UIControlStateNormal];
                 [self.eventsButton setTitleColor:blackColor forState:UIControlStateNormal];
                 shouldShowEvents = FALSE;
             }
             if([userLocale isEqualToString:LOCALE_SPANISH]){
                 [self deleteEventType:TYPE_EVENT];
             }else{
                 [self deleteEventType:TYPE_EVENT];
             }
             
             [self.eventsButton setSelected:!self.eventsButton.selected];
             
             break;
         case 11:
             
             if([self.deathButton isSelected]){
                // [self.deathButton setImage:imgDeathOn forState:UIControlStateNormal];
                [self.deathButton setTitleColor:redColor forState:UIControlStateNormal];
                 shouldShowDeaths = TRUE;

             } else{
                 //[self.deathButton setImage:imgDeathOff forState:UIControlStateNormal];
                [self.deathButton setTitleColor:blackColor forState:UIControlStateNormal];
                 shouldShowDeaths = FALSE;
             }
             if([userLocale isEqualToString:LOCALE_SPANISH]){
                 [self deleteEventType:TYPE_DEATH];
             }else{
                 [self deleteEventType:TYPE_DEATH];
             }
             [self.deathButton setSelected:!self.deathButton.selected];
             
             break;
        default:
             break;
     }
    
}

- (void)deleteEventType:(NSString *)eventType {
    MyLocation *nextAnnotation;

    for (int i = 0; i < [[mapView annotations] count]; i++)
	{
		nextAnnotation = [[mapView annotations]objectAtIndex: i];
		
		if([nextAnnotation isKindOfClass:[MyLocation class]] && [eventType isEqualToString:[nextAnnotation itemType]]){

			if([[mapView viewForAnnotation:nextAnnotation] isHidden]){
                [[mapView viewForAnnotation:nextAnnotation] setHidden:NO];
                [mapView deselectAnnotation:nextAnnotation animated:NO];
                    [[mapView viewForAnnotation:nextAnnotation]  setEnabled:YES];

            }else{
                    [[mapView viewForAnnotation:nextAnnotation] setHidden:YES];
                    [[mapView viewForAnnotation:nextAnnotation] setHidden:YES];
                    [[mapView viewForAnnotation:nextAnnotation] setEnabled:NO];

            }

		}
	}

}

- (void)deleteAllEventType {
    MyLocation *nextAnnotation;
    
    for (int i = 0; i < [[mapView annotations] count]; i++)
	{
		nextAnnotation = [[mapView annotations]objectAtIndex: i];
		
		if([nextAnnotation isKindOfClass:[MyLocation class]]){
            
			if([[mapView viewForAnnotation:nextAnnotation] isHidden]){
                [[mapView viewForAnnotation:nextAnnotation] setHidden:NO];
                [mapView deselectAnnotation:nextAnnotation animated:NO];
                [[mapView viewForAnnotation:nextAnnotation]  setEnabled:YES];
                
            }
            
		}
	}
    
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    if(component == 1){
        return [arrayMonths count];
        } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Enero"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Marzo"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Mayo"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Julio"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Agosto"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Octubre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Diciembre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"January"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"March"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"May"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"July"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"August"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"October"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"December"])) {
            
            arrayDays = arrayDays31;
            [pickerView reloadInputViews];
            return [arrayDays count];
    }
    else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Febrero"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"February"])){
            
        arrayDays = arrayDaysFebruary;
        [pickerView reloadInputViews];
        return [arrayDays count];
  
    } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Abril"] ||[[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Junio"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Septiembre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Noviembre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"April"] ||[[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"June"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"September"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"November"])) {
       
        arrayDays = arrayDays30;
        [pickerView reloadInputViews];

        return [arrayDays count];
    }
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 1){
          
        NSString *month = [arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]];
        if ([month isEqual:@"Enero"] || [month isEqual:@"January"]) {
            monthSelected = @"01";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Febrero"] || [month isEqual:@"February"]) {
            monthSelected = @"02";
            arrayDays = arrayDaysFebruary;
        } else
        if ([month isEqual:@"Marzo"] || [month isEqual:@"March"]) {
            monthSelected = @"03";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Abril"] || [month isEqual:@"April"]) {
            monthSelected = @"04";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Mayo"] || [month isEqual:@"May"]) {
            monthSelected = @"05";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Junio"] || [month isEqual:@"June"]) {
            monthSelected = @"06";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Julio"] || [month isEqual:@"July"]) {
            monthSelected = @"07";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Agosto"] || [month isEqual:@"August"]) {
            monthSelected = @"08";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Septiembre"] || [month isEqual:@"September"]) {
            monthSelected = @"09";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Octubre"] || [month isEqual:@"October"]) {
            monthSelected = @"10";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Noviembre"] || [month isEqual:@"November"]) {
            monthSelected = @"11";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Diciembre"] || [month isEqual:@"December"]) {
            monthSelected = @"12";
            arrayDays = arrayDays31;
        }
        
        if([monthPicker selectedRowInComponent:0] + 1 > arrayDays.count){
            daySelected = [arrayDays objectAtIndex:(arrayDays.count - 1)];
        } else {
            daySelected = [arrayDays objectAtIndex:[monthPicker selectedRowInComponent:0]];
        }

            [pickerView reloadInputViews];
            [pickerView reloadAllComponents];

        } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Enero"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Marzo"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Mayo"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Julio"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Agosto"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Octubre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Diciembre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"January"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"March"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"May"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"July"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"August"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"October"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"December"])) {
       
            arrayDays = arrayDays31;
            if([monthPicker selectedRowInComponent:0] + 1 > arrayDays.count){
                daySelected = [arrayDays objectAtIndex:(arrayDays.count -  1)];
            } else {
                daySelected = [arrayDays objectAtIndex:row];
            }
            [pickerView reloadInputViews];

    } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Febrero"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"February"])){
     
        arrayDays = arrayDaysFebruary;
        if([monthPicker selectedRowInComponent:0] + 1 > arrayDays.count){
            daySelected = [arrayDays objectAtIndex:(arrayDays.count -  1)];
        } else {
            daySelected = [arrayDays objectAtIndex:row];
        }
        [pickerView reloadInputViews];
    } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Abril"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Junio"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Septiembre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Noviembre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"April"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"June"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"September"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"November"])) {
   
        arrayDays = arrayDays30;
        if([monthPicker selectedRowInComponent:0] + 1 > arrayDays.count){
            daySelected = [arrayDays objectAtIndex:(arrayDays.count -  1)];
        } else {
            daySelected = [arrayDays objectAtIndex:row];
        }
        [pickerView reloadInputViews];
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
   
    if(component == 1){
       
        NSString *month = [arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]];
        if ([month isEqual:@"Enero"] || [month isEqual:@"January"]) {
            monthSelected = @"01";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Febrero"] || [month isEqual:@"February"]) {
            monthSelected = @"02";
            arrayDays = arrayDaysFebruary;
        } else
        if ([month isEqual:@"Marzo"] || [month isEqual:@"March"]) {
            monthSelected = @"03";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Abril"] || [month isEqual:@"April"]) {
            monthSelected = @"04";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Mayo"] || [month isEqual:@"May"]) {
            monthSelected = @"05";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Junio"] || [month isEqual:@"June"]) {
            monthSelected = @"06";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Julio"] || [month isEqual:@"July"]) {
            monthSelected = @"07";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Agosto"] || [month isEqual:@"August"]) {
            monthSelected = @"08";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Septiembre"] || [month isEqual:@"September"]) {
            monthSelected = @"09";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Octubre"] || [month isEqual:@"October"]) {
            monthSelected = @"10";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Noviembre"] || [month isEqual:@"November"]) {
            monthSelected = @"11";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Diciembre"] || [month isEqual:@"December"]) {
            monthSelected = @"12";
            arrayDays = arrayDays31;
        }
        
        [pickerView reloadInputViews];
        
        return [arrayMonths objectAtIndex:row];
        
    } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Enero"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Marzo"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Mayo"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Julio"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Agosto"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Octubre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Diciembre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"January"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"March"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"May"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"July"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"August"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"October"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"December"])) {
       
        arrayDays = arrayDays31;

        [pickerView reloadInputViews];
        
        return [arrayDays objectAtIndex:row];
    } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Febrero"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"February"])){
    
        arrayDays = arrayDaysFebruary;
        
        [pickerView reloadInputViews];

        return [arrayDays objectAtIndex:row];

      } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Abril"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Junio"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Septiembre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Noviembre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"April"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"June"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"September"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"November"])) {
      
        arrayDays = arrayDays30;

        [pickerView reloadInputViews];

        return [arrayDays objectAtIndex:row];
     }
    
}


- (void)topPinTapped {
    
    // dismiss out callout if it's already shown but on a different parent view
 //////   [bottomMapView deselectAnnotation:bottomPin.annotation animated:NO];
    
    // now in this example we're going to introduce an artificial delay in order to make our popup feel identical to MKMapView.
    // MKMapView has a delay after tapping so that it can intercept a double-tap for zooming. We don't need that delay but we'll
    // add it just so things feel the same.
 //////////   [self performSelector:@selector(popupMapCalloutView:) withObject:nil afterDelay:1.0/3.0];
}

#pragma mark - MKMapView

/*- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // make sure to display our precreated pin that adds an accessory view.
    return bottomPin;
}*/

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    // dismiss out callout if it's already shown but on a different parent view
    
    if (calloutView.window)
        [calloutView dismissCalloutAnimated:NO];
    
    // now in this example we're going to introduce an artificial delay in order to make our popup feel identical to MKMapView.
    // MKMapView has a delay after tapping so that it can intercept a double-tap for zooming. We don't need that delay but we'll
    // add it just so things feel the same.
  [self performSelector:@selector(popupMapCalloutView:) withObject:view afterDelay:1.0/3.0];
    //CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude + 5, view.annotation.coordinate.longitude);
    
    CLLocationCoordinate2D newCenter;
    
    /*if (self.view.frame.size.height == 480.0) { //3.5 inch
         //newCenter = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude + 5, view.annotation.coordinate.longitude);
        UIDevice *currentDevice = [UIDevice currentDevice];
        if ([currentDevice.model rangeOfString:@"Simulator"].location == NSNotFound) { // Device
            newCenter = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude + 2, view.annotation.coordinate.longitude);
        } else { // Simulator
            newCenter = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude + 7, view.annotation.coordinate.longitude);
        }

        
    } else if (self.view.frame.size.height == 568.0) { // 4 inch
       
        UIDevice *currentDevice = [UIDevice currentDevice];
        if ([currentDevice.model rangeOfString:@"Simulator"].location == NSNotFound) { // Device*/
            //newCenter = CLLocationCoordinate2DMake(coordX + 2, view.annotation.coordinate.longitude);
            
            // newCenter = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude + 2, view.annotation.coordinate.longitude);
            
            CGFloat pixelsPerDegreeLat = self.mapView.frame.size.height / self.mapView.region.span.latitudeDelta;
            CGFloat pixelsPerDegreeLon = self.mapView.frame.size.width / self.mapView.region.span.longitudeDelta;
            
            //CLLocationDegrees latitudinalShift = offset.height / pixelsPerDegreeLat;
            //CLLocationDegrees longitudinalShift = -(offset.width / pixelsPerDegreeLon);
            
            CLLocationDegrees latitudinalShift = 70 / pixelsPerDegreeLat;
            CLLocationDegrees longitudinalShift = 0 / pixelsPerDegreeLon;
            
            CGFloat lat = view.annotation.coordinate.latitude + latitudinalShift;
            CGFloat lon = view.annotation.coordinate.longitude + longitudinalShift;
            
            CLLocationCoordinate2D newCenterCoordinate = (CLLocationCoordinate2D){lat, lon};
            
            newCenter = newCenterCoordinate;

 /*       } else { // Simulator
            newCenter = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude + 6, view.annotation.coordinate.longitude);
        }

    } else if (self.view.frame.size.height == 1024.0) { // iPad
       // newCenter = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude + 4, view.annotation.coordinate.longitude);
        
        UIDevice *currentDevice = [UIDevice currentDevice];
        if ([currentDevice.model rangeOfString:@"Simulator"].location == NSNotFound) { // Device
            newCenter = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude + 2, view.annotation.coordinate.longitude);
        } else { // Simulator
            newCenter = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude + 3, view.annotation.coordinate.longitude);
        }

        
    } else {
        newCenter = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude + 3, view.annotation.coordinate.longitude);
    }*/
   
    [[self mapView] setCenterCoordinate:newCenter animated:YES];
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    // again, we'll introduce an artifical delay to feel more like MKMapView for this demonstration.
    [calloutView performSelector:@selector(dismissCalloutAnimated:) withObject:nil afterDelay:1.0/3.0];
}

#pragma mark - SMCalloutView

- (void)popupCalloutView {
    
    // clear any custom view that was set by another pin
    calloutView.contentView = nil;
    calloutView.backgroundView = [SMCalloutBackgroundView systemBackgroundView]; // use the system graphics
    
    // This does all the magic.
    [calloutView presentCalloutFromRect:selectedPin.frame
                                 inView:marsView
                      constrainedToView:calloutView
               permittedArrowDirections:SMCalloutArrowDirectionAny
                               animated:YES];
}

- (void)popupMapCalloutView:(MKAnnotationView *) pin  {

    [customView setHidden:TRUE];
    
    MyAnnotationButton *leftButton =  (MyAnnotationButton *)pin.leftCalloutAccessoryView;
    MyAnnotationButton *rightButton =  (MyAnnotationButton *)pin.rightCalloutAccessoryView;
    
    UIView *leftButtonView = [[UIView alloc] initWithFrame:CGRectMake(7.5, 10 , 40, 40)];
    [leftButtonView addSubview:leftButton];
    UIView *rightButtonView = [[UIView alloc] initWithFrame:CGRectMake(402.5, 10 , 40, 40)];
    [rightButtonView addSubview:rightButton];
    
    
    if([userLocale isEqualToString:LOCALE_SPANISH] && [leftButton.eventType isEqualToString:TYPE_DEATH]){
        labelTypeEvent.text = SPANISH_DEATH_TEXT;
         [labelTypeEvent setTextColor:redColor];
    } else if([userLocale isEqualToString:LOCALE_SPANISH] && [leftButton.eventType isEqualToString:TYPE_BIRTHDAY]){
        labelTypeEvent.text = SPANISH_BIRTHDAY_TEXT;
        [labelTypeEvent setTextColor:greenColor];
    } else if([userLocale isEqualToString:LOCALE_SPANISH] && [leftButton.eventType isEqualToString:TYPE_EVENT]){
        labelTypeEvent.text = SPANISH_EVENT_TEXT;
        [labelTypeEvent setTextColor:violetColor];
    }  else if(![userLocale isEqualToString:LOCALE_SPANISH] && [leftButton.eventType isEqualToString:TYPE_DEATH]){
        labelTypeEvent.text = ENGLISH_DEATH_TEXT;
        [labelTypeEvent setTextColor:redColor];
    } else if(![userLocale isEqualToString:LOCALE_SPANISH] && [leftButton.eventType isEqualToString:TYPE_BIRTHDAY]){
        labelTypeEvent.text = ENGLISH_BIRTHDAY_TEXT;
        [labelTypeEvent setTextColor:greenColor];
    } else if(![userLocale isEqualToString:LOCALE_SPANISH] && [leftButton.eventType isEqualToString:TYPE_EVENT]){
        labelTypeEvent.text = ENGLISH_EVENT_TEXT;
        [labelTypeEvent setTextColor:violetColor];
    }
    
    
    
    
    CGFloat textWidth =  [labelTypeEvent.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}].width;
    
    labelTypeEvent.frame = CGRectMake(0, 0, textWidth, 44);
    
    [labelTypeEvent setCenter:toolBar.center];
    
    
    // UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(40, 10, 400, 30)];
    // [textField setEnabled:NO];
    NSString* description = [[NSString alloc] initWithFormat:@"%@", leftButton.eventDescription];
    description = [description stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    description = [description stringByReplacingOccurrencesOfString:@"&amp;nbsp;" withString:@" "];
    
    int descLength = [description length];
    
    double numTextFields = round(description.length / 50);
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 15.0f;
    paragraphStyle.maximumLineHeight = 15.0f;
    paragraphStyle.minimumLineHeight = 15.0f;
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(54, 0, 340, 60)];
    NSString *string = description;
    NSDictionary *ats = @{
                          NSFontAttributeName : [UIFont fontWithName:@"Arial" size:11.0f],
                          NSParagraphStyleAttributeName : paragraphStyle,
                          };
    
    textView.attributedText = [[NSAttributedString alloc] initWithString:string attributes:ats];
    [textView setHidden:TRUE];
    if([description isEqualToString:@"(null)"]){
        description = @"";
    }
    [textView setText:description];
    [textView setFont:[UIFont fontWithName:@"Arial" size:11]];
    [textView setScrollEnabled:YES];
    [textView setUserInteractionEnabled:YES];
    [textView setEditable:NO];
    [textView setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    [textView setHidden:FALSE];
    [textView setExclusiveTouch:YES];
    [textView setSelectable:NO];
   // [textView resignFirstResponder];
    //[textView setDelegate:self];
    
    
    /*if(customView != nil){
        [customView removeFromSuperview];
    }*/
    //self.mapView.layer.frame.size
    // custom view to be used in our callout
    customView = [[UIView alloc] initWithFrame:CGRectMake((self.view.layer.frame.size.height - 450) / 2, self.view.frame.size.width/2 - 50 , 450, 60)];
    
    
    UILongPressGestureRecognizer *customViewtap = [[UILongPressGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(keepCustomView:)];
    
    [textView addGestureRecognizer:customViewtap];
    
    [customView addSubview:textView];
    
    [customView setHidden:FALSE];
    //customView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    //customView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green: 122.0/255.0 blue: 255.0/255.0 alpha: 1.0];

    
    //customView.backgroundColor = [UIColor colorWithRed:201.0/255.0 green: 105.0/255.0 blue: 224.0/255.0 alpha: 1.0];

    //customView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    customView.layer.borderWidth = 0.1;
    customView.layer.cornerRadius = 8;
    

    if([leftButton.eventType isEqualToString:@"FALLECIMIENTO"] || [leftButton.eventType isEqualToString:@"DEATH"]){
        customView.backgroundColor = [UIColor colorWithRed:252.0/255.0 green: 53.0/255.0 blue: 54.0/255.0 alpha: 1.0];
    } else if([leftButton.eventType isEqualToString:@"NACIMIENTO"] || [leftButton.eventType isEqualToString:@"BIRTHDAY"]){
        customView.backgroundColor = [UIColor colorWithRed:76.0/255.0 green: 217.0/255.0 blue: 100.0/255.0 alpha: 1.0];
    } else if([leftButton.eventType isEqualToString:@"EVENTO HISTÓRICO"] || [leftButton.eventType isEqualToString:@"EVENT"]){
        customView.backgroundColor = [UIColor colorWithRed:201.0/255.0 green: 105.0/255.0 blue: 224.0/255.0 alpha: 1.0];
    }
    // Uncomment this to demonstrate how you can embed editable controls inside the callout when
    // used on a MKMapView. It's important that you use our CustomMapView subclass for this to
    // work on iOS 6 and better.
    
    
    [customView addSubview:rightButtonView];
    [customView addSubview:leftButtonView];

    
    
    // if you provide a custom view for the callout content, the title and subtitle will not be displayed
    calloutView.contentView = customView;
    calloutView.backgroundView = nil; // reset background view to the default SMCalloutDrawnBackgroundView
    
    // just to mix things up, we'll present the callout in a Layer instead of a View. This will require us to override
    // -hitTest:withEvent: in our CustomMapView subclass.
    /*[calloutView presentCalloutFromRect:selectedPin.bounds
                                 inView:selectedPin
                      constrainedToView:customView
               permittedArrowDirections:SMCalloutArrowDirectionAny
                               animated:YES];*/
    [mapView addSubview:customView];
}

- (NSTimeInterval)calloutView:(SMCalloutView *)theCalloutView delayForRepositionWithSize:(CGSize)offset {
    
    // Uncomment this to cancel the popup
    // [calloutView dismissCalloutAnimated:NO];
    
    // if annotation view is coming from MKMapView, it's contained within a MKAnnotationContainerView instance
    // so we need to adjust the map position so that the callout will be completely visible when displayed
    if ([NSStringFromClass([calloutView.superview.superview class]) isEqualToString:@"MKAnnotationContainerView"]) {
        CGFloat pixelsPerDegreeLat = bottomMapView.frame.size.height / bottomMapView.region.span.latitudeDelta;
        CGFloat pixelsPerDegreeLon = bottomMapView.frame.size.width / bottomMapView.region.span.longitudeDelta;
        
        CLLocationDegrees latitudinalShift = offset.height / pixelsPerDegreeLat;
        CLLocationDegrees longitudinalShift = -(offset.width / pixelsPerDegreeLon);
        
        CGFloat lat = bottomMapView.region.center.latitude + latitudinalShift;
        CGFloat lon = bottomMapView.region.center.longitude + longitudinalShift;
        CLLocationCoordinate2D newCenterCoordinate = (CLLocationCoordinate2D){lat, lon};
        if (fabsf(newCenterCoordinate.latitude) <= 90 && fabsf(newCenterCoordinate.longitude <= 180)) {
            [bottomMapView setCenterCoordinate:newCenterCoordinate animated:YES];
        }
    }
    else {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x-offset.width, scrollView.contentOffset.y-offset.height) animated:YES];
    }
    
    return kSMCalloutViewRepositionDelayForUIScrollView;
}

- (void)disclosureTapped {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tap!" message:@"You tapped the disclosure button."
                                                   delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Whatevs",nil];
    [alert show];
}

- (void)dismissCallout {
    [calloutView dismissCalloutAnimated:NO];
    
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    CGFloat componentWidth = 0.0;
    if(component == 0){
        componentWidth = 73.0;
    } else{
        componentWidth = 135.0;
    }
    return componentWidth;
}

- (void)dismissCustomView:(UITapGestureRecognizer *)gestureRecognizer
{
    for (id<MKAnnotation> ann in mapView.selectedAnnotations) {
        [mapView deselectAnnotation:ann animated:NO];
    }
    
    CGPoint currentlocation = [gestureRecognizer locationInView:customView];
    
    if (CGRectContainsPoint(textView.frame, currentlocation) && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [(UIPanGestureRecognizer*)gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        
        isPanning = TRUE;
        
    } else if (CGRectContainsPoint(textView.frame, currentlocation) && [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {

        [customView setHidden:TRUE];
        isPanning = FALSE;
        labelTypeEvent.text = @"";
        
    } else if (!CGRectContainsPoint(textView.frame, currentlocation) && [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        
        [customView setHidden:TRUE];
        isPanning = FALSE;
        labelTypeEvent.text = @"";
        
    } else if (!CGRectContainsPoint(textView.frame, currentlocation) && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [(UIPanGestureRecognizer*)gestureRecognizer state] == UIGestureRecognizerStateEnded) {

        isPanning = FALSE;
        
    }else if (!CGRectContainsPoint(textView.frame, currentlocation) && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [(UIPanGestureRecognizer*)gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        
        [customView setHidden:TRUE];
        isPanning = FALSE;
        labelTypeEvent.text = @"";
    }
    else {
        isPanning = FALSE;
    }
    
 
}

- (void)keepCustomView:(UITapGestureRecognizer *)gestureRecognizer
{
    [textView becomeFirstResponder];
    [customView setHidden:FALSE];
}

-(BOOL)prefersStatusBarHidden { return YES; }

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    isPanning = TRUE;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    isPanning = TRUE;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isPanning = FALSE;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    isPanning = FALSE;
}
/*
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self.view];
    
    //static
    
   
    
    if ((touchPoint.x > ((self.view.layer.frame.size.height - 450) / 2) + 54) && (touchPoint.x < ((self.view.layer.frame.size.height - 450) / 2) + 54 + 340) && (touchPoint.y > (self.view.frame.size.width/ 2) - 100) && (touchPoint.y > (((self.view.frame.size.width/2) - 100 + 60)))) {
//    if ([touch.view isKindOfClass:[UIControl class]])
        return NO;
    } else {
        //return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
         return YES;
    }
    
}
*/
- (void)didReceiveMemoryWarning
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [arrayItems removeAllObjects];
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    
}

@end

//
// Custom subclasses for using SMCalloutView with MKMapView
//

@implementation MapAnnotation @end

@interface MKMapView (UIGestureRecognizer)

// this tells the compiler that MKMapView actually implements this method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

@end

@implementation CustomMapView

// override UIGestureRecognizer's delegate method so we can prevent MKMapView's recognizer from firing
// when we interact with UIControl subclasses inside our callout view.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isKindOfClass:[UIControl class]])
        return NO;
    else
        return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *calloutMaybe = [self.calloutView hitTest:[self.calloutView convertPoint:point fromView:self] withEvent:event];
    if (calloutMaybe) return calloutMaybe;
    
    return [super hitTest:point withEvent:event];
}

@end


