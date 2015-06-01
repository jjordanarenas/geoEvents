#import "GeoEvent.h"

@implementation GeoEvent
@synthesize type, longitude, latitude, country, date, description, language, url;

-(id)initWithType:(NSString *)t longitude:(NSString *)longit latitude:(NSString *)latit country:(NSString *)c date:(NSString *)dat{

	self.type = t;
	self.longitude = longit;
	self.latitude = latit;
	self.country = c;
	self.date = dat;
	return self;
}


-(id)initWithType:(NSString *)t longitude:(NSString *)longit latitude:(NSString *)latit country:(NSString *)c date:(NSString *)dat description:(NSString *)desc isCoupled:(NSString *)isCoup generation:(NSString *)gen language:(NSString *)lang isCatched:(NSString *)isCatch geoEventId:(NSString *)geoEvntId{
    
    self.type = t;
	self.longitude = longit;
	self.latitude = latit;
	self.country = c;
	self.date = dat;
    self.description = desc;
    self.language = lang;
    
    return self;
}


-(id)initWithType:(NSString *)t longitude:(NSString *)longit latitude:(NSString *)latit country:(NSString *)c date:(NSString *)dat description:(NSString *)desc language:(NSString *)lang url:(NSString *)u {
    
    self.type = t;
	self.longitude = longit;
	self.latitude = latit;
	self.country = c;
	self.date = dat;
    self.description = desc;
    self.language = lang;
    self.url = u;
    
    return self;
}



@end