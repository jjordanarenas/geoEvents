//
//  MyLocation.h
//  geoEvents
//
//  Created by Jorge Jordán Arenas on 17/08/12.
//  Copyright (c) 2012 Jorge Jordán Arenas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GeoEvent.h"

@interface MyLocation : NSObject <MKAnnotation> {
    NSString *_name;
    NSString *_address;
	NSString *_itemType;
	NSString *_image;
	GeoEvent *_geoEvent;
    CLLocationCoordinate2D _coordinate;
}

@property (copy) NSString *name;
@property (copy) NSString *address;
@property (copy) NSString *itemType;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) GeoEvent *geoEvent;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithName:(NSString*)name address:(NSString*)address itemType:(NSString*)itemType image:(NSString*)image coordinate:(CLLocationCoordinate2D)coordinate geoEvent:(GeoEvent*)geoEvent;


@end
