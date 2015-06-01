//
//  LocationController.m
//  GeoEvents
//
//  Created by Jorge Jordán Arenas on 30/09/11.
//  Copyright 2011 Insane Platypus Games. All rights reserved.

#import <UIKit/UIKit.h>

@interface GeoEvent : NSObject {
	NSString *type;
	NSString *longitude;
	NSString *latitude;
	NSString *country;
	NSString *date;
	NSString *description;
    NSString *language;
    NSString *url;
}

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *language;
@property (nonatomic, retain) NSString *url;

-(id)initWithType:(NSString *)t longitude:(NSString *)longit latitude:(NSString *)latit country:(NSString *)c date:(NSString *)dat description:(NSString *)desc isCoupled:(NSString *)isCoup generation:(NSString *)gen language:(NSString *)lang isCatched:(NSString *)isCatch geoEventId:(NSString *)geoEvntId;

-(id)initWithType:(NSString *)t longitude:(NSString *)longit latitude:(NSString *)latit country:(NSString *)c date:(NSString *)dat description:(NSString *)desc language:(NSString *)lang url:(NSString *)u;


@end