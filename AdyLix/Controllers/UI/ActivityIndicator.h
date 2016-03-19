//
//  ActivityIndicator.h
//  AdyLix
//
//  Created by Sahar Mostafa on 10/22/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef ActivityIndicator_h
#define ActivityIndicator_h

#import <UIKit/UIKit.h>


typedef enum ActivityIndicatorDirection
{
    ActivityIndicatorDirectionClockwise = -1,
    ActivityIndicatorDirectionCounterClockwise = 1
} ActivityIndicatorDirection;


@interface ActivityIndicator : UIView
{
    NSUInteger      _steps;
    CGFloat         _stepDuration;
    BOOL            _isAnimating;
    
    UIColor                         *_color;
    BOOL                            _hidesWhenStopped;
    UIRectCorner                    _roundedCoreners;
    CGSize                          _cornerRadii;
    CGSize                          _finSize;
    ActivityIndicatorDirection    _direction;
    UIActivityIndicatorViewStyle    _actualActivityIndicatorViewStyle;
}


- (id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

- (CGPathRef)finPathWithRect:(CGRect)rect;
@end

#endif /* ActivityIndicator_h */
