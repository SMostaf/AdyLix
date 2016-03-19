//
//  ActivityIndicator.m
//  AdyLix
//
//  Created by Sahar Mostafa on 10/22/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivityIndicator.h"

@interface ActivityIndicator()
{
    NSTimer     *_timer;
    CGFloat     _anglePerStep;
    CGFloat     _currStep;
}

- (void)_repeatAnimation:(NSTimer*)timer;
- (UIColor*)_colorForStep:(NSUInteger)stepIndex;
- (void)_setPropertiesForStyle:(UIActivityIndicatorViewStyle)style;

@end


@implementation ActivityIndicator

- (void)awakeFromNib
{
    [self _setPropertiesForStyle:UIActivityIndicatorViewStyleWhite];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _setPropertiesForStyle:UIActivityIndicatorViewStyleWhite];
    }
    return self;
}

- (id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style;
{
    self = [self initWithFrame:CGRectZero];
    if (self)
    {
        [self _setPropertiesForStyle:style];
    }
    return self;
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    [self _setPropertiesForStyle:activityIndicatorViewStyle];
}

- (void)_setPropertiesForStyle:(UIActivityIndicatorViewStyle)style
{
   // self.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hat.png"]];
    _direction = ActivityIndicatorDirectionClockwise;
    _roundedCoreners = UIRectCornerAllCorners;
    _cornerRadii = CGSizeMake(1, 1);
    _stepDuration = 0.1;
    _steps = 12;
    
    switch (style) {
        case UIActivityIndicatorViewStyleGray:
        {
            _color = [UIColor darkGrayColor];
            _finSize = CGSizeMake(2, 5);
            self.indicatorRadius = 5;
            
            break;
        }
            
        case UIActivityIndicatorViewStyleWhite:
        {
            _color = [UIColor whiteColor];
            _finSize = CGSizeMake(2, 5);
            self.indicatorRadius = 5;
            
            break;
        }
            
        case UIActivityIndicatorViewStyleWhiteLarge:
        {
            _color = [UIColor whiteColor];
            _cornerRadii = CGSizeMake(2, 2);
            _finSize = CGSizeMake(3, 9);
            self.indicatorRadius = 8.5;
            
            break;
        }
            
        default:
            [NSException raise:NSInvalidArgumentException format:@"style invalid"];
            break;
    }
    
    _isAnimating = NO;
    if (_hidesWhenStopped)
        self.hidden = YES;
}

#pragma mark - UIActivityIndicator

- (void)startAnimating
{
    _currStep = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:_stepDuration target:self selector:@selector(_repeatAnimation:) userInfo:nil repeats:YES];
    _isAnimating = YES;
    
    if (_hidesWhenStopped)
        self.hidden = NO;
}

- (void)stopAnimating
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    _isAnimating = NO;
    if (_hidesWhenStopped)
        self.hidden = YES;
}

- (BOOL)isAnimating
{
    return _isAnimating;
}

#pragma mark - HZActivityIndicator Drawing.

- (void)setIndicatorRadius:(NSUInteger)indicatorRadius
{
    indicatorRadius = indicatorRadius;
    
    UIImage *statusImage = [UIImage imageNamed:@"hat.png"];
    UIImageView *activityImageView = [[UIImageView alloc]
                                      initWithImage:statusImage];

    activityImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"Icon@2x rot2.png"],
                                         [UIImage imageNamed:@"Icon@2x rot3.png"],
                                         [UIImage imageNamed:@"Icon@2x copy.png"],

                                         nil];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            indicatorRadius*2 + _finSize.height*2,
                            indicatorRadius*2 + _finSize.height*2);
    [self setNeedsDisplay];
}

- (void)setSteps:(NSUInteger)steps
{
    _anglePerStep = (360/steps) * M_PI / 180;
    _steps = steps;
    [self setNeedsDisplay];
}

- (void)setFinSize:(CGSize)finSize
{
    _finSize = finSize;
    [self setNeedsDisplay];
}

- (UIColor*)_colorForStep:(NSUInteger)stepIndex
{
    CGFloat alpha = 1.0 - (stepIndex % _steps) * (1.0 / _steps);
    
    return [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha(_color.CGColor, alpha)];
}

- (void)_repeatAnimation:(NSTimer*)timer
{
    _currStep++;
    [self setNeedsDisplay];
}

- (CGPathRef)finPathWithRect:(CGRect)rect
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                     byRoundingCorners:_roundedCoreners
                                                           cornerRadii:_cornerRadii];
    CGPathRef path = CGPathCreateCopy([bezierPath CGPath]);
    return path;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect finRect = CGRectMake(self.bounds.size.width/2 - _finSize.width/2, 0,
                                _finSize.width, _finSize.height);
    CGPathRef bezierPath = [self finPathWithRect:finRect];
    
    for (int i = 0; i < _steps; i++)
    {
        [[self _colorForStep:_currStep+i*_direction] set];
        
        CGContextBeginPath(context);
        CGContextAddPath(context, bezierPath);
        CGContextClosePath(context);
        CGContextFillPath(context);
        
        CGContextTranslateCTM(context, self.bounds.size.width / 2, self.bounds.size.height / 2);
        CGContextRotateCTM(context, _anglePerStep);
        CGContextTranslateCTM(context, -(self.bounds.size.width / 2), -(self.bounds.size.height / 2));
    }
}


@end
