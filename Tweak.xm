#import <UIKit/UIKit.h>

@interface _UIBatteryView : UIView
@property (nonatomic,retain) CAShapeLayer * bodyLayer; 
@property (nonatomic,retain) CAShapeLayer * pinLayer;
@property (nonatomic,retain) CALayer * fillLayer; 
@property (nonatomic,retain) CAShapeLayer * batteryLayer;
@property (nonatomic,retain) CAShapeLayer * batteryBodyLayer;
@property (assign,nonatomic) double chargePercent; 
@property (nonatomic,assign) CGFloat bodyColorAlpha;
-(UIColor *)bodyColor;
-(UIColor *)_batteryFillColor;
@end

%hook _UIBatteryView
%property (nonatomic, retain) CAShapeLayer * batteryLayer;
%property (nonatomic, retain) CAShapeLayer * batteryBodyLayer;

-(void)_commonInit{
	%orig;
	/*
	Init our battery layer and add it to the stack!
	*/
	self.bodyColorAlpha = 0;
	self.batteryBodyLayer = [[CAShapeLayer alloc] init];
	self.batteryLayer = [[CAShapeLayer alloc] init];
	[self.bodyLayer addSublayer:self.batteryBodyLayer];
	[self.batteryBodyLayer addSublayer:self.batteryLayer];
}

-(void)setBodyColorAlpha:(CGFloat)arg1{
	%orig(0);
}

-(void)_updateFillLayer{
	%orig;
	self.batteryLayer.strokeEnd = float(self.chargePercent);
}

-(void)_updatePercentage{
	%orig;
	self.batteryLayer.strokeEnd = float(self.chargePercent);
}

-(void)_updateFillColor{
	/*
	Hide our fill layer. Can't remove it form the superview due to the bolt somehow requiring it.
	*/
	self.fillLayer.backgroundColor = [UIColor clearColor].CGColor;
	self.batteryLayer.strokeColor = [self _batteryFillColor].CGColor;
}

-(UIColor *) _batteryFillColor{
	/*
	Make it look better on white backgrounds
	*/
	UIColor *original = %orig;
	if ([original isEqual:[UIColor blackColor]]){
		return [UIColor whiteColor];
	} else {
		return original;
	}
}




-(UIColor *) bodyColor {
	/*
	Make it look better on white backgrounds
	*/
	UIColor *original = %orig;
	if ([original isEqual:[[UIColor blackColor] colorWithAlphaComponent:0.4]]){
		return [original colorWithAlphaComponent:1.0];
	} else {
		return original;
	}
}

-(void)layoutSubviews {
	%orig;
	/*
	Setup our path for drawing a circle.
	TODO: Add other shapes ;)
	*/

	CGMutablePathRef thePath = CGPathCreateMutable();
	CGPathAddArc(thePath, NULL, 6.7, 6.5, 5, -M_PI_2, M_PI_2*3, NO);
	CGPathCloseSubpath(thePath);
	/*
	Remove the pin layer
	*/
	[self.pinLayer removeFromSuperlayer];
	/*
	Setup the body layer
	*/
	[self.batteryBodyLayer setPath:thePath];
	self.batteryBodyLayer.lineWidth = 3;
	self.batteryBodyLayer.fillColor = [UIColor clearColor].CGColor;
	self.batteryBodyLayer.backgroundColor = [UIColor clearColor].CGColor;
	self.batteryBodyLayer.strokeColor = [[self bodyColor] colorWithAlphaComponent:0.4].CGColor;

	/*
	Setup the battery layer
	*/
	[self.batteryLayer setPath:thePath];
	self.batteryLayer.lineWidth = 2;
	self.batteryLayer.fillColor = [UIColor clearColor].CGColor;
	self.batteryLayer.backgroundColor = [UIColor clearColor].CGColor;
	self.batteryLayer.strokeColor = [self _batteryFillColor].CGColor;
	self.batteryLayer.strokeStart = 0;
	self.batteryLayer.strokeEnd = float(self.chargePercent);
	
	/*
	Don't forget to release!
	*/
	CGPathRelease(thePath);
}

%end
