//
//  AdyLocationRequest.m
//
//  Copyright (c) 2014-2015 Adyit Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "AdyLocationRequest.h"


@interface AdyLocationRequest ()

// Redeclare this property as readwrite for internal use.
@property (nonatomic, assign, readwrite) BOOL hasTimedOut;

/** The NSDate representing the time when the request started. Set when the |timeout| property is set. */
@property (nonatomic, strong) NSDate *requestStartTime;
/** The timer that will fire to notify this request that it has timed out. Started when the |timeout| property is set. */
@property (nonatomic, strong) NSTimer *timeoutTimer;

@end


@implementation AdyLocationRequest

static AdyLocationRequestID _nextRequestID = 0;

/**
 Returns a unique request ID (within the lifetime of the application).
 */
+ (AdyLocationRequestID)getUniqueRequestID
{
    _nextRequestID++;
    return _nextRequestID;
}

/**
 Throws an exeption when you try to create a location request using a non-designated initializer.
 */
- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Must use initWithType: instead." userInfo:nil];
    return [self initWithType:AdyLocationRequestTypeSingle];
}

/**
 Designated initializer. Initializes and returns a newly allocated location request object with the specified type.
 
 @param type The type of the location request. 
 */
- (instancetype)initWithType:(AdyLocationRequestType)type
{
    self = [super init];
    if (self) {
        _requestID = [AdyLocationRequest getUniqueRequestID];
        _type = type;
        _hasTimedOut = NO;
    }
    return self;
}

/**
 Returns the associated recency threshold (in seconds) for the location request's desired accuracy level.
 */
- (NSTimeInterval)updateTimeStaleThreshold
{
    switch (self.desiredAccuracy) {
        case AdyLocationAccuracyRoom:
            return kAdyUpdateTimeStaleThresholdRoom;
            break;
        case AdyLocationAccuracyHouse:
            return kAdyUpdateTimeStaleThresholdHouse;
            break;
        case AdyLocationAccuracyBlock:
            return kAdyUpdateTimeStaleThresholdBlock;
            break;
        case AdyLocationAccuracyNeighborhood:
            return kAdyUpdateTimeStaleThresholdNeighborhood;
            break;
        case AdyLocationAccuracyCity:
            return kAdyUpdateTimeStaleThresholdCity;
            break;
        default:
            NSAssert(NO, @"Unknown desired accuracy.");
            return 0.0;
            break;
    }
}

/**
 Returns the associated horizontal accuracy threshold (in meters) for the location request's desired accuracy level.
 */
- (CLLocationAccuracy)horizontalAccuracyThreshold
{
    switch (self.desiredAccuracy) {
        case AdyLocationAccuracyRoom:
            return kAdyHorizontalAccuracyThresholdRoom;
            break;
        case AdyLocationAccuracyHouse:
            return kAdyHorizontalAccuracyThresholdHouse;
            break;
        case AdyLocationAccuracyBlock:
            return kAdyHorizontalAccuracyThresholdBlock;
            break;
        case AdyLocationAccuracyNeighborhood:
            return kAdyHorizontalAccuracyThresholdNeighborhood;
            break;
        case AdyLocationAccuracyCity:
            return kAdyHorizontalAccuracyThresholdCity;
            break;
        default:
            NSAssert(NO, @"Unknown desired accuracy.");
            return 0.0;
            break;
    }
}

/**
 Completes the location request.
 */
- (void)complete
{
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
    self.requestStartTime = nil;
}

/**
 Forces the location request to consider itself timed out.
 */
- (void)forceTimeout
{
    if (self.isRecurring == NO) {
        self.hasTimedOut = YES;
    } else {
        NSAssert(self.isRecurring == NO, @"Only single location requests (not recurring requests) should ever be considered timed out.");
    }
}

/**
 Cancels the location request.
 */
- (void)cancel
{
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
    self.requestStartTime = nil;
}

/**
 Starts the location request's timeout timer if a nonzero timeout value is set, and the timer has not already been started.
 */
- (void)startTimeoutTimerIfNeeded
{
    if (self.timeout > 0 && !self.timeoutTimer) {
        self.requestStartTime = [NSDate date];
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeout target:self selector:@selector(timeoutTimerFired:) userInfo:nil repeats:NO];
    }
}

/**
 Computed property that returns whether this is a subscription request.
 */
- (BOOL)isRecurring
{
    return (self.type == AdyLocationRequestTypeSubscription) || (self.type == AdyLocationRequestTypeSignificantChanges);
}

/**
 Computed property that returns how long the request has been alive (since the timeout value was set).
 */
- (NSTimeInterval)timeAlive
{
    if (self.requestStartTime == nil) {
        return 0.0;
    }
    return fabs([self.requestStartTime timeIntervalSinceNow]);
}

/**
 Returns whether the location request has timed out or not.
 Once this becomes YES, it will not automatically reset to NO even if a new timeout value is set.
 */
- (BOOL)hasTimedOut
{
    if (self.timeout > 0.0 && self.timeAlive > self.timeout) {
        _hasTimedOut = YES;
    }
    return _hasTimedOut;
}

/**
 Callback when the timeout timer fires. Notifies the delegate that this event has occurred.
 */
- (void)timeoutTimerFired:(NSTimer *)timer
{
    self.hasTimedOut = YES;
    [self.delegate locationRequestDidTimeout:self];
}

/**
 Two location requests are considered equal if their request IDs match.
 */
- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    if (((AdyLocationRequest *)object).requestID == self.requestID) {
        return YES;
    }
    return NO;
}

/**
 Return a hash based on the string representation of the request ID.
 */
- (NSUInteger)hash
{
    return [[NSString stringWithFormat:@"%ld", (long)self.requestID] hash];
}

- (void)dealloc
{
    [_timeoutTimer invalidate];
}

@end
