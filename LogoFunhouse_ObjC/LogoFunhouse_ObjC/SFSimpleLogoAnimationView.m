//
//  SFSimpleLogoAnimationView.m
//  Simple
//
//  Created by Collin Ruffenach on 4/23/14.
//  Copyright (c) 2014 Simple Finance Corporation. All rights reserved.
//

#import "SFSimpleLogoAnimationView.h"

@interface SFLogoPathOptions ()
@property (nonatomic, assign) NSNumber *iterations;
@property (nonatomic, assign) NSNumber *amplitude;
@property (nonatomic, assign) NSNumber *resolution;
@property (nonatomic, assign) NSNumber *frequency;
@property (nonatomic, strong) NSArray *iterationColors;
@end

static const NSInteger kSFSimpleLogoIterations = 5.0;
static const CGFloat kSFSimpleLogoAmplitude = 0.2;
static const NSInteger kSFSimpleLogoResolution = 200.0;
static const CGFloat kSFSimpleLogoFrequency = 2.0;

NSArray * SFLogoPathDefaultColors() {
    UIColor *brownColor = [UIColor colorWithRed:(216.0/255.0)
                                          green:(112.0/255.0)
                                           blue:(95.0/255.0)
                                          alpha:1];
    UIColor *blueColor = [UIColor colorWithRed:(60.0/255.0)
                                         green:(124.0/255.0)
                                          blue:(132.0/255.0)
                                         alpha:0.7];
    return @[brownColor,
             blueColor,
             brownColor,
             blueColor,
             blueColor];
}

@implementation SFLogoPathOptions

+ (instancetype)simpleLogoPathOptions {
    SFLogoPathOptions *defaultOptions = [[SFLogoPathOptions alloc] initWithIterations:@(kSFSimpleLogoIterations)
                                                                            amplitude:@(kSFSimpleLogoAmplitude)
                                                                           resolution:@(kSFSimpleLogoResolution)
                                                                            frequency:@(kSFSimpleLogoFrequency)];
    [defaultOptions setIterationColors:SFLogoPathDefaultColors()];
    return defaultOptions;
}

- (instancetype)initWithIterations:(NSNumber*)iterations
                         amplitude:(NSNumber*)amplitude
                        resolution:(NSNumber*)resolution
                         frequency:(NSNumber*)frequency {
    
    self = [super init];
    if (self) {
        self.iterations = iterations;
        self.amplitude = amplitude;
        self.resolution = resolution;
        self.frequency = frequency;
    }
    return self;
}

- (void)dealloc {
    self.iterations = nil;
    self.amplitude = nil;
    self.resolution = nil;
    self.frequency = nil;
    self.iterationColors = nil;
}

#pragma mark - Overrides

- (void)setColor:(UIColor*)lineColor {
    self.iterationColors = @[lineColor];
    
}

- (void)setIterationColors:(NSArray*)iterationColors {
    if (iterationColors.count != _iterations.unsignedIntegerValue) {
        NSLog(@"[SFLogoPathOptions] : WARNING called setIterationColors: with colors: %@ on options with %@ iterations. The number of colors should match the number of iterations", iterationColors, _iterations);
    }
    self.iterationColors = iterationColors;
}

- (UIColor*)colorForIteration:(NSUInteger)iterationNumber {
    return !(_iterationColors || !_iterationColors.lastObject) ? [UIColor blackColor] :
    iterationNumber < _iterationColors.count ? _iterationColors[iterationNumber] :
    _iterationColors.lastObject;
}

@end

@interface SFSimpleLogoLineView : UIView
- (void)setPath:(UIBezierPath*)path;
@property (nonatomic, assign) UIColor *color;
@property (nonatomic, assign) CGFloat initialOffset;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGFloat strokeLength;
@property (nonatomic, assign) CGFloat strokeLocation;
@property (nonatomic, assign) BOOL showTrack;
@end

@interface SFSimpleLogoLineView ()
@property (nonatomic, assign) NSTimeInterval start;
@property (nonatomic, retain) CADisplayLink *displayLink;
@property (nonatomic, retain) CAShapeLayer *trackLayer;
@property (nonatomic, retain) CAShapeLayer *layer1;
@property (nonatomic, retain) CAShapeLayer *layer2;
@end

@implementation SFSimpleLogoLineView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CAShapeLayer * (^CAShapeLayerBuilderBlock)(void) = ^CAShapeLayer*(void){
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.lineWidth = 5.0;
            layer.backgroundColor = [UIColor clearColor].CGColor;
            layer.fillColor = [UIColor clearColor].CGColor;
            layer.strokeColor = [UIColor grayColor].CGColor;
            layer.strokeStart = 0.0;
            layer.strokeEnd = layer.strokeStart;
            layer.lineCap = kCALineCapRound;
            return layer;
        };
        
        CAShapeLayer *trackLayer = [CAShapeLayer layer];
        trackLayer.lineWidth = 7.5;
        trackLayer.strokeColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2].CGColor;
        trackLayer.backgroundColor = [UIColor clearColor].CGColor;
        trackLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:trackLayer];
        self.trackLayer = trackLayer;
        
        CAShapeLayer *layer1 = CAShapeLayerBuilderBlock();
        [self.layer addSublayer:layer1];
        self.layer1 = layer1;
        
        CAShapeLayer *layer2 = CAShapeLayerBuilderBlock();
        [self.layer addSublayer:layer2];
        self.layer2 = layer2;
        
        self.duration = 1.0;
        self.initialOffset = 0.0;
        self.start = [[NSDate distantPast] timeIntervalSince1970];
    }
    return self;
}

- (void)setPath:(UIBezierPath*)path {
    _trackLayer.path = path.CGPath;
    _layer1.path = path.CGPath;
    _layer2.path = path.CGPath;
}

- (void)dealloc {
    self.layer1 = nil;
    self.layer2 = nil;
    self.displayLink = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _layer1.frame = self.bounds;
    _layer2.frame = self.bounds;
}

- (void)startAnimation {
    if (_start == [[NSDate distantPast] timeIntervalSince1970]) {
        _start = [[NSDate date] timeIntervalSince1970];
    }
    
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkFired:)];
    self.displayLink = displayLink;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation {
    if (!_displayLink.isPaused) {
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSRunLoopCommonModes];
        [_displayLink invalidate];
        self.displayLink = nil;
    }
}

CGFloat SFStrokeOffset(CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	t /= d/2.0;
	if (t < 1.0) return c/2.0*t*t + b;
	t--;
	return -c/2 * (t*(t-2.0) - 1.0) + b;
};

- (void)displayLinkFired:(CADisplayLink*)displayLink {
    NSTimeInterval elapsedTime = ([[NSDate date] timeIntervalSince1970]-_start)+(_duration*self.initialOffset);
    double time = (elapsedTime - (_duration*floorf(elapsedTime/_duration)))/_duration;
    self.strokeLocation = pow(time, 1.0);
}

#pragma mark - Overrides

- (void)setStrokeLength:(CGFloat)strokeLength {
    _strokeLength = MIN(MAX(strokeLength, 0.0), 1.0);
    if (!_displayLink) {
        self.strokeLocation = self.strokeLocation;
    }
}

- (void)setStrokeLocation:(CGFloat)strokeLocation {
    strokeLocation = strokeLocation > 1.0 ? 0.0 : strokeLocation;
    _strokeLocation = strokeLocation;
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    if (_strokeLocation-_strokeLength > 0) {
        _layer1.strokeEnd = _strokeLocation;
        _layer1.strokeStart = _strokeLocation-_strokeLength;
        _layer2.strokeEnd = 0.0;
        _layer2.strokeStart = 0.0;
    } else {
        _layer1.strokeEnd = _strokeLocation;
        _layer1.strokeStart = 0.0;
        _layer2.strokeEnd = 1.0;
        _layer2.strokeStart = 1.0-(_strokeLength-_strokeLocation);
    }
    [CATransaction commit];
}

- (void)setColor:(UIColor *)color {
    _layer1.strokeColor = color.CGColor;
    _layer2.strokeColor = _layer1.strokeColor;
}

- (UIColor*)color {
    return [UIColor colorWithCGColor:_layer1.strokeColor];
}

@end

@interface SFSimpleLogoAnimationView (PrivateMethods)

-(void)drawPathsForLogo;

@end

@interface SFSimpleLogoAnimationView ()
@property (nonatomic, assign) NSTimeInterval start;
@end

@implementation SFSimpleLogoAnimationView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.iterations = 5;
        self.amplitude = 0.2;
        self.resolution = 200;
        self.frequency = 2.0;
        self.tailLength = 0.8;
        [self drawPathsForLogo];
    }
    
    return self;
}

- (NSArray*)pointsWithResolution:(float)resolution
                       amplitude:(float)amplitude
                           phase:(float)phase
                       frequency:(float)frequency {
    
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:resolution];
    CGFloat resolutionIncrement = (2.0*M_PI)/resolution;
    
    for(int i = 1; i < resolution+1; i++) {
        
        CGFloat x = (0.5+0.5*amplitude*sinf(phase+frequency*(i*resolutionIncrement)))*cosf(i*resolutionIncrement);
        CGFloat y = (0.5+0.5*amplitude*sinf(phase+frequency*(i*resolutionIncrement)))*sinf(i*resolutionIncrement);
        
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
    return [NSArray arrayWithArray:points];
}

- (NSArray*)pointsForPathWithResolution:(float)resolution
                              amplitude:(float)amplitude
                              frequency:(float)frequency {
    
    float phaseIncrement = (2.0*M_PI)/self.iterations;
    
    NSMutableArray *shapes = [NSMutableArray arrayWithCapacity:self.iterations];
    
    for(int i = 1; i < self.iterations+1; i++) {
        
        [shapes addObject:[self pointsWithResolution:resolution
                                           amplitude:amplitude
                                               phase:i*phaseIncrement
                                           frequency:frequency]];
    }
    
    return [NSArray arrayWithArray:shapes];
}

-(NSArray*)pathsForResolution:(float)resolution
                    amplitude:(float)amplitude
                    frequency:(float)frequency {
    
    NSArray *shapes = [self pointsForPathWithResolution:resolution
                                              amplitude:amplitude
                                              frequency:frequency];
    
    //Get Min and Max X and Y
    
    __block CGFloat maxX = NSIntegerMin;
    __block CGFloat minX = NSIntegerMax;
    __block CGFloat maxY = NSIntegerMin;
    __block CGFloat minY = NSIntegerMax;
    
    [shapes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSArray *points = (NSArray*)obj;
        
        [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            CGPoint point = [(NSValue*)obj CGPointValue];
            
            CGFloat x = point.x;
            CGFloat y = point.y;
            
            if (x < minX) {
                
                minX = x;
            }
            
            else if (x > maxX) {
                
                maxX = x;
            }
            
            if (y < minY) {
                
                minY = y;
            }
            
            else if (x > maxY) {
                
                maxY = y;
            }
        }];
    }];
    
    //Get the scaler for each dimension
    
    CGFloat xScaler = maxX - minX;
    CGFloat yScaler = maxX - minX;
    
    //Scale the points for this view and store in normalized points
    
    NSMutableArray *normalizedPoints = [NSMutableArray arrayWithCapacity:[shapes count]];
    
    [shapes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSArray *points = (NSArray*)obj;
        __block NSMutableArray *newPoints = [NSMutableArray arrayWithCapacity:[points count]];
        
        [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            CGPoint point = [(NSValue*)obj CGPointValue];
            CGPoint scaledPoint = CGPointMake(point.x/xScaler, point.y/yScaler);
            
            [newPoints addObject:[NSValue valueWithCGPoint:scaledPoint]];
        }];
        
        [normalizedPoints addObject:newPoints];
    }];
    
    NSMutableArray *paths = [NSMutableArray arrayWithCapacity:self.iterations];
    
    //For all the normalized points put a straight line between them to create the path
    
    [normalizedPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSArray *points = (NSArray*)obj;
        
        __block CGMutablePathRef logoPath = CGPathCreateMutable();
        
        [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            CGPoint point = [(NSValue*)obj CGPointValue];
            
            CGPoint scaledPoint = CGPointMake(point.x*CGRectGetWidth(self.frame),
                                              point.y*CGRectGetHeight(self.frame));
            
            scaledPoint = CGPointMake(scaledPoint.x+CGRectGetWidth(self.frame)/2, scaledPoint.y+CGRectGetHeight(self.frame)/2);
            
            if (idx == 0) {
                
                CGPathMoveToPoint(logoPath,
                                  NULL,
                                  scaledPoint.x,
                                  scaledPoint.y);
            }
            
            else {
                
                CGPathAddLineToPoint(logoPath,
                                     NULL,
                                     scaledPoint.x,
                                     scaledPoint.y);
            }
            
            if (idx == ([points count]-1)) {
                
                CGPathCloseSubpath(logoPath);
            }
        }];
        
        [paths addObject:[UIBezierPath bezierPathWithCGPath:logoPath]];
        
        // FIXME losing CGMutablePath
    }];
    
    return [NSArray arrayWithArray:paths];
}

- (UIColor*)strokeColorForIndex:(NSInteger)index {    
    return _colors ? _colors[index % _colors.count] : [UIColor lightGrayColor];
}

- (void)redrawPaths {
    
    if (self.subviews.count == 0) return;
    
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SFSimpleLogoLineView *view = obj;
        [view stopAnimation];
        [view removeFromSuperview];
    }];
    
    [self drawPathsForLogo];
}

- (void)drawPathsForLogo {
    
    NSArray *fromPaths = [self pathsForResolution:self.resolution
                                        amplitude:self.amplitude
                                        frequency:self.frequency];
    
    __block typeof(self) blockSelf = self;
    __block NSMutableArray *logoLineViews = [@[] mutableCopy];
    [fromPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SFSimpleLogoLineView *lineView = [[SFSimpleLogoLineView alloc] initWithFrame:self.bounds];
        [lineView setPath:(UIBezierPath*)obj];
        lineView.strokeLength = blockSelf.tailLength;
        lineView.color = [blockSelf strokeColorForIndex:idx];
        lineView.initialOffset = (idx%2)*0.05;
        lineView.duration = 1.5;
        [logoLineViews addObject:lineView];
    }];
    
    [logoLineViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [blockSelf addSubview:obj];
        [(SFSimpleLogoLineView*)obj startAnimation];
    }];
}

#pragma mark - Custom Setters

- (void)setIterations:(float)iterations {
    _iterations = iterations;
    [self redrawPaths];
}

- (void)setAmplitude:(float)amplitude {
    _amplitude = amplitude;
    [self redrawPaths];
}

- (void)setResolution:(float)resolution {
    _resolution = resolution;
    [self redrawPaths];
}

- (void)setFrequency:(float)frequency {
    _frequency = frequency;
    [self redrawPaths];
}

- (void)setTailLength:(CGFloat)tailLength {
    _tailLength = tailLength;
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SFSimpleLogoLineView *lineView = obj;
        lineView.strokeLength = tailLength;
    }];
}

- (void)startAnimating {
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SFSimpleLogoLineView *lineView = obj;
        [lineView startAnimation];
    }];
}

- (void)stopAnimating {
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SFSimpleLogoLineView *lineView = obj;
        [lineView stopAnimation];
    }];
}

- (void)setDuration:(NSTimeInterval)duration {
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SFSimpleLogoLineView *lineView = obj;
        lineView.duration = duration;
    }];
}

- (void)setRandomizeDuration:(BOOL)randomizeDuration {
    NSTimeInterval duration = [(SFSimpleLogoLineView*)self.subviews.firstObject duration];
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SFSimpleLogoLineView *lineView = obj;
        lineView.duration = duration * (1.0+(randomizeDuration ? ((arc4random()%100)/100.0) : 0.0));
    }];
}

- (void)setColors:(NSArray *)colors {
    _colors = colors;
    [self redrawPaths];
}

@end