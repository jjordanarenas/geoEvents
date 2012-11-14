//
//  AppDelegate.m
//  geoEvents
//
//  Created by Jorge Jordán Arenas on 17/08/12.
//  Copyright (c) 2012 Jorge Jordán Arenas. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "GeoEvent.h"

@implementation AppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    
    // Setup some globals
	databaseName = @"GeoEventDB.sql";
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];

	databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	
	// Execute the "checkAndCreateDatabase" function
	[self checkAndCreateDatabase];
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
    sleep(2);
    
    
    // Setup some globals
	databaseName = @"GeoEventDB.sql";
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	NSString *documentsDir = [documentPaths objectAtIndex:0];

	databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	
	// Execute the "checkAndCreateDatabase" function
	[self checkAndCreateDatabase];
	
	// Query the database for all animal records and construct the "animals" array
	//[self readAnimalsFromDatabase];
	
    
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
	
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
	// Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	
    //	[fileManager release];
}

-(NSMutableArray*) readGeoEventsFromDatabase {
	// Setup the database object
	sqlite3 *database;
	
	// Init the animals Array
	geoEvents = [[NSMutableArray alloc] init];
    
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
		const char *sqlStatement = "select * from geoEvents";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSString *aGeoEventId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				NSString *aType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
				NSString *aLongitude = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
				NSString *aLatitude = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
				NSString *aCountry = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
				NSString *aDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
				NSString *aDescription = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
				NSString *aIsCatched = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
                NSString *aLanguage = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
				NSString *aIsCoupled = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)];
				NSString *aGeneration = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)];
                
				GeoEvent *geoEvent = [[GeoEvent alloc] initWithType:aType longitude:aLongitude latitude:aLatitude country:aCountry date:aDate description:aDescription isCoupled:aIsCoupled generation:aGeneration language:aLanguage isCatched:aIsCatched geoEventId:aGeoEventId];
                
                
				// Add the geoEvent object to the animals Array
				[geoEvents addObject:geoEvent];
				
				////////////[geoEvent release];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	sqlite3_close(database);
	
    return geoEvents;
}

-(NSMutableArray*) readGeoEventsFromDatabaseFromDate:(NSString *) date language:(NSString *)lang{
	// Setup the database object
	sqlite3 *database;
	
	// Init the animals Array
	geoEvents = [[NSMutableArray alloc] init];
    
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        NSString *sqlStatementConcat = [NSString stringWithFormat:@"select type, longitude, latitude, country, language, description, date, url from geoEvents where date like '%%%@%%' and language like '%%%@%%'", date, lang];
		const char *sqlStatement = [sqlStatementConcat UTF8String];
		sqlite3_stmt *compiledStatement;
        NSLog(@"databasePath: %@ ", sqlStatementConcat);

        
		//const char *sqlStatement = "select * from geoEvents where";
		//sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                //NSString *aGeoEventId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				NSString *aType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				NSString *aLongitude = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
				NSString *aLatitude = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
				NSString *aCountry = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
				NSString *aLanguage = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
				NSString *aDescription = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
				//NSString *aIsCatched = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
                NSString *aDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
                NSString *aURL = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
                
				//NSString *aIsCoupled = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)];
				//NSString *aGeneration = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)];
             
                
                
				//GeoEvent *geoEvent = [[GeoEvent alloc] initWithType:aType longitude:aLongitude latitude:aLatitude country:aCountry date:aDate description:aDescription isCoupled:aIsCoupled generation:aGeneration language:aLanguage isCatched:aIsCatched geoEventId:aGeoEventId];
                GeoEvent *geoEvent = [[GeoEvent alloc] initWithType:aType longitude:aLongitude latitude:aLatitude country:aCountry date:aDate description:aDescription language:aLanguage url:aURL];
                
               // -(id)initWithType:(NSString *)t longitude:(NSString *)longit latitude:(NSString *)latit country:(NSString *)c date:(NSString *)dat description:(NSString *)desc language:(NSString *)lang{

				// Add the geoEvent object to the animals Array
				[geoEvents addObject:geoEvent];
				
				////////////[geoEvent release];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	sqlite3_close(database);
	
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
	////////[geoEvents release];
    ///////[viewController release];
    /////////[window release];
    
  ////////  [super dealloc];
}

@end
