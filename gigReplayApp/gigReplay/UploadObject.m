//
//  UploadObject.m
//  TimeSync2
//
//  Created by User on 26/3/13.
//  Copyright (c) 2013 Thesmos Inc. All rights reserved.
//

#import "UploadObject.h"

@implementation UploadObject

@synthesize sessionid, filePath, startTime, uploadStatus, entryNumber, contentType, userid;

- (id)initWithFilePath:(NSString *)path entryid:(int)uid sessionid:(int)sid startTime:(double)start contentType:(int)type uploadStatus:(int)status fromUser:(int)user{
    self.filePath = path;
    self.sessionid = sid;
    self.startTime = start;
    self.uploadStatus = status;
    self.entryNumber = uid;
    self.contentType = type;
    self.userid = user;
    return self;
}

@end