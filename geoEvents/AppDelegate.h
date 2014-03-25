//
//  AppDelegate.h
//  geoEvents
//
//  Created by Jorge Jordán Arenas on 17/08/12.
//  Copyright (c) 2012 Jorge Jordán Arenas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h> 
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "MyLocation.h"
#import "SMCalloutView.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, SMCalloutViewDelegate>{
    // Database variables
	NSString *databasePath;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) ViewController *viewController;
@property (nonatomic, strong) NSMutableArray *geoEvents;

-(NSMutableArray*) readGeoEventsFromDatabaseFromDate:(NSString *) date language:(NSString *)lang;

@end



