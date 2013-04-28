//
//  AppDelegate.h
//  geoEvents
//
//  Created by Jorge Jordán Arenas on 17/08/12.
//  Copyright (c) 2012 Jorge Jordán Arenas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h> 

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    // Database variables
	NSString *databaseName;
	NSString *databasePath;
    // Array to store the animal objects
	NSMutableArray *geoEvents;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) ViewController *viewController;
//@property (nonatomic, retain) NSMutableArray *geoEvents;
@property (nonatomic, strong) NSMutableArray *geoEvents;

-(NSMutableArray*) readGeoEventsFromDatabase;
-(NSMutableArray*) readGeoEventsFromDatabaseFromDate:(NSString *) date language:(NSString *)lang;

@end
