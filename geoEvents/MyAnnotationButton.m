//
//  MyAnnotationButton.m
//  geoEvents
//
//  Created by Jorge Jordán Arenas on 13/10/12.
//  Copyright (c) 2012 Jorge Jordán Arenas. All rights reserved.
//

#import "MyAnnotationButton.h"

@implementation MyAnnotationButton

@synthesize urlToShow = urlToShow;
@synthesize eventDescription = eventDescription;
@synthesize eventType = eventType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (NSString *)urlToShow {
    return urlToShow;
}

- (NSString *)eventDescription {
    return eventDescription;
}

- (NSString *)eventType {
    return eventType;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
