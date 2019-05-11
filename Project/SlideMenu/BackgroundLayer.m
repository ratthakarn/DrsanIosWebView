//
//  BackgroundLayer.m
//
//  Copyright (c) 2018 Sherdle. All rights reserved.
//

#import "BackgroundLayer.h"
#import "AppDelegate.h"

@implementation BackgroundLayer

//Blue gradient background
+ (CAGradientLayer*) colorGradient {
    UIColor *colorOne = GRADIENT_ONE;
    UIColor *colorTwo = GRADIENT_TWO;
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
	headerLayer.colors = colors;
	headerLayer.locations = locations;
	
	return headerLayer;
                       
}

@end
