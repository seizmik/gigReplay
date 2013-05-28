//
//  SyncObject.h
//  gigReplay
//
//  Created by User on 28/5/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncObject : NSObject

@property int entryid;
@property double previousTimeRelationship;
@property double previousSync;
@property BOOL expiredSync;

- (id)initWithLastRelationship:(double)lastRelationship since:(double)lastSync entry:(int)entry;

@end
