//
//  CustomMapView.h
//  geoEvents
//
//  Created by Jorge Jordán Arenas on 16/08/13.
//  Copyright (c) 2013 Jorge Jordán Arenas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMCalloutView.h"

@interface CustomMapView : UIResponder<UIApplicationDelegate, SMCalloutViewDelegate>


// this tells the compiler that MKMapView actually implements this method
//- (BOOL)customGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

@end
