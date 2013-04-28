//
//  MyLocation.m
//  geoEvents
//
//  Created by Jorge Jordán Arenas on 22/08/12.
//  Copyright (c) 2012 Jorge Jordán Arenas. All rights reserved.
//

#import "MyLocation.h"

@implementation MyLocation

@synthesize name = _name;
@synthesize address = _address;
@synthesize itemType = _itemType;
@synthesize image = _image;
@synthesize coordinate = _coordinate;

- (id)initWithName:(NSString*)name address:(NSString*)address itemType:(NSString*)itemType image:(NSString*)image coordinate:(CLLocationCoordinate2D)coordinate geoEvent:(GeoEvent*)geoEvent{
    if ((self = [super init])) {
        _name = [name copy];
        _address = [address copy];
		_itemType = [itemType copy];
		_image = [image copy];
        _coordinate = coordinate;
        _geoEvent = geoEvent;
    }
    return self;
}

- (NSString *)title {
    return _name;
}

- (NSString *)subtitle {
    return _address;
}

- (NSString *)image {
    return _image;
}

- (GeoEvent *)geoEvent {
    return _geoEvent;
}

- (void)dealloc
{
    _name = nil;
    _address = nil;
    _itemType = nil;
    _image = nil;
    _geoEvent = nil;
}

@end