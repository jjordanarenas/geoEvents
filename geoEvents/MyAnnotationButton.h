//
//  MyAnnotationButton.h
//  geoEvents
//
//  Created by Jorge Jordán Arenas on 13/10/12.
//  Copyright (c) 2012 Jorge Jordán Arenas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAnnotationButton : UIButton {
    NSString *urlToShow;
    NSString *eventDescription;
}

@property (nonatomic, retain) NSString *urlToShow;
@property (nonatomic, retain) NSString *eventDescription;
@property (nonatomic, retain) NSString *eventType;

@end
