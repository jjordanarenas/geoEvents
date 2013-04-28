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
#import "TSMiniWebBrowser.h"
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
@property (nonatomic, strong) IBOutlet TSMiniWebBrowser *webBrowser;

//@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation ViewController

@synthesize eventsButton = _eventsButton;
@synthesize birthdayButton = _birthdayButton;
@synthesize deathButton = _deathButton;
@synthesize filterButton = _filterButton;
@synthesize calendarButton = _calendarButton;
@synthesize webBrowser = _webBrowser;

@synthesize mapView;
@synthesize eventsSelectorView;
@synthesize userLocation;
@synthesize arrayItems;
@synthesize locationManager;
@synthesize buttonFilterView;
@synthesize buttonCalendarView;
@synthesize datePicker;
@synthesize monthPicker;

AppDelegate *appDelegate;

GADBannerView *bannerView_;

static NSString *const TYPE_BIRTHDAY = @"BIRTHDAY";
static NSString *const TYPE_DEATH = @"DEATH";
static NSString *const TYPE_EVENT = @"EVENT";
static NSString *const TYPE_BIRTHDAY_ES = @"NACIMIENTO";
static NSString *const TYPE_DEATH_ES = @"FALLECIMIENTO";
static NSString *const TYPE_EVENT_ES = @"EVENTO HISTÓRICO";
static NSString *const LOCALE_ENGLISH = @"en";
static NSString *const LOCALE_SPANISH = @"es";

BOOL cityLocated = FALSE;
BOOL connectionAlerted = FALSE;
BOOL buttonMenuSelected = FALSE;
BOOL buttonCalendarMenuSelected = FALSE;
BOOL shouldShowDeaths = TRUE;
BOOL shouldShowBirthdays = TRUE;
BOOL shouldShowEvents = TRUE;
BOOL calendarMustRefresh = TRUE;

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
NSString* dateSelected;

UIImage *imgBirthDayOn;
UIImage *imgBirthDayOff;
UIImage *imgDeathOn;
UIImage *imgDeathOff;
UIImage *imgEventOn;
UIImage *imgEventOff;
UIImage *imgWikipedia;


//TSMiniWebBrowser *webBrowser;

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
    
    _webBrowser =nil;
}

- (void)viewDidAppear:(BOOL)animated{
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
    
    [monthPicker reloadInputViews];
    [monthPicker reloadAllComponents];
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

    [arrayItems removeAllObjects];
    arrayItems = [[NSMutableArray alloc] init];
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
    MyLocation *annotation;
    
    static NSString *const TYPE_BIRTHDAY = @"BIRTHDAY";
    static NSString *const TYPE_DEATH = @"DEATH";
    static NSString *const TYPE_EVENT = @"EVENT";
    @autoreleasepool {
	for(int i = 0; i < arrayItems.count; i++){
        
        geoEvent = (GeoEvent *)[arrayItems objectAtIndex:i];
    
        address = [geoEvent description];
        itemType = [geoEvent type];
        //image;
        
		//CLLocationCoordinate2D coordinate;
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
   
		//MyLocation *annotation = [[MyLocation alloc] initWithName:itemType address:address itemType:itemType image:image coordinate:coordinate geoEvent:geoEvent];
        
        annotation = [[MyLocation alloc] initWithName:itemType address:address itemType:itemType image:image coordinate:coordinate geoEvent:geoEvent];
        
		[self.mapView addAnnotation:annotation];
        //annotation = nil;
	}
    }
}

- (void) removeAnnotations {
    [mapView removeAnnotations:[mapView annotations]];
    /*for (id <MKAnnotation>  myAnnot in [mapView annotations])
    {
        if (![myAnnot isKindOfClass:[MKUserLocation class]])
        {
            //[mapView removeAnnotation:myAnnot];
        }
        
    }*/
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
        MKPinAnnotationView *retval;
        MyAnnotationButton *myDetailButton;
    
        // Make sure we only create Pins for the Cameras. Ignore the current location annotation
        // so it returns the 'blue dot'
        if ([annotation isMemberOfClass:[MyLocation class]]) {
            // See if we can reduce, reuse, recycle
            retval = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            
            // If we have to, create a new view
            if (retval == nil) {
                retval = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            }else{
                retval.annotation = annotation;
            }
            
            if (retval) {
                [retval setPinColor:MKPinAnnotationColorGreen];
                retval.animatesDrop = NO;
                retval.canShowCallout = YES;
                
                //NSString *imName = @"";
                if([[annotation itemType] isEqualToString:TYPE_BIRTHDAY] || [[annotation itemType] isEqualToString:TYPE_BIRTHDAY_ES]){
                    [retval setPinColor:MKPinAnnotationColorGreen];
                    //imName = [NSString stringWithFormat:@"birthday_on"];
                    //UIImage *imageName =  [UIImage imageNamed:imName];
                    //retval.image = imageName;
                    _countBirthdays++;
                }
                if([[annotation itemType] isEqualToString:TYPE_DEATH] || [[annotation itemType] isEqualToString:TYPE_DEATH_ES]){
                    [retval setPinColor:MKPinAnnotationColorRed];
                    //imName = [NSString stringWithFormat:@"deaths_on"];
                    //UIImage *imageName =  [UIImage imageNamed:imName];
                    //retval.image = imageName;
                    _countDeaths++;
                }
                if([[annotation itemType] isEqualToString:TYPE_EVENT] || [[annotation itemType] isEqualToString:TYPE_EVENT_ES]){
                    [retval setPinColor:MKPinAnnotationColorPurple];
                    //imName = [NSString stringWithFormat:@"event_on"];
                    //UIImage *imageName =  [UIImage imageNamed:imName];
                    //retval.image = imageName;
                    _countHistoricEvents++;
                }
                
                urlSelected = [[annotation geoEvent] url];
                
                // Set up the Left callout
                myDetailButton = [MyAnnotationButton buttonWithType:UIButtonTypeCustom];
                [myDetailButton setImage:imgWikipedia forState:UIControlStateNormal];
                myDetailButton.frame = CGRectMake(0, 0, 23, 23);
                myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                
                myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                
                myDetailButton.urlToShow = [[[annotation geoEvent] url] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [myDetailButton addTarget:self action:@selector(wikipediaButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
                
                retval.leftCalloutAccessoryView = myDetailButton;
            }
        }
        
        return retval;
    }

- (void)wikipediaButtonTapped:(id)sender event:(id)event
{
//    MyAnnotationButton *buttonClicked = (MyAnnotationButton *)sender;

    NSError *error;
    NSURL* url = [NSURL URLWithString:[sender urlToShow]];
    BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey
                                   error: &error];

    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }
    
    //TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:url];
    _webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:url];
    _webBrowser.showURLStringOnActionSheetTitle = YES;
    _webBrowser.showPageTitleOnTitleBar = YES;
    _webBrowser.showActionButton = YES;
    _webBrowser.showReloadButton = YES;
    _webBrowser.mode = TSMiniWebBrowserModeModal;
    _webBrowser.barStyle = UIBarStyleBlack;

    if(_webBrowser.mode == TSMiniWebBrowserModeModal) {
        [self presentModalViewController:_webBrowser animated:YES];
    } else {
        [self.navigationController pushViewController:_webBrowser animated:YES];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!appDelegate){
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    if(!geocoder){
        geocoder = [[CLGeocoder alloc] init];
    }
    
    
    [monthPicker reloadInputViews];
    [monthPicker reloadAllComponents];
    
    imgBirthDayOn = [UIImage imageNamed:@"birthday_on"];
    imgBirthDayOff = [UIImage imageNamed:@"birthday_off"];
    
    imgDeathOn = [UIImage imageNamed:@"deaths_on"];
    imgDeathOff = [UIImage imageNamed:@"deaths_off"];
    
    imgEventOn = [UIImage imageNamed:@"event_on"];
    imgEventOff = [UIImage imageNamed:@"event_off"];
    
    imgWikipedia = [UIImage imageNamed:@"wikipedia_logo_button"];
    
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
    self.eventsSelectorView.layer.cornerRadius = 8.0;

    CGRect buttonMenuViewFrame = self.buttonFilterView.frame;
    buttonMenuViewFrame.origin.x = self.mapView.layer.frame.size.width - (self.buttonFilterView.frame.size.width - 5);
    buttonMenuViewFrame.size.width = 40;
    self.buttonFilterView.frame = buttonMenuViewFrame;
    self.buttonFilterView.layer.cornerRadius = 5.0;
 
    CGRect calendarViewFrame = self.monthPicker.frame;
    calendarViewFrame.origin.x -= self.monthPicker.frame.size.width;
    self.monthPicker.frame = calendarViewFrame;
    self.monthPicker.layer.cornerRadius = 8.0;
    
    CGRect buttonCalendarViewFrame = self.buttonCalendarView.frame;
    buttonCalendarViewFrame.origin.x = - 5;
    self.buttonCalendarView.frame = buttonCalendarViewFrame;
    self.buttonCalendarView.layer.cornerRadius = 5.0;
    
    arrayItems = [[NSMutableArray alloc] initWithCapacity:1];
    
    GeoEvent *geoEvent = [[GeoEvent alloc] initWithType:@"" longitude:@"" latitude:@"" country:@"" date:@"" description:@"" isCoupled:@"" generation:@"" language:@"" isCatched:@"" geoEventId:@""];
    
    [arrayItems addObject:geoEvent];
    
    arrayMonths = [[NSMutableArray alloc] initWithObjects:@"Enero",@"Febrero",@"Marzo",@"Abril",@"Mayo",
                   @"Junio",@"Julio",@"Agosto",@"Septiembre",@"Octubre",@"Noviembre",
                   @"Diciembre", nil];
    arrayDaysFebruary = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", nil];
    arrayDays30 = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", nil];
    arrayDays31 = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", nil];
    
    // Crear una vista del tamaño estándar en la parte inferior de la pantalla. GADBannerView
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
    
    // Especificar el "identificador de bloque" del anuncio. Se trata del ID de editor de AdMob.
    bannerView_.adUnitID = @"a150fbda1caeec3";
    
    // Hay que comunicar al módulo de tiempo de ejecución el UIViewController que debe restaurar después de llevar
    // al usuario donde vaya el anuncio y añadirlo a la jerarquía de vistas.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    // Iniciar una solicitud genérica para cargarla con un anuncio.
    [bannerView_ loadRequest:[GADRequest request]];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    //NSLog(@"Did Update Location = %f / %f", [newLocation coordinate].latitude, [newLocation coordinate].longitude);
    
    //NSLog(@"Current User Location = %f / %f", [[mapView userLocation] coordinate].latitude, [[mapView userLocation] coordinate].longitude);
    
    
    [geocoder reverseGeocodeLocation: newLocation completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSLog( @"ERROR?: %@", error.description );
         /*NSLog( @"placemark.ISOcountryCode: %@", placemark.ISOcountryCode );
         NSLog( @"placemark.country: %@", placemark.country );
         NSLog( @"placemark.postalCode: %@", placemark.postalCode);
         NSLog( @"placemark.administrativeArea: %@", placemark.administrativeArea);
         NSLog( @"placemark.subAdministrativeArea: %@", placemark.subAdministrativeArea);
         NSLog( @"placemark.locality: %@", placemark.locality);
         NSLog( @"placemark.subLocality: %@", placemark.subLocality);
         NSLog( @"placemark.thoroughfare: %@", placemark.thoroughfare);
         NSLog( @"placemark.subThoroughfare: %@", placemark.subThoroughfare);
         NSLog( @"placemark.region: %@", placemark.region);*/
         
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
}

- (IBAction) showCalendarFilterMenu:(id)sender{
    
    CGRect calendarViewFrame = self.monthPicker.frame;
    CGRect buttonCalendarViewFrame = self.buttonCalendarView.frame;
    
    buttonCalendarViewFrame.size.width = 40;
    calendarViewFrame.size.width = 230;
    
    if(buttonCalendarMenuSelected == FALSE){
        buttonCalendarMenuSelected = TRUE;
        calendarViewFrame.origin.x = -3;
        
        buttonCalendarViewFrame.origin.x = calendarViewFrame.size.width - 8;
        
    } else{
        [self removeAnnotations];
        [self getGeoEvents];
        if(buttonMenuSelected){
            [self showFilterMenu:0];
        }
        [self.birthdayButton setImage:imgBirthDayOn forState:UIControlStateNormal];
        shouldShowBirthdays = TRUE;
        [self.birthdayButton setSelected:FALSE];
        [self.deathButton setImage:imgDeathOn forState:UIControlStateNormal];
        shouldShowDeaths = TRUE;
        [self.deathButton setSelected:FALSE];
        [self.eventsButton setImage:imgEventOn forState:UIControlStateNormal];
        shouldShowEvents = TRUE;
        [self.eventsButton setSelected:FALSE];

        buttonCalendarMenuSelected = FALSE;
        calendarViewFrame.origin.x = -self.monthPicker.frame.size.width;
        buttonCalendarViewFrame.origin.x = -5;
        
        
    }
    self.calendarButton.enabled = FALSE;
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
}

- (IBAction) filterEventsByDate:(id)sender{

}

- (IBAction) filterEvents:(id)sender{
    
     int tag = [sender tag];

     
     switch (tag) {
         case 10:
             
             
             if([self.birthdayButton isSelected]){
                 [self.birthdayButton setImage:imgBirthDayOn forState:UIControlStateNormal];
                 shouldShowBirthdays = TRUE;
             } else{
                 [self.birthdayButton setImage:imgBirthDayOff forState:UIControlStateNormal];
                                  shouldShowBirthdays = FALSE;
             }
             if([userLocale isEqualToString:LOCALE_SPANISH]){
                 [self deleteEventType:TYPE_BIRTHDAY_ES];
             }else{
                 [self deleteEventType:TYPE_BIRTHDAY];
             }
             [self.birthdayButton setSelected:!self.birthdayButton.selected];
             
             break;
         case 12:
             
             if([self.eventsButton isSelected]){
                 [self.eventsButton setImage:imgEventOn forState:UIControlStateNormal];
                  shouldShowEvents = TRUE;
             } else{
                 [self.eventsButton setImage:imgEventOff forState:UIControlStateNormal];
                 shouldShowEvents = FALSE;
             }
             if([userLocale isEqualToString:LOCALE_SPANISH]){
                 [self deleteEventType:TYPE_EVENT_ES];
             }else{
                 [self deleteEventType:TYPE_EVENT];
             }
             
             [self.eventsButton setSelected:!self.eventsButton.selected];
             
             break;
         case 11:
             
             if([self.deathButton isSelected]){
                 [self.deathButton setImage:imgDeathOn forState:UIControlStateNormal];
                 shouldShowDeaths = TRUE;

             } else{
                 [self.deathButton setImage:imgDeathOff forState:UIControlStateNormal];
                 shouldShowDeaths = FALSE;
             }
             if([userLocale isEqualToString:LOCALE_SPANISH]){
                 [self deleteEventType:TYPE_DEATH_ES];
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
//    @autoreleasepool {
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
   // }
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    if(component == 1){
        return [arrayMonths count];
        } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Enero"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Marzo"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Mayo"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Julio"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Agosto"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Octubre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Diciembre"])) {
            
            arrayDays = arrayDays31;
            [pickerView reloadInputViews];
            return [arrayDays count];
    }
    else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Febrero"] )){
            
        arrayDays = arrayDaysFebruary;
        [pickerView reloadInputViews];
        return [arrayDays count];
  
    } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Abril"] ||[[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Junio"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Septiembre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Noviembre"])) {
       
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
        if ([month isEqual:@"Enero"]) {
            monthSelected = @"01";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Febrero"]) {
            monthSelected = @"02";
            arrayDays = arrayDaysFebruary;
        } else
        if ([month isEqual:@"Marzo"]) {
            monthSelected = @"03";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Abril"]) {
            monthSelected = @"04";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Mayo"]) {
            monthSelected = @"05";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Junio"]) {
            monthSelected = @"06";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Julio"]) {
            monthSelected = @"07";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Agosto"]) {
            monthSelected = @"08";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Septiembre"]) {
            monthSelected = @"09";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Octubre"]) {
            monthSelected = @"10";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Noviembre"]) {
            monthSelected = @"11";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Diciembre"]) {
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

        } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Enero"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Marzo"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Mayo"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Julio"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Agosto"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Octubre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Diciembre"])) {
       
            arrayDays = arrayDays31;
            if([monthPicker selectedRowInComponent:0] + 1 > arrayDays.count){
                daySelected = [arrayDays objectAtIndex:(arrayDays.count -  1)];
            } else {
                daySelected = [arrayDays objectAtIndex:row];
            }
            [pickerView reloadInputViews];

    } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Febrero"] )){
     
        arrayDays = arrayDaysFebruary;
        if([monthPicker selectedRowInComponent:0] + 1 > arrayDays.count){
            daySelected = [arrayDays objectAtIndex:(arrayDays.count -  1)];
        } else {
            daySelected = [arrayDays objectAtIndex:row];
        }
        [pickerView reloadInputViews];
    } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Abril"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Junio"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Septiembre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Noviembre"])) {
   
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
        if ([month isEqual:@"Enero"]) {
            monthSelected = @"01";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Febrero"]) {
            monthSelected = @"02";
            arrayDays = arrayDaysFebruary;
        } else
        if ([month isEqual:@"Marzo"]) {
            monthSelected = @"03";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Abril"]) {
            monthSelected = @"04";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Mayo"]) {
            monthSelected = @"05";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Junio"]) {
            monthSelected = @"06";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Julio"]) {
            monthSelected = @"07";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Agosto"]) {
            monthSelected = @"08";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Septiembre"]) {
            monthSelected = @"09";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Octubre"]) {
            monthSelected = @"10";
            arrayDays = arrayDays31;
        } else
        if ([month isEqual:@"Noviembre"]) {
            monthSelected = @"11";
            arrayDays = arrayDays30;
        } else
        if ([month isEqual:@"Diciembre"]) {
            monthSelected = @"12";
            arrayDays = arrayDays31;
        }
        
        [pickerView reloadInputViews];
        
        return [arrayMonths objectAtIndex:row];
        
    } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Enero"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Marzo"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Mayo"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Julio"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Agosto"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Octubre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Diciembre"])) {
       
        arrayDays = arrayDays31;

        [pickerView reloadInputViews];
        
        return [arrayDays objectAtIndex:row];
    } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Febrero"] )){
    
        arrayDays = arrayDaysFebruary;
        
        [pickerView reloadInputViews];

        return [arrayDays objectAtIndex:row];

      } else if ((component == 0) && ([[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Abril"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Junio"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Septiembre"] || [[arrayMonths objectAtIndex:[monthPicker selectedRowInComponent:1]] isEqual: @"Noviembre"])) {
      
        arrayDays = arrayDays30;

        [pickerView reloadInputViews];

        return [arrayDays objectAtIndex:row];
     }
    
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

- (void)didReceiveMemoryWarning
{
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Memory Warning"message:@"Memory Warning"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];*/
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.locationManager.delegate = nil;
    monthPicker.delegate = nil;

    imgDeathOff = nil;
    imgDeathOn = nil;
    imgEventOff = nil;
    imgEventOn = nil;
    imgBirthDayOff = nil;
    imgBirthDayOn = nil;
    
    mapView = nil;
    userLocation = nil;
    arrayItems = nil;
    eventsSelectorView = nil;
    
    _countBirthdays  = nil;
    _countDeaths = nil;
    _countHistoricEvents = nil;
    buttonFilterView = nil;
    buttonCalendarView = nil;
    datePicker = nil;
    monthPicker = nil;
    
    locationManager = nil;
    mapView = nil;
    
    appDelegate = nil;
    bannerView_ = nil;
    
    cityLocated = nil;
    connectionAlerted = nil;
    buttonMenuSelected = nil;
    buttonCalendarMenuSelected = nil;
    shouldShowDeaths = nil;
    shouldShowBirthdays = nil;
    shouldShowEvents = nil;
    calendarMustRefresh = nil;
    
    geocoder = nil;
    
    settings = nil;
    
    currentDate = nil;
    dateFormatter = nil;
    
    arrayDate = nil;
    
    arrayMonths = nil;
    arrayDays = nil;
    arrayDaysFebruary = nil;
    arrayDays30 = nil;
    arrayDays31 = nil;
    
    userCity = nil;
    userLocale = nil;
    urlSelected = nil;
    monthSelected = nil;
    daySelected = nil;
    dateSelected = nil;
    
    dayInteger = nil;
    monthInteger = nil;
    
    //[blablabla release];
}

@end
