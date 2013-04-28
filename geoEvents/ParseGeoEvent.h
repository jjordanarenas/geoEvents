//
//  ParseAnimal.h
//  GoldRush
//
//  Created by Jorge Jordán Arenas on 04/11/11.
//  Copyright (c) 2011 InsanePlatypusGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeoEvent.h"

@interface ParseGeoEvent : NSObject{
    
    NSXMLParser   *revParser; 
	
	GeoEvent *geoEventRet;
	
	NSMutableString *currentElement;
    
    NSMutableArray *arrayGeoEvents;
}

-(NSMutableArray*)parseGeoEvent:(NSString *)xml;

@end
