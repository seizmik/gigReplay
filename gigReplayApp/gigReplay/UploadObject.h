//
//  UploadObject.h
//  TimeSync2
//
//  Created by User on 26/3/13.
//  Copyright (c) 2013 Thesmos Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadObject : NSObject

@property int sessionid;
@property (strong, nonatomic) NSString *filePath;
@property double startTime;
@property int uploadStatus;
@property int entryNumber;
@property int contentType;
@property int userid;
@property (strong, nonatomic) NSString *thumbnailPath;

- (id)initWithFilePath:(NSString *)path entryid:(int)uid sessionid:(int)sid startTime:(double)start contentType:(int)type uploadStatus:(int)status fromUser:(int)user thumbnail:(NSString *)thumbPath;

@end
