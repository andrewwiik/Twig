@interface SBFLockScreenDateView : UIView
@property (assign,nonatomic) CGFloat alignmentPercent;
@property (nonatomic, retain) UIView *weatherView;
@end


@interface WATodayPadView : UIView
- (id)initWithFrame:(CGRect)frame;
@property (nonatomic,retain) UIView * locationLabel;                       //@synthesize locationLabel=_locationLabel - In the implementation block
@property (nonatomic,retain) UIView * conditionsLabel;  
@end

@interface WALockscreenWidgetViewController : UIViewController
@end

static BOOL IS_RTL = NO;
static BOOL RTL_IS_SET = NO;

%hook SBFLockScreenDateView
%property (nonatomic, retain) UIView *weatherView;
- (CGFloat)alignmentPercent {
	if (!RTL_IS_SET) {
		IS_RTL = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
		RTL_IS_SET = YES;
	}
	return IS_RTL ? -1.0 : 1.0;
}
- (void)setAlignmentPercent:(CGFloat)percent {
	if (!RTL_IS_SET) {
		IS_RTL = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
		RTL_IS_SET = YES;
	}
	%orig(IS_RTL ? -1.0 : 1.0);
}
%end

@interface SBLockScreenDateViewController : UIViewController
@property (nonatomic, retain) UIViewController *weatherController;
@end


%hook SBLockScreenDateViewController
%property (nonatomic, retain) UIViewController *weatherController;
- (void)loadView {
	%orig;
	if (!RTL_IS_SET) {
		IS_RTL = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
		RTL_IS_SET = YES;
	}
	self.weatherController = [[NSClassFromString(@"WALockscreenWidgetViewController") alloc] init];
	[self addChildViewController:self.weatherController];
	[self.weatherController didMoveToParentViewController:self];
	[self.view addSubview:self.weatherController.view];

	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.weatherController.view
			                                             attribute:NSLayoutAttributeCenterY
			                                             relatedBy:NSLayoutRelationEqual
			                                                toItem:self.view
			                                             attribute:NSLayoutAttributeCenterY
			                                            multiplier:1
			                                              constant:0]];

	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.weatherController.view
			                                             attribute:IS_RTL ? NSLayoutAttributeRight : NSLayoutAttributeLeft
			                                             relatedBy:NSLayoutRelationEqual
			                                                toItem:self.view
			                                             attribute:IS_RTL ? NSLayoutAttributeRight : NSLayoutAttributeLeft
			                                            multiplier:1
			                                              constant:0]];
}

- (void)setContentAlpha:(CGFloat)alpha withSubtitleVisible:(BOOL)subtitleVisible {
	%orig;
	if (self.weatherController)
		self.weatherController.view.alpha = alpha;
}
%end

%hook WATodayPadViewStyle
-(NSUInteger)format {
	return 2;
}
-(void)setFormat:(NSUInteger)arg1 {
	%orig(2);
}
-(id)initWithFormat:(NSUInteger)arg1 orientation:(NSInteger)arg2 {
	return %orig(2,arg2);
}
-(double)locationLabelBaselineToTemperatureLabelBaseline {
	return 0;
}
-(double)conditionsLabelBaselineToLocationLabelBaseline {
	return 0;
}
-(double)conditionsLabelBaselineToBottom {
	return 0;
}
%end

%hook WATodayPadView
- (void)layoutSubviews {
	%orig;
	if (self.conditionsLabel) {
		self.conditionsLabel.hidden = YES;
		self.conditionsLabel.alpha = 0;
	}

	if (self.locationLabel) {
		self.locationLabel.alpha = 0;
		self.locationLabel.hidden = YES;
	}
}
%end
