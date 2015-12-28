//
//  ShareHelper.h
//  AdyLix
//
//  Created by Sahar Mostafa on 12/18/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef ShareHelper_h
#define ShareHelper_h

#import <UIKit/UIKit.h>
#import "DataInfo.h"

@interface ShareHelper : NSObject
enum ShareType {
    kEmpty = 0,
    kShareItem = 1,
    kShareStyle = 2
};
+(UIActivityViewController*) shareInfo:(enum ShareType) type info:(DataInfo*) info;
@end

#endif /* ShareHelper_h */
