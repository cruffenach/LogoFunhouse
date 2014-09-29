//
//  ViewController.m
//  LogoFunhouse_ObjC
//
//  Created by Collin Ruffenach on 8/6/14.
//  Copyright (c) 2014 Simple. All rights reserved.
//

#import "ViewController.h"
#import "SFSimpleLogoAnimationView.h"

static CGFloat const kSFTableViewCellContentInsetTop = 0.0;
static CGFloat const kSFTableViewCellContentInsetLeft = 15.0;
static CGFloat const kSFTableViewCellContentInsetBottom = 0.0;
static CGFloat const kSFTableViewCellContentInsetRight = 15.0;
static UIEdgeInsets const kSFTableViewCellContentInsets = (UIEdgeInsets){
    kSFTableViewCellContentInsetTop,
    kSFTableViewCellContentInsetLeft,
    kSFTableViewCellContentInsetBottom,
    kSFTableViewCellContentInsetRight
};

#pragma mark - Table View Cells
#pragma mark -

typedef NS_ENUM(NSInteger, SFLogoColorType) {
    SFLogoColorTypeDefault,
    SFLogoColorTypePride,
    SFLogoColorTypeGray
};

#pragma mark SFRadioButtonCell

@protocol SFRadioButtonCellDelegate;

@interface SFRadioButtonCell : UITableViewCell
@property (nonatomic, weak)id <SFRadioButtonCellDelegate> delegate;
@end

@protocol SFRadioButtonCellDelegate <NSObject>
- (void)radioButtonCellDidSelectColorType:(SFLogoColorType)colorType;
@end

NSArray * SFLogoColors() {
    return @[@(SFLogoColorTypeDefault),
             @(SFLogoColorTypePride),
             @(SFLogoColorTypeGray)];
}

NSString * NSStringFromSFLogoColorType(SFLogoColorType colorType) {
    switch (colorType) {
        case SFLogoColorTypeDefault:
            return @"Default";
        case SFLogoColorTypePride:
            return @"Pride";
        case SFLogoColorTypeGray:
            return @"Gray";
    }
}

static NSString *const kSFRadioButtonCellIdentifier = @"kSFRadioButtonCellIdentifier";

@interface SFRadioButtonCell ()
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) SFLogoColorType colorType;
@end

@implementation SFRadioButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor grayColor];
        
        NSMutableArray *colorNames = [@[] mutableCopy];
        [SFLogoColors() enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [colorNames addObject:NSStringFromSFLogoColorType((SFLogoColorType)[obj integerValue])];
        }];
        
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:colorNames];
        segmentedControl.tintColor = [UIColor whiteColor];
        [segmentedControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:segmentedControl];
        [segmentedControl sizeToFit];
        self.segmentedControl = segmentedControl;
        
        self.colorType = SFLogoColorTypeDefault;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _segmentedControl.center = CGPointMake(CGRectGetMidX(self.contentView.bounds),
                                           CGRectGetMidY(self.contentView.bounds));
}

#pragma mark Segmented Control Value Changed

- (void)valueChanged:(UISegmentedControl*)segmentedControl {
    [_delegate radioButtonCellDidSelectColorType:self.colorType];
}

#pragma mark Overrides

- (void)setColorType:(SFLogoColorType)colorType {
    _segmentedControl.selectedSegmentIndex = [SFLogoColors() indexOfObject:@(colorType)];
}

- (SFLogoColorType)colorType {
    return (SFLogoColorType)[SFLogoColors()[_segmentedControl.selectedSegmentIndex] integerValue];
}

@end

#pragma mark - SFSwitchCell

@protocol SFSwitchCellDelegate;

@interface SFSwitchCell : UITableViewCell
@property (nonatomic, assign) NSString *switchText;
@property (nonatomic, assign) BOOL switchControlOn;
@property (nonatomic, assign) id <SFSwitchCellDelegate> delegate;
@end

@protocol SFSwitchCellDelegate <NSObject>
- (void)switchCellSwitchDidToggle:(SFSwitchCell*)switchCell;
@end

@interface SFSwitchCell ()
@property (nonatomic, strong) UILabel *switchLabel;
@property (nonatomic, assign) UISwitch *switchControl;
@end

static NSString *const kSFSwitchCellIdentifier = @"kSFSwitchCellIdentifier";

@implementation SFSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor grayColor];
        
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchControl.tintColor = [UIColor whiteColor];
        switchControl.onTintColor = [UIColor colorWithHue:196.0/365.0 saturation:0.62 brightness:0.80 alpha:1.0];
        [switchControl addTarget:self action:@selector(switchControlToggled:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:switchControl];
        self.switchControl = switchControl;
        
        UILabel *switchLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        switchLabel.textColor = [UIColor whiteColor];
        switchLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:switchLabel];
        self.switchLabel = switchLabel;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentFrame = UIEdgeInsetsInsetRect(self.contentView.bounds, kSFTableViewCellContentInsets);
    _switchControl.frame = CGRectMake(CGRectGetMaxX(contentFrame)-CGRectGetWidth(_switchControl.bounds),
                                      (CGRectGetHeight(self.contentView.bounds)-CGRectGetHeight(_switchControl.bounds))/2.0,
                                      CGRectGetWidth(_switchControl.bounds),
                                      CGRectGetHeight(_switchControl.bounds));
    _switchLabel.frame = CGRectMake(CGRectGetMinX(contentFrame),
                                    0,
                                    CGRectGetMinX(_switchControl.frame),
                                    CGRectGetHeight(self.contentView.bounds));
}

- (void)switchControlToggled:(UISwitch*)switchControl {
    [self.delegate switchCellSwitchDidToggle:self];
}

#pragma mark Overrides

- (void)setSwitchText:(NSString *)switchText {
    _switchLabel.text = switchText;
    [self setNeedsLayout];
}

- (NSString*)switchText {
    return _switchLabel.text;
}

- (void)setSwitchControlOn:(BOOL)switchControlOn {
    _switchControl.on = switchControlOn;
}

- (BOOL)switchControlOn {
    return _switchControl.on;
}

@end

#pragma mark - SFSliderCell

@protocol SFSliderCellDelegate;

@interface SFSliderCell : UITableViewCell
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) NSString *sliderText;
@property (nonatomic, assign) BOOL integersOnly;
@property (nonatomic, assign) id <SFSliderCellDelegate> delegate;
@end

@protocol SFSliderCellDelegate <NSObject>
- (void)sliderValueDidChange:(SFSliderCell*)sliderCell;
@end

static NSString *const kSFSliderCellIdentifier = @"kSFSliderCellIdentifier";

@interface SFSliderCell ()
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *sliderLabel;
@end

static CGFloat const kLabelSliderMarginHorizontal = 10.0;

@implementation SFSliderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor grayColor];
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectZero];
        slider.minimumValue = 0.0;
        slider.maximumValue = 1.0;
        slider.tintColor = [UIColor whiteColor];
        [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:slider];
        self.slider = slider;
        
        UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        sliderLabel.textColor = [UIColor whiteColor];
        sliderLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:sliderLabel];
        self.sliderLabel = sliderLabel;
        
        self.sliderText = @(slider.value).stringValue;
        
        self.integersOnly = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentFrame = UIEdgeInsetsInsetRect(self.contentView.bounds, kSFTableViewCellContentInsets);
    _sliderLabel.frame = CGRectMake(CGRectGetMinX(contentFrame),
                                    0,
                                    CGRectGetWidth(_sliderLabel.bounds),
                                    CGRectGetHeight(self.contentView.bounds));
    _slider.frame = CGRectMake(CGRectGetMaxX(_sliderLabel.frame)+kLabelSliderMarginHorizontal,
                               0,
                               CGRectGetMaxX(contentFrame)-kLabelSliderMarginHorizontal-CGRectGetMaxX(_sliderLabel.frame),
                               CGRectGetHeight(self.bounds));
}

- (void)sliderChanged:(UISlider*)slider {
    self.sliderText = self.sliderText;
    [self.delegate sliderValueDidChange:self];
}

#pragma mark Overrides

- (void)setSliderText:(NSString *)sliderText {
    _sliderLabel.text = [sliderText stringByAppendingFormat:@": %0.2f", _integersOnly ? floorf(self.value) : self.value];
    [_sliderLabel sizeToFit];
    [self setNeedsLayout];
}

- (NSString*)sliderText {
    return [_sliderLabel.text substringToIndex:[_sliderLabel.text rangeOfString:@":"].location];;
}

- (void)setValue:(CGFloat)value {
    _slider.value = value;
    self.sliderText = self.sliderText;
}

- (CGFloat)value {
    return _integersOnly ? floorf(_slider.value) : _slider.value;
}

@end

#pragma mark - View Controller

typedef NS_ENUM(NSInteger, SFLogoFunhouseTableMode) {
    SFLogoFunhouseTableModeBaseOptions,
    SFLogoFunhouseTableModeGuillocheOptions
};

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, SFRadioButtonCellDelegate, SFSliderCellDelegate, SFSwitchCellDelegate> {
    NSDictionary *_pCells;
}

@property (nonatomic, strong) UIView *border;
@property (nonatomic, assign) CGFloat lastScale;
@property (nonatomic, strong) SFSimpleLogoAnimationView *logoView;
@property (nonatomic, readonly) NSArray *cells;
@property (nonatomic, readonly) SFRadioButtonCell *colorCell;
@property (nonatomic, readonly) SFSwitchCell *animateCell;
@property (nonatomic, readonly) SFSliderCell *tailLengthCell;
@property (nonatomic, readonly) SFSliderCell *durationCell;
@property (nonatomic, readonly) SFSwitchCell *randomizeCell;
@property (nonatomic, readonly) UITableViewCell *guillocheCoefficientsCell;
@property (nonatomic, readonly) SFSliderCell *iterationsCell;
@property (nonatomic, readonly) SFSliderCell *amplitudeCell;
@property (nonatomic, readonly) SFSliderCell *frequencyCell;
@property (nonatomic, readonly) UITableViewCell *backToBasicsCell;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) SFLogoFunhouseTableMode tableMode;
@property (nonatomic, assign) SFLogoColorType colorType;

- (void)setTableMode:(SFLogoFunhouseTableMode)tableMode animated:(BOOL)animated;

@end

typedef NS_ENUM(NSInteger, SFLogoFunhouseCellType) {
    SFLogoFunhouseCellTypeColor,
    SFLogoFunhouseCellTypeAnimate,
    SFLogoFunhouseCellTypeTailLength,
    SFLogoFunhouseCellTypeDuration,
    SFLogoFunhouseCellTypeRandomizeDuration,
    SFLogoFunhouseCellTypeGuillocheCoefficients,
    SFLogoFunhouseCellTypeGuillocheIterations,
    SFLogoFunhouseCellTypeGuillocheAmplitude,
    SFLogoFunhouseCellTypeGuillocheFrequency,
    SFLogoFunhouseCellTypeBackToBasic
};

NSArray * SFLogoFunhouseBaseCells() {
    return @[
             @(SFLogoFunhouseCellTypeColor),
             @(SFLogoFunhouseCellTypeAnimate),
             @(SFLogoFunhouseCellTypeTailLength),
             @(SFLogoFunhouseCellTypeDuration),
             @(SFLogoFunhouseCellTypeRandomizeDuration),
             @(SFLogoFunhouseCellTypeGuillocheCoefficients)
             ];
}

NSArray * SFLogoFunhouseGuillocheCoefficientCells() {
    return @[
             @(SFLogoFunhouseCellTypeGuillocheIterations),
             @(SFLogoFunhouseCellTypeGuillocheAmplitude),
             @(SFLogoFunhouseCellTypeGuillocheFrequency),
             @(SFLogoFunhouseCellTypeBackToBasic)
             ];
}

NSArray * SFLogoFunhouseCells(SFLogoFunhouseTableMode mode) {
    switch (mode) {
        case SFLogoFunhouseTableModeBaseOptions:
            return SFLogoFunhouseBaseCells();
        case SFLogoFunhouseTableModeGuillocheOptions:
            return SFLogoFunhouseGuillocheCoefficientCells();
    }
}

SFLogoFunhouseCellType SFLogoFunhouseCellTypeForIndexPath(SFLogoFunhouseTableMode mode, NSIndexPath *indexPath) {
    return [SFLogoFunhouseCells(mode)[indexPath.row] integerValue];
}

static NSString *const kSFLogoFunhouseTextCellIdentifier = @"kSFLogoFunhouseTextCellIdentifier";

NSString * SFLogoFunhouseCellIdentifierForCellType(SFLogoFunhouseCellType cellType) {
    switch (cellType) {
        case SFLogoFunhouseCellTypeColor:
            return kSFRadioButtonCellIdentifier;
        case SFLogoFunhouseCellTypeTailLength:
        case SFLogoFunhouseCellTypeDuration:
        case SFLogoFunhouseCellTypeGuillocheIterations:
        case SFLogoFunhouseCellTypeGuillocheAmplitude:
        case SFLogoFunhouseCellTypeGuillocheFrequency:
            return kSFSliderCellIdentifier;
        case SFLogoFunhouseCellTypeAnimate:
        case SFLogoFunhouseCellTypeRandomizeDuration:
            return kSFSwitchCellIdentifier;
        case SFLogoFunhouseCellTypeGuillocheCoefficients:
        case SFLogoFunhouseCellTypeBackToBasic:
            return kSFLogoFunhouseTextCellIdentifier;
    }
}

NSArray * SFColorsForSFLogoColorType(SFLogoColorType colorType) {
    switch (colorType) {
        case SFLogoColorTypeDefault:
            return @[
                     [UIColor colorWithRed:(216.0/255.0)
                                     green:(112.0/255.0)
                                      blue:(95.0/255.0)
                                     alpha:1.0],
                     [UIColor colorWithRed:(60.0/255.0)
                                     green:(124.0/255.0)
                                      blue:(132.0/255.0)
                                     alpha:1.0],
                     [UIColor colorWithRed:(216.0/255.0)
                                     green:(112.0/255.0)
                                      blue:(95.0/255.0)
                                     alpha:1.0],
                     [UIColor colorWithRed:(60.0/255.0)
                                     green:(124.0/255.0)
                                      blue:(132.0/255.0)
                                     alpha:1.0],
                     [UIColor colorWithRed:(60.0/255.0)
                                     green:(124.0/255.0)
                                      blue:(132.0/255.0)
                                     alpha:1.0]
                     ];
        case SFLogoColorTypePride:
            return @[
                     [UIColor colorWithRed:(288.0/255.0)
                                     green:(115.0/255.0)
                                      blue:(104.0/255.0)
                                     alpha:1],
                     [UIColor colorWithRed:(237.0/255.0)
                                     green:(166.0/255.0)
                                      blue:(90.0/255.0)
                                     alpha:1.0],
                     [UIColor colorWithRed:(243.0/255.0)
                                     green:(219.0/255.0)
                                      blue:(97.0/255.0)
                                     alpha:1.0],
                     [UIColor colorWithRed:(147.0/255.0)
                                     green:(203.0/255.0)
                                      blue:(116.0/255.0)
                                     alpha:1.0],
                     [UIColor colorWithRed:(85.0/255.0)
                                     green:(192.0/255.0)
                                      blue:(182.0/255.0)
                                     alpha:1.0],
                     [UIColor colorWithRed:(78.0/255.0)
                                     green:(170.0/255.0)
                                      blue:(204.0/255.0)
                                     alpha:1.0],
                     [UIColor colorWithRed:(148.0/255.0)
                                     green:(132.0/255.0)
                                      blue:(172.0/255.0)
                                     alpha:1.0],
                     [UIColor colorWithRed:(225.0/255.0)
                                     green:(146.0/255.0)
                                      blue:(190.0/255.0)
                                     alpha:1.0]
                     ];
        case SFLogoColorTypeGray:
            return nil;
    }
}

@implementation ViewController

- (void)loadCells {
    NSMutableDictionary *cells = [@{} mutableCopy];
    
    for (NSNumber * tableModeNumber in @[@(SFLogoFunhouseTableModeBaseOptions), @(SFLogoFunhouseTableModeGuillocheOptions)]) {
        NSMutableArray *cellsArray = [@[] mutableCopy];
        [SFLogoFunhouseCells((SFLogoFunhouseTableMode)tableModeNumber.integerValue) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SFLogoFunhouseCellType cellType = [obj integerValue];
            UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:SFLogoFunhouseCellIdentifierForCellType(cellType)
                                                                     forIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            switch (cellType) {
                case SFLogoFunhouseCellTypeColor: {
                    SFRadioButtonCell *castCell = (SFRadioButtonCell*)cell;
                    castCell.delegate = self;
                } break;
                case SFLogoFunhouseCellTypeAnimate: {
                    SFSwitchCell *castCell = (SFSwitchCell*)cell;
                    castCell.switchText = @"Animate";
                    castCell.switchControlOn = YES;
                    castCell.delegate = self;
                } break;
                case SFLogoFunhouseCellTypeTailLength: {
                    SFSliderCell *castCell = (SFSliderCell*)cell;
                    castCell.sliderText = @"Tail Length";
                    castCell.value = _logoView.tailLength;
                    castCell.delegate = self;
                } break;
                case SFLogoFunhouseCellTypeDuration: {
                    SFSliderCell *castCell = (SFSliderCell*)cell;
                    castCell.sliderText = @"Duration";
                    castCell.value = 1.0;
                    castCell.delegate = self;
                    castCell.slider.maximumValue = 5.0;
                } break;
                case SFLogoFunhouseCellTypeRandomizeDuration: {
                    SFSwitchCell *castCell = (SFSwitchCell*)cell;
                    castCell.switchText = @"Randomize Duration";
                    castCell.switchControlOn = NO;
                    castCell.delegate = self;
                } break;
                case SFLogoFunhouseCellTypeGuillocheCoefficients: {
                    cell.textLabel.text = @"Guilloche Coefficients";
                    cell.textLabel.font = [UIFont systemFontOfSize:13];
                    cell.backgroundColor = [UIColor grayColor];
                    cell.textLabel.textColor = [UIColor whiteColor];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                } break;
                case SFLogoFunhouseCellTypeGuillocheIterations: {
                    SFSliderCell *castCell = (SFSliderCell*)cell;
                    castCell.sliderText = @"Iterations";
                    castCell.slider.minimumValue = 1.0;
                    castCell.slider.maximumValue = 10.0;
                    castCell.value = 5.0;
                    castCell.integersOnly = YES;
                    castCell.delegate = self;
                } break;
                case SFLogoFunhouseCellTypeGuillocheAmplitude: {
                    SFSliderCell *castCell = (SFSliderCell*)cell;
                    castCell.sliderText = @"Amplitude";
                    castCell.slider.maximumValue = 1.0;
                    castCell.value = 0.2;
                    castCell.delegate = self;
                } break;
                case SFLogoFunhouseCellTypeGuillocheFrequency: {
                    SFSliderCell *castCell = (SFSliderCell*)cell;
                    castCell.sliderText = @"Frequency";
                    castCell.slider.minimumValue = 1.0;
                    castCell.slider.maximumValue = 10.0;
                    castCell.integersOnly = YES;
                    castCell.value = 2.0;
                    castCell.delegate = self;
                } break;
                case SFLogoFunhouseCellTypeBackToBasic: {
                    cell.textLabel.text = @"Back to basic options";
                    cell.textLabel.font = [UIFont systemFontOfSize:13];
                    cell.backgroundColor = [UIColor grayColor];
                    cell.textLabel.textColor = [UIColor whiteColor];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                } break;
            }
            [cellsArray addObject:cell];
        }];
        cells[tableModeNumber] = cellsArray;
    }
    _pCells = cells;
    self.tableMode = SFLogoFunhouseTableModeBaseOptions;
}
            
- (void)viewDidLoad {
    [super viewDidLoad];
	SFSimpleLogoAnimationView *logoView = [[SFSimpleLogoAnimationView alloc] initWithFrame:CGRectMake(0,
                                                                                                      0,
                                                                                                      CGRectGetWidth(self.view.bounds)*0.85,
                                                                                                      CGRectGetWidth(self.view.bounds)*0.85)];
    logoView.colors = SFColorsForSFLogoColorType(SFLogoColorTypeDefault);
    [logoView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizerFired:)]];
    [logoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerFired:)]];
    [self.view addSubview:logoView];
    self.logoView = logoView;
    
    self.colorType = SFLogoColorTypeDefault;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = NO;
    tableView.backgroundColor = [UIColor grayColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[SFRadioButtonCell class]
      forCellReuseIdentifier:kSFRadioButtonCellIdentifier];
    [tableView registerClass:[SFSliderCell class]
      forCellReuseIdentifier:kSFSliderCellIdentifier];
    [tableView registerClass:[SFSwitchCell class]
      forCellReuseIdentifier:kSFSwitchCellIdentifier];
    [tableView registerClass:[UITableViewCell class]
      forCellReuseIdentifier:kSFLogoFunhouseTextCellIdentifier];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectZero];
    border.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:border];
    self.border = border;
    
    [self loadCells];
}

- (CGFloat)tableHeight {
    return SFLogoFunhouseCells(_tableMode).count*44;
}

- (void)layoutSubviews {
    CGFloat tableHeight = [self tableHeight];
    CGRect bounds = self.view.bounds;
    _tableView.frame = CGRectMake(0,
                                  CGRectGetHeight(bounds)-tableHeight,
                                  CGRectGetWidth(bounds),
                                  tableHeight);
    _logoView.center = CGPointMake(CGRectGetMidX(bounds),
                                   (CGRectGetHeight(bounds)-tableHeight)/2.0);
    _border.bounds = CGRectMake(0,
                                0,
                                CGRectGetWidth(bounds),
                                1.0/[[UIScreen mainScreen] scale]);
    _border.center = CGPointMake(_tableView.center.x,
                                 CGRectGetMinY(_tableView.frame));
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutSubviews];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return SFLogoFunhouseCells(_tableMode).count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cells[indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.guillocheCoefficientsCell) {
        [self setTableMode:SFLogoFunhouseTableModeGuillocheOptions animated:YES];
    } else if (cell == self.backToBasicsCell) {
        [self setTableMode:SFLogoFunhouseTableModeBaseOptions animated:YES];
    }
}

#pragma mark SFSliderCellDelegate

- (void)sliderValueDidChange:(SFSliderCell*)sliderCell {
    if (sliderCell == self.tailLengthCell) {
        _logoView.tailLength = sliderCell.value;
    } else if (sliderCell == self.durationCell) {
        [_logoView setDuration:sliderCell.value];
    } else if (sliderCell == self.iterationsCell) {
        _logoView.iterations = sliderCell.value;
    } else if (sliderCell == self.amplitudeCell) {
        _logoView.amplitude = sliderCell.value;
    } else if (sliderCell == self.frequencyCell) {
        _logoView.frequency = sliderCell.value;
    }
}

#pragma mark SFSwitchCellDelegate

- (void)switchCellSwitchDidToggle:(SFSwitchCell*)switchCell {
    if (switchCell == self.animateCell) {
        switchCell.switchControlOn ? [_logoView startAnimating] : [_logoView stopAnimating];
    } else if (switchCell == self.randomizeCell) {
        [_logoView setRandomizeDuration:switchCell.switchControlOn];
    }
}

#pragma mark SFRadioButtonCellDelegate

- (void)radioButtonCellDidSelectColorType:(SFLogoColorType)colorType {
    _logoView.colors = SFColorsForSFLogoColorType(colorType);
}

#pragma mark UIGestureRecognizer Selectors

- (void)tapGestureRecognizerFired:(UIPinchGestureRecognizer*)pinchGestureRecognizer {
    __block typeof(self) blockSelf = self;
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:1.0
                        options:0
                     animations:^{
                         blockSelf.logoView.transform = CGAffineTransformIdentity;
                     } completion:NULL];
    
}

- (void)pinchGestureRecognizerFired:(UIPinchGestureRecognizer*)gestureRecognizer {
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        _lastScale = [gestureRecognizer scale];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 2.0;
        const CGFloat kMinScale = 0.5;
        
        CGFloat newScale = 1 -  (_lastScale - [gestureRecognizer scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        [gestureRecognizer view].transform = transform;
        
        _lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }
}

#pragma mark Overrides

- (NSArray*)cells {
    return _pCells[@(_tableMode)];
}

- (SFLogoFunhouseTableMode)tableModeForCellType:(SFLogoFunhouseCellType)cellType {
    return [SFLogoFunhouseCells(_tableMode) containsObject:@(cellType)] ? _tableMode :
    (_tableMode == SFLogoFunhouseTableModeBaseOptions ?
     SFLogoFunhouseTableModeGuillocheOptions :
     SFLogoFunhouseTableModeBaseOptions);
}

- (id)cellForCellType:(SFLogoFunhouseCellType)cellType {
    SFLogoFunhouseTableMode mode = [self tableModeForCellType:cellType];
    return _pCells[@(mode)][[SFLogoFunhouseCells(mode) indexOfObject:@(cellType)]];
}

- (SFRadioButtonCell*)colorCell {
    return [self cellForCellType:SFLogoFunhouseCellTypeColor];
}

- (SFSwitchCell*)animateCell {
    return [self cellForCellType:SFLogoFunhouseCellTypeAnimate];
}

- (SFSliderCell*)tailLengthCell {
    return [self cellForCellType:SFLogoFunhouseCellTypeTailLength];
}

- (SFSliderCell*)durationCell {
    return [self cellForCellType:SFLogoFunhouseCellTypeDuration];
}

- (SFSwitchCell*)randomizeCell {
    return [self cellForCellType:SFLogoFunhouseCellTypeRandomizeDuration];
}

- (SFSliderCell*)iterationsCell {
    return [self cellForCellType:SFLogoFunhouseCellTypeGuillocheIterations];
}

- (SFSliderCell*)amplitudeCell {
    return [self cellForCellType:SFLogoFunhouseCellTypeGuillocheAmplitude];
}

- (SFSliderCell*)frequencyCell {
    return [self cellForCellType:SFLogoFunhouseCellTypeGuillocheFrequency];
}

- (UITableViewCell*)guillocheCoefficientsCell {
    return [self cellForCellType:SFLogoFunhouseCellTypeGuillocheCoefficients];
}

- (UITableViewCell*)backToBasicsCell {
    return [self cellForCellType:SFLogoFunhouseCellTypeBackToBasic];
}

- (void)setTableMode:(SFLogoFunhouseTableMode)tableMode animated:(BOOL)animated {
    if (animated) {
        [_tableView beginUpdates];
        NSArray *showingCells = SFLogoFunhouseCells(_tableMode);
        NSArray *incomingCells = SFLogoFunhouseCells(tableMode);
        _tableMode = tableMode;
        
        NSInteger differential = @(incomingCells.count).integerValue-@(showingCells.count).integerValue;
        NSMutableArray *indexPathsToModify = [@[] mutableCopy];
        BOOL inserting = differential > 0;
        for (int i = (inserting ? 0 : 1); i < (inserting ? differential : (ABS(differential)+1)); i++) {
            [indexPathsToModify addObject:[NSIndexPath indexPathForRow:(inserting ? showingCells.count+i :showingCells.count-i)
                                                             inSection:0]];
        }
        
        inserting ? [_tableView insertRowsAtIndexPaths:indexPathsToModify
                                      withRowAnimation:UITableViewRowAnimationFade] :
        [_tableView deleteRowsAtIndexPaths:indexPathsToModify
                          withRowAnimation:UITableViewRowAnimationFade];
        
        
        NSMutableArray *indexPathsToReload = [@[] mutableCopy];
        for (int i = 0; i < MIN(showingCells.count, incomingCells.count); i++) {
            [indexPathsToReload addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [_tableView reloadRowsAtIndexPaths:indexPathsToReload
                          withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
        
        __block typeof(self) blockSelf = self;
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:0.8
              initialSpringVelocity:1.0
                            options:0
                         animations:^{
                             [blockSelf layoutSubviews];
                         }
                         completion:NULL];
    } else {
        _tableMode = tableMode;
        [_tableView  reloadData];
        [self layoutSubviews];
    }
}

- (void)setTableMode:(SFLogoFunhouseTableMode)tableMode {
    [self setTableMode:tableMode animated:NO];
}

- (SFLogoColorType)colorType {
    return self.colorCell.colorType;
}

- (void)setColorType:(SFLogoColorType)colorType {
    self.colorCell.colorType = colorType;
}

@end