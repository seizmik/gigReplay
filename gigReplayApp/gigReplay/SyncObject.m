//
//  SyncObject.m
//  gigReplay
//
//  Created by User on 28/5/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "SyncObject.h"

@implementation SyncObject
@synthesize entryid, previousSync, previousTimeRelationship, expiredSync;

- (id)initWithLastRelationship:(double)lastRelationship since:(double)lastSync entry:(int)entry
{
    self.entryid = entry;
    self.previousSync = lastSync;
    self.previousTimeRelationship = lastRelationship;
    return self;
}

@end
