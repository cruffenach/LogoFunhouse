//
//  SFSimpleLogoAnimationView.h
//  Simple
//
//  Created by Collin Ruffenach on 4/23/14.
//  Copyright (c) 2014 Simple Finance Corporation. All rights reserved.
//s

#import <Accelerate/Accelerate.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SFLogoPathOptions : NSObject
+ (instancetype)simpleLogoPathOptions;
- (instancetype)initWithIterations:(NSNumber*)iterations
                         amplitude:(NSNumber*)amplitude
                        resolution:(NSNumber*)resolution
                         frequency:(NSNumber*)frequency;
- (void)setColor:(UIColor*)lineColor;
- (void)setIterationColors:(NSArray*)iterationColors;
- (UIColor*)colorForIteration:(NSUInteger)iterationNumber;
@end

@interface SFLogoView : UIView
@end

@interface SFSimpleLogoAnimationView : UIView

@property (nonatomic, assign) float iterations;
@property (nonatomic, assign) float amplitude;
@property (nonatomic, assign) float resolution;
@property (nonatomic, assign) float frequency;
@property (nonatomic, assign) CGFloat tailLength;
@property (nonatomic, strong) NSArray *colors;

- (void)setDuration:(NSTimeInterval)duration;
- (void)setRandomizeDuration:(BOOL)randomizeDuration;

- (void)startAnimating;
- (void)stopAnimating;

@end