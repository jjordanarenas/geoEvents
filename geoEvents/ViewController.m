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

@interface ViewController ()

@end

@implementation ViewController
@synthesize mapView;
@synthesize eventsSelectorView;
@synthesize userLocation;
@synthesize arrayItems;
@synthesize locationManager;

BOOL cityLocated = FALSE;
NSUserDefaults *settings;
//double METERSPERMILE_ZOOMIN = 0.5;
//double METERSPERMILE_ZOOMOUT = 3.7;
double METERSPERMILE_ZOOMIN = 5000;
double METERSPERMILE_ZOOMOUT = 370000;
NSString *userCity =@"";
NSString *userLocale =@"";
NSString *urlSelected =@"";
static NSString *const MODE = @"DEMO";  //@"PROD"
BOOL connectionAlerted = FALSE;
CLGeocoder *geocoder;
AppDelegate *appDelegate;
static NSString *const TYPE_BIRTHDAY = @"BIRTHDAY";
static NSString *const TYPE_DEATH = @"DEATH";
static NSString *const TYPE_EVENT = @"EVENT";
static NSString *const TYPE_BIRTHDAY_ES = @"NACIMIENTO";
static NSString *const TYPE_DEATH_ES = @"FALLECIMIENTO";
static NSString *const TYPE_EVENT_ES = @"EVENTO HISTÓRICO";
static NSString *const LOCALE_ENGLISH = @"en";
static NSString *const LOCALE_SPANISH = @"es";
BOOL buttonMenuSelected = FALSE;

-(void) locateUser{
	CLLocationCoordinate2D zoomLocation;
	zoomLocation.latitude = userLocation.coordinate.latitude;
	zoomLocation.longitude = userLocation.coordinate.longitude;
	
	MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, METERSPERMILE_ZOOMIN*METERS_PER_MILE, METERSPERMILE_ZOOMIN*METERS_PER_MILE);
	
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
	
    [self.mapView setRegion:adjustedRegion animated:YES];
    //self.mapView.showsUserLocation = NO;
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    if (!appDelegate){
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
     NSLog(@"the model itself contains %@", arrayItems); //<Unit: 0x6bc6150>
   // if(arrayItems){
        arrayItems = [[NSMutableArray alloc] initWithCapacity:10];
    //}
            GeoEvent *geoEvent = [[GeoEvent alloc] initWithType:@"" longitude:@"" latitude:@"" country:@"" date:@"" description:@"" isCoupled:@"" generation:@"" language:@"" isCatched:@"" geoEventId:@""];
    [arrayItems addObject:geoEvent];
     NSLog(@"the model itself contains %@", arrayItems); //<Unit: 0x6bc6150>
    if(!geocoder){
        geocoder = [[CLGeocoder alloc] init];
    }
  //  mapView = [[MKMapView alloc]init];

    settings = [NSUserDefaults standardUserDefaults];
    
    ////////  [viewLoadingData setHidden:NO];
        NSLocale *locale = [NSLocale currentLocale];
        NSString *currentLocale = [locale displayNameForKey:NSLocaleIdentifier
                                                      value:[locale localeIdentifier]];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];

        NSLog( @"Complete locale: %@", currentLocale );
     NSLog( @"Complete language: %@", language );
    userLocale = language;
   // mapView.delegate = self;
    
        if(cityLocated==FALSE){
            
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            //self.locationManager.purpose = NSLocalizedString(@"We use location to put you in the map", @"");

            //  self.locationManager.distanceFilter = 50;
            [self.locationManager startUpdatingLocation];
            
        }
    
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)currentLocation{
	
    //[self.locationManager stopUpdatingLocation];
    
    //NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    if(cityLocated==FALSE){
        userLocation = currentLocation;
        NSLog(@"*** Current User Location: %@ ", userLocation.location);
        
        NSLog(@"*** HORIZONTAL ACCURACY: %f ", userLocation.location.horizontalAccuracy);
        
       /* if(userLocation.location.horizontalAccuracy > 100.0 && !accuracyAlerted){
            
            
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Accuracy Warning" message:@"The accuracy of your location is low, this could cause problems on the search" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [alert show];
            accuracyAlerted = TRUE;
        }*/
        
        /*MKReverseGeocoder *geocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:currentLocation.coordinate] autorelease];
         geocoder.delegate = self;
         [geocoder start];*/
		
        if(self.mapView.annotations.count <= 1){
            CLLocationCoordinate2D zoomLocation;
            zoomLocation.latitude = userLocation.coordinate.latitude;
            zoomLocation.longitude = userLocation.coordinate.longitude;
            
            //  if(userCity == @"" && cityLocated==FALSE){
            /*      if( ![userCity isEqualToString:@""]){
             [self createAnimalForStep1];
             }*/
            [self locateUser];
        }
	}
    
}

-(void) getGeoEvents {
    

     //arrayItems = [appDelegate readGeoEventsFromDatabase];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateStyle:NSDateFormatterNoStyle];
    //[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd\/MM"];
    //NSString* currentTime = [dateFormatter stringFromDate:[NSDate date]];
    NSString* currentTime = @"12/10";
    NSLog(@"currentTime %@", currentTime); //<Unit: 0x6bc6150>
    arrayItems = [appDelegate readGeoEventsFromDatabaseFromDate:currentTime language:userLocale];
    
     NSLog(@"the model itself contains %@", arrayItems); //<Unit: 0x6bc6150>
    
    /////[arrayItems addObject:geoEvent];
    NSLog(@"the model itself contains %@", arrayItems); //<Unit: 0x6bc6150>
 NSLog(@"mapView %@", mapView); //<Unit: 0x6bc6150>
  //  [mapView showsUserLocation];
    //    [mapView setHidden:NO];
        [self plotGeoEventPositionsFromArray];
    //[self.view addSubview:mapView];
}

- (void)plotGeoEventPositionsFromArray{
    
	
    
     NSLog(@"arrayItems.count %d", arrayItems.count); //<Unit: 0x6bc6150>
	for(int i = 0; i < arrayItems.count; i++){
        GeoEvent *geoEvent = (GeoEvent *)[arrayItems objectAtIndex:i];
    
        NSString *address = [geoEvent description];
        NSString *itemType = [geoEvent type];
        NSString *image = @"";
        
        
		CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[geoEvent latitude] doubleValue];
        coordinate.longitude = [[geoEvent longitude] doubleValue];
        
        static NSString *const TYPE_BIRTHDAY = @"BIRTHDAY";
        static NSString *const TYPE_DEATH = @"DEATH";
        static NSString *const TYPE_EVENT = @"EVENT";
        
        if([itemType isEqualToString:TYPE_BIRTHDAY]){
            itemType = TYPE_BIRTHDAY_ES;
        }
        
        if([itemType isEqualToString:TYPE_DEATH]){
            itemType = TYPE_DEATH_ES;
        }
        
        if([itemType isEqualToString:TYPE_EVENT]){
            itemType = TYPE_EVENT_ES;
        }
        
		//itemType = geoEvent.type;
        
		//image = geoEvent.image;
        
        //NSLog(@"EVENT TYPE %@", itemType);
		MyLocation *annotation = [[MyLocation alloc] initWithName:itemType address:address itemType:itemType image:image coordinate:coordinate geoEvent:geoEvent];
		[self.mapView addAnnotation:annotation];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation {
	static NSString *identifier = @"MyLocation";
        
    /*    if ([annotation isKindOfClass:[MyLocation class]]) {
            
            MKAnnotationView *annotationView = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            
            if (annotationView == nil) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            } else {
                
                annotationView.annotation = annotation;
            }
            
            // NSLog(@"ANNOTATION_VIEW%@", annotationView.annotation);
            
            //NSLog(@"ANNOTATION TYPE %@ ", [annotation itemType]);
            
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            //annotationView.image = imageOrange;
            annotationView.hidden = NO;
           // NSString *imName = [annotation image];
             NSString *imName = [NSString stringWithFormat:@"%@%@", [annotation itemType], @".png"];
            UIImage *imageName =  [UIImage imageNamed:imName];
            NSLog(@"imageName %@ ", imName);
            
            annotationView.image = imageName;
           // NSLog(@"imageName %@ ", annotationView);
            
            return annotationView;
        }
		*/
   /* }else {
     */   
        MKPinAnnotationView *retval = nil;
        
        // Make sure we only create Pins for the Cameras. Ignore the current location annotation
        // so it returns the 'blue dot'
        if ([annotation isMemberOfClass:[MyLocation class]]) {
            // See if we can reduce, reuse, recycle
            (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            
            // If we have to, create a new view
            if (retval == nil) {
                retval = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
                
                // Set the button as the callout view
                //retval.leftCalloutAccessoryView = myDetailButton;
                //retval.animatesDrop = YES;
                //retval.canShowCallout = YES;
                
                //[retval setPinColor:MKPinAnnotationColorGreen];
            }
            
            // Set a bunch of other stuff
            if (retval) {
                [retval setPinColor:MKPinAnnotationColorGreen];
                retval.animatesDrop = NO;
                retval.canShowCallout = YES;
                if([[annotation itemType] isEqualToString:TYPE_BIRTHDAY] || [[annotation itemType] isEqualToString:TYPE_BIRTHDAY_ES]){
                    [retval setPinColor:MKPinAnnotationColorGreen];
                }
                if([[annotation itemType] isEqualToString:TYPE_DEATH] || [[annotation itemType] isEqualToString:TYPE_DEATH_ES]){
                    [retval setPinColor:MKPinAnnotationColorPurple];
                }
                if([[annotation itemType] isEqualToString:TYPE_EVENT] || [[annotation itemType] isEqualToString:TYPE_EVENT_ES]){
                    [retval setPinColor:MKPinAnnotationColorRed];
                }
                
                //url = [annotation url];
                urlSelected = [[annotation geoEvent] url];
                
                // Set up the Left callout
                MyAnnotationButton *myDetailButton = [MyAnnotationButton buttonWithType:UIButtonTypeCustom];
                [myDetailButton setImage:[UIImage imageNamed:@"WAR.png"] forState:UIControlStateNormal];
                myDetailButton.frame = CGRectMake(0, 0, 23, 23);
                myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                
                myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                myDetailButton.urlToShow = [[annotation geoEvent] url];
                [myDetailButton addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
                
                
                retval.leftCalloutAccessoryView = myDetailButton;
                
                
                
            }
        }
        
        
        return retval;
    }
    
	
  /////  return nil;
////}
/*
- (void) showUrl:(id)sender urlButton:(NSString *) urlButton{
    TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:urlButton]];
    webBrowser.showURLStringOnActionSheetTitle = YES;
    webBrowser.showPageTitleOnTitleBar = YES;
    webBrowser.showActionButton = YES;
    webBrowser.showReloadButton = YES;
    webBrowser.mode = TSMiniWebBrowserModeModal;
    webBrowser.barStyle = UIBarStyleBlack;
    
    NSLog(@"URL %@", urlButton);
    
    if(webBrowser.mode == TSMiniWebBrowserModeModal) {
        [self presentModalViewController:webBrowser animated:YES];
    } else {
        [self.navigationController pushViewController:webBrowser animated:YES];
        // [self.navigationController presentViewController:webBrowser animated:YES completion:];
    }
}*/

- (void)checkButtonTapped:(id)sender event:(id)event
{
    MyAnnotationButton *buttonClicked = (MyAnnotationButton *)sender;

    TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:[sender urlToShow]]];
    //TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:urlSelected]];
    webBrowser.showURLStringOnActionSheetTitle = YES;
    webBrowser.showPageTitleOnTitleBar = YES;
    webBrowser.showActionButton = YES;
    webBrowser.showReloadButton = YES;
    webBrowser.mode = TSMiniWebBrowserModeModal;
    webBrowser.barStyle = UIBarStyleBlack;

     //NSLog(@"URL %@", urlSelected);
    NSLog(@"URL %@", [sender urlToShow]);
    
    if(webBrowser.mode == TSMiniWebBrowserModeModal) {
        [self presentModalViewController:webBrowser animated:YES];
    } else {
        [self.navigationController pushViewController:webBrowser animated:YES];
       // [self.navigationController presentViewController:webBrowser animated:YES completion:];
    }
   /* NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil)
    {
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }*/
}

- (void)viewDidLoad
{
    [super viewDidLoad]; 
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    NSLog(@"Did Update Location = %f / %f", [newLocation coordinate].latitude, [newLocation coordinate].longitude);
    
    NSLog(@"Current User Location = %f / %f", [[mapView userLocation] coordinate].latitude, [[mapView userLocation] coordinate].longitude);
    
    
    [geocoder reverseGeocodeLocation: newLocation completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSLog( @"ERROR?: %@", error.description );
         NSLog( @"placemark.ISOcountryCode: %@", placemark.ISOcountryCode );
         NSLog( @"placemark.country: %@", placemark.country );
         NSLog( @"placemark.postalCode: %@", placemark.postalCode);
         NSLog( @"placemark.administrativeArea: %@", placemark.administrativeArea);
         NSLog( @"placemark.subAdministrativeArea: %@", placemark.subAdministrativeArea);
         NSLog( @"placemark.locality: %@", placemark.locality);
         NSLog( @"placemark.subLocality: %@", placemark.subLocality);
         NSLog( @"placemark.thoroughfare: %@", placemark.thoroughfare);
         NSLog( @"placemark.subThoroughfare: %@", placemark.subThoroughfare);
         NSLog( @"placemark.region: %@", placemark.region);
         
         userCity = placemark.locality;
         [self getGeoEvents];
         [self.locationManager stopUpdatingLocation];
     }];
    
}

- (IBAction) showFilterMenu:(id)sender{
    
    CGRect scrollViewFrame = eventsSelectorView.frame;
    if(buttonMenuSelected == FALSE){
        buttonMenuSelected = TRUE;
        scrollViewFrame.origin.x = 50;
    } else{
        buttonMenuSelected = FALSE;
        scrollViewFrame.origin.x = 680;
    }

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         eventsSelectorView.frame = scrollViewFrame;
                     }
                     completion:^(BOOL finished){
                     }];
    [UIView commitAnimations];
}

- (IBAction) filterEvents:(id)sender{
    
     int tag = [sender tag];

     
     switch (tag) {
         case 10:
             if([userLocale isEqualToString:LOCALE_SPANISH]){
                 [self deleteEventType:TYPE_BIRTHDAY_ES];
             }else{
                 [self deleteEventType:TYPE_BIRTHDAY];
             }
             break;
         case 11:
             if([userLocale isEqualToString:LOCALE_SPANISH]){
                 [self deleteEventType:TYPE_EVENT_ES];
             }else{
                 [self deleteEventType:TYPE_EVENT];
             }
             break;
         case 12:
             [self deleteEventType:@"SAINT"];
             break;
         case 13:
             [self deleteEventType:@"WAR"];
             break;
         case 14:
             if([userLocale isEqualToString:LOCALE_SPANISH]){
                 [self deleteEventType:TYPE_DEATH_ES];
             }else{
                 [self deleteEventType:TYPE_DEATH];
             }
             break;
         case 15:
             [self deleteEventType:@"SPORTS"];
             break;
         case 16:
             [self deleteEventType:@"BIRTHDAY"];
             break;
         case 17:
             [self deleteEventType:@"FILM"];
             break;
         case 18:
             [self deleteEventType:@"SAINT"];
             break;
         case 19:
             [self deleteEventType:@"DEATH"];
             break;
         case 20:
             [self deleteEventType:@"SPORTS"];
             break;
         case 21:
             [self deleteEventType:@"LITERATURA"];
             break;
         default:
             break;
     }
    
}

- (void)deleteEventType:(NSString *)eventType {
    MyLocation *nextAnnotation;
    NSLog(@"COUNT %d ", [[mapView annotations] count]);
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
                    [[mapView viewForAnnotation:nextAnnotation]  setHidden:YES];
                    [[mapView viewForAnnotation:nextAnnotation]  setEnabled:NO];

            }

		}
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
