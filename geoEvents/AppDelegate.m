//
//  AppDelegate.m
//  geoEvents
//
//  Created by Jorge Jordán Arenas on 17/08/12.
//  Copyright (c) 2012 Jorge Jordán Arenas. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MyLocation.h"
#import "GeoEvent.h"

@implementation AppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    /*// Create an instance of a UINavigationController
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    // Place navigation controller's view in the window hierarchy
    self.window.rootViewController = navController;
    */
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.window.rootViewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        self.window.rootViewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    
    int cacheSizeMemory = 4*1024*1024; // 4MB
    int cacheSizeDisk = 32*1024*1024; // 32MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
 
    [NSURLCache setSharedURLCache:sharedCache];
    
    // Setup some globals
	NSString *databaseName = @"GeoEventDB.sql";
	
	// Get the path to the caches directory and append the databaseName
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
	NSString *documentsDir = [documentPaths objectAtIndex:0];
    
	databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	

    
    NSError *error;
    NSURL* url = [NSURL fileURLWithPath:databasePath];
    BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey
                                   error: &error];
    
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    } else{
        NSLog(@"Success excluding %@ from backing up", databasePath);
    }
    
	// Execute the "checkAndCreateDatabase" function
	[self checkAndCreateDatabase];
 
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
    sleep(2);
    
  	// Configure and show the window
	[window addSubview:[viewController view]];
	[window makeKeyAndVisible];
}

-(void) checkAndCreateDatabase{
	// Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL success;
	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:databasePath];
	
	// If the database already exists then return without doing anything
	if(success) return;
	
	// If not then proceed to copy the database from the application to the users filesystem
	
    NSString *databaseName = @"GeoEventDB.sql";
    
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
	// Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	
    //	[fileManager release];
}

-(NSMutableArray*) readGeoEventsFromDatabaseFromDate:(NSString *) date language:(NSString *)lang{
	// Setup the database object
	sqlite3 *database;
	
	// Init the array
	
    NSMutableArray *geoEvents = [[NSMutableArray alloc] init];
    [geoEvents removeAllObjects];
    
    GeoEvent *geoEvent;
    
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        NSString *sqlStatementConcat = [NSString stringWithFormat:@"select distinct type, longitude, latitude, country, language, description, date, url from geoEvents where date like '%%%@%%' and language like '%%%@%%'", date, lang];
        
		const char *sqlStatement = [sqlStatementConcat UTF8String];
		sqlite3_stmt *compiledStatement;
        NSLog(@"query: %@ ", sqlStatementConcat);

        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSString *aType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				NSString *aLongitude = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
				NSString *aLatitude = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
				NSString *aCountry = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
				NSString *aLanguage = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
				NSString *aDescription = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
				NSString *aDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
                NSString *aURL = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
                
                geoEvent = [[GeoEvent alloc] initWithType:aType longitude:aLongitude latitude:aLatitude country:aCountry date:aDate description:aDescription language:aLanguage url:aURL];
                
               // Add the geoEvent object to the animals Array
				[geoEvents addObject:geoEvent];				
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	int rc = sqlite3_close(database);
	
    if (rc != SQLITE_OK)
    {
        NSLog(@"close not OK.  rc=%d", rc);
    }
    
    return geoEvents;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)dealloc {
}

@end




