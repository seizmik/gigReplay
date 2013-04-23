//
//  ApiObject.m
//  gigReplay
//
//  Created by Leon Ng on 31/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "ApiObject.h"
//wporkgjwkrherjh[perjhojerophjaeojhoerh
@implementation ApiObject;
@synthesize User_ID,apiWrapperObject,Session_Name,SessionCode,CreatedDetailsInfo,CreatedUserName,sessionExpirationStatus,SessionExpiryDateAndTime,SessionExpiryStatus,sessionExpirationDetails,SearchSessionDetailsHolder,Scene_Name,SessionCodeFromSearch,SessionCreatedDateFromSearch,SessionCreatedDetailsFromSearch,SessionCreatedUserIDFromSearch,SessionCreatedUserNameFromSearch,SessionExpiryDetailsFromSearch,SessionExpiryStatusFromSearch,SessionNameFromSearch,hasExpiredString;

//REST method of POST facebook details to WebURL(online DB)
-(void)postUserDetails:(NSString *)facebookId userEmail:(NSString *)email userName:(NSString *)Username facebookToken:(NSString *)fbtoken APIIdentifier:(int)Identifier
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:COMMON_SERVER_URL@"user"]];
    
    ResponseIdentifier=Identifier;
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:facebookId forKey:@"fb_user_id"];
    [request setPostValue:Username forKey:@"user_name"];
    [request setPostValue:fbtoken forKey:@"fb_authorization_token"];
    [request setPostValue:@"xml" forKey:@"format"];
    [request setDelegate:self];
    [request startAsynchronous];
}

-(void)postCreateSessionDetails:(NSString *)userid SessionName:(NSString *)sessioname APILink:(NSString *)Link APIIdentifier:(int)Identifier
{
    
    
    ResponseIdentifier=Identifier;
    //NSLog(@"ident %d",ResponseIdentifier);
    self.Scene_Name=sessioname;
    self.User_ID=[userid intValue];
    NSString *urlString = [NSString stringWithFormat:COMMON_SERVER_URL@"%@",Link];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:userid forKey:@"user_id"];
    if (ResponseIdentifier ==API_IDENTIFIER_SESSION_CREATION)
    {
        [request setPostValue:sessioname forKey:@"session_name"];
    }
    else if (ResponseIdentifier ==API_IDENTIFIER_SESSION_JOIN)
    {
        // NSLog(@"%@ sessionname",sessionname);
        [request setPostValue:sessioname forKey:@"session_id"];
    }
  //  NSLog(@"%@",url);
    [request setPostValue:@"xml" forKey:@"format"];
    [request setDelegate:self];
    [request startAsynchronous];
}
-(void)postJoinSessionDetails:(NSString *)userid SesssionName:(NSString *)sessionname  SessionID:(NSString *)sessionid Created_User_Id:(NSString *)Created_User_ID APIIdentifier:(int)Identifier
{
    
    
    ResponseIdentifier=Identifier;
    //NSLog(@"ident %d",ResponseIdentifier);
    self.Session_Name=sessionname;
    self.User_ID=[userid intValue];
    NSString *urlString = [NSString stringWithFormat:COMMON_SERVER_URL@"session/join"];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:userid forKey:@"user_id"];
    [request setPostValue:sessionname forKey:@"session_name"];
    [request setPostValue:sessionid forKey:@"session_id"];
    [request setPostValue:Created_User_ID forKey:@"created_user_id"];
    
    [request setPostValue:@"xml" forKey:@"format"];
    [request setDelegate:self];
    [request startAsynchronous];
}
-(void)SearchSessionDetails:(NSString *)Username  SessionName:(NSString *)sessionName APIIdentifier:(int)Identifier
{
    SearchSessionDetailsHolder=[[NSMutableArray alloc]init];
    ResponseIdentifier=API_IDENTIFIER_SEARCH_FOR_JOIN_SESSION;
    
    NSString *UrlString=[NSString stringWithFormat:COMMON_SERVER_URL@"session/user"];
      
    NSURL *url = [NSURL URLWithString:UrlString];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:Username forKey:@"user_name"];
    [request setPostValue:sessionName forKey:@"session_name"];
    [request setPostValue:@"xml" forKey:@"format"];
    
    [request setDelegate:self];
    [request startAsynchronous];
    
}



- (void)requestStarted:(ASIHTTPRequest *)request
{
    
    
    if (ResponseTimeData!=nil)
    {
        ResponseTimeData=nil;
        
    }
    
    ResponseTimeData=[[NSMutableData alloc] init];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    
    
    NSLog(@"Response %d ==> ",request.responseStatusCode);
    
    
    
    if((request.responseStatusCode==400)||(request.responseStatusCode==405)||(request.responseStatusCode==406))
    {
        [self doParse:ResponseTimeData];
        [self ShowAlertMessage:@"Warning" Message:@"Unexpected Error Occured"];
        
    }
    else if ((request.responseStatusCode==404))
    {
        
        if (ResponseIdentifier == API_IDENTIFIER_USER_REG)
        {
            //   [self SendNotificationsAfterUserRegistration:@"Warning"];
        }
        
        else
        {
            [self ShowAlertMessage:@"Warning" Message:@"No Data Found"];
            ResponseTimeData=nil;
            
        }
        
    }
        else
    {
        [self doParse:ResponseTimeData];
    }
}
- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data;
{
    
    [ResponseTimeData appendData:data];
    
    
}
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qualifiedName
attributes:(NSDictionary *)attributeDict
{
    if(ResponseIdentifier==API_IDENTIFIER_USER_REG)
    {
        if([elementName isEqualToString:@"id"])
        {
            IsUserID=TRUE;
        }
     
    }
    else if(ResponseIdentifier==API_IDENTIFIER_SESSION_CREATION)
    {
        
        if([elementName isEqualToString:@"code"])
        {
            IsCode=TRUE;
        }
        if([elementName isEqualToString:@"created_time"])
        {
            
            IsCreatedDetails=TRUE;
        }
        
        if (IsCreatedDetails)
        {
            if ([elementName isEqualToString:@"date"])
            {
                IsSessionCreatedDetails=TRUE;
            }
            
        }
        
        if ([elementName isEqualToString:@"sessionexpirationtime"])
        {
            IssessionExpirationElement=TRUE;
        }
        if (IssessionExpirationElement)
        {
            if ([elementName isEqualToString:@"date"])
            {
                IssessionExpirationDate=TRUE;
            }
            if ([elementName isEqualToString:@"has_expired"])
            {
                IssessionHasExpired=TRUE;
            }
            
            
        }
    }
    else if(ResponseIdentifier==API_IDENTIFIER_SESSION_JOIN)
        
    {
        
        if([elementName isEqualToString:@"code"])
        {
            IsCode=TRUE;
        }
        if([elementName isEqualToString:@"date"])
        {
            
            IsCreatedDetails=TRUE;
        }
        
        
    }
    else if (ResponseIdentifier==API_IDENTIFIER_SEARCH_FOR_JOIN_SESSION)
    {
        if ([elementName hasPrefix:@"session_"])
        {
            SessionPrefixFound=TRUE;
        }
        if (SessionPrefixFound)
        {
            if ([elementName isEqualToString:@"code"])
            {
                IsCodeFoundInSearch=TRUE;
            }
            if ([elementName isEqualToString:@"session_name"])
            {
                IsSessionNameFoundInSearch=TRUE;
            }
            if ([elementName isEqualToString:@"created_time"])
            {
                IsSessionCreatedInfoInSearch=TRUE;
            }
            if (IsSessionCreatedInfoInSearch)
            {
                if ([elementName isEqualToString:@"date"])
                {
                    IsSessionCreatedDateFoundInSearch=TRUE;
                }
                
            }
            if ([elementName isEqualToString:@"created_user_id"])
            {
                IsSessionCreatedUserIDInSearch=TRUE;
            }
            if ([elementName isEqualToString:@"created_user_name"])
            {
                IsSessionCreatedUserNameInSearch=TRUE;
            }
            
            if ([elementName isEqualToString:@"sessionexpirationtime"])
            {
                isSessionExpiryElementInSearch=TRUE;
            }
            if (isSessionExpiryElementInSearch)
            {
                if ([elementName isEqualToString:@"date"])
                {
                    isSessionExpiryDateAndTimeInSearch=TRUE;
                }
                if ([elementName isEqualToString:@"has_expired"])
                {
                    isSessionExpiryStatusInSearch=TRUE;
                }
                
            }
            
        }
        
    }


}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
    
     if(ResponseIdentifier==API_IDENTIFIER_USER_REG)
    {
        if (IsUserID)
        {
            self.User_ID=[string intValue];
              NSLog(@"%d user_id parse in!",User_ID);
        }
      
        
    }
    else if (ResponseIdentifier==API_IDENTIFIER_SESSION_CREATION)
    {
        
        
        if (IsCode)
        {
            self.SessionCode=string;
        }
        if ( IsCreatedDetails)
        {
            
            if (IsSessionCreatedDetails)
            {
                
                self.CreatedDetailsInfo=string;
            }
            
        }
        if (IssessionExpirationElement)
        {
            if (IssessionExpirationDate)
            {
                self.sessionExpirationDetails=string;
            }
            if (IssessionHasExpired)
            {
                self.sessionExpirationStatus=string;
            }
            
            
        }
        
    }
    else if(ResponseIdentifier==API_IDENTIFIER_SESSION_JOIN)
        
    {
        if (IsCode)
        {
            self.SessionCode=string;
        }
        if ( IsCreatedDetails)
        {
            self.CreatedDetailsInfo=string;
            
        }
        
        
    }
    else if (ResponseIdentifier==API_IDENTIFIER_SEARCH_FOR_JOIN_SESSION)
    {
        if (SessionPrefixFound)
        {
            if (IsCodeFoundInSearch)
            {
                self.SessionCodeFromSearch=string;
            }
            if (IsSessionNameFoundInSearch)
            {
                self.SessionNameFromSearch=string;
            }
            
            if (IsSessionCreatedInfoInSearch)
            {
                if (IsSessionCreatedDateFoundInSearch)
                {
                    self.SessionCreatedDateFromSearch=string;
                }
                
            }
            if (IsSessionCreatedUserIDInSearch)
            {
                self.SessionCreatedUserIDFromSearch=string;
            }
            
            if (IsSessionCreatedUserNameInSearch)
            {
                self.SessionCreatedUserNameFromSearch=string;
            }
            if (isSessionExpiryElementInSearch)
            {
                if (isSessionExpiryDateAndTimeInSearch)
                {
                    self.SessionExpiryDetailsFromSearch=string;
                    // NSLog(@"%@",self.SessionExpiryDetailsFromSearch);
                }
                if (isSessionExpiryStatusInSearch)
                {
                    self.SessionExpiryStatusFromSearch=string;
                    // NSLog(@"%@",self.SessionExpiryStatusFromSearch);
                }
            }
            
            
        }
    }

}

- (void)parser:(NSXMLParser *)parser
didEndElement:(NSString *)elementName
namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qName
{
    

  if(ResponseIdentifier==API_IDENTIFIER_USER_REG)
    {
        if ([elementName isEqualToString:@"id"])
        {
            IsUserID=FALSE;
            
        }
       
    }
    
    else if (ResponseIdentifier==API_IDENTIFIER_SESSION_CREATION)
    {
        if (IsCode)
        {
            IsCode=FALSE;
        }
        if (IsCreatedDetails)
        {
            if (IsSessionCreatedDetails)
            {
                IsSessionCreatedDetails=FALSE;
            }
            IsCreatedDetails=FALSE;
        }
        if (IssessionExpirationDate)
        {
            IssessionExpirationDate=FALSE;
        }
        if (IssessionHasExpired)
        {
            IssessionHasExpired=FALSE;
        }
        if (IssessionExpirationElement)
        {
            IssessionHasExpired=FALSE;
        }
        
        
    }
    else if (ResponseIdentifier==API_IDENTIFIER_SESSION_JOIN)
    {
        if (IsCode)
        {
            IsCode=FALSE;
        }
        if (IsCreatedDetails)
        {
            IsCreatedDetails=FALSE;
        }
        
        
    }
    else if (ResponseIdentifier==API_IDENTIFIER_SEARCH_FOR_JOIN_SESSION)
    {
        if (SessionPrefixFound)
        {
            if (([elementName isEqualToString:@"code"])&&(IsCodeFoundInSearch))
            {
                IsCodeFoundInSearch=FALSE;
            }
            if (([elementName isEqualToString:@"session_name"])&&(IsSessionNameFoundInSearch))
            {
                IsSessionNameFoundInSearch=FALSE;
            }
            if (([elementName isEqualToString:@"date"])&&(IsSessionCreatedDateFoundInSearch))
            {
                IsSessionCreatedDateFoundInSearch=FALSE;
                IsSessionCreatedInfoInSearch=FALSE;
            }
            if (([elementName isEqualToString:@"created_user_id"])&&(IsSessionCreatedUserIDInSearch))
            {
                IsSessionCreatedUserIDInSearch=FALSE;
            }
            if (([elementName isEqualToString:@"created_user_name"])&&(IsSessionCreatedUserNameInSearch))
            {
                IsSessionCreatedUserNameInSearch=FALSE;
            }
            if (([elementName isEqualToString:@"date"])&&(isSessionExpiryDateAndTimeInSearch))
            {
                isSessionExpiryDateAndTimeInSearch=FALSE;
            }
            if (([elementName isEqualToString:@"has_expired"])&&(isSessionExpiryStatusInSearch))
            {
                
                isSessionExpiryElementInSearch=FALSE;
                isSessionExpiryStatusInSearch=FALSE;
            }
            
            
            
            if (([elementName hasPrefix:@"session_"])&& (SessionPrefixFound)&&(![elementName isEqualToString:@"session_name"]))
            {
                
                NSArray *Details=[[NSArray alloc]initWithObjects:self.SessionCodeFromSearch,self.SessionNameFromSearch,self.SessionCreatedDateFromSearch,self.SessionCreatedUserIDFromSearch,self.SessionCreatedUserNameFromSearch,self.SessionExpiryDetailsFromSearch,self.SessionExpiryStatusFromSearch,nil];
                [SearchSessionDetailsHolder addObject:Details];
                
                SessionPrefixFound=FALSE;
            }
        }
        
        
    }

}

- (void) doParse:(NSData *)data
{
    
    // create and init NSXMLParser object
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];
    
    // create and init our delegate
    
    
    // set delegate
    [nsXmlParser setDelegate:self];
    
    // parsing...
    BOOL success = [nsXmlParser parse];
    
    
    // test the result
    if (success)
    {
        
        NSLog(@"No errors ");
        
        if (ResponseIdentifier==API_IDENTIFIER_SYNC)
        {
      
            [self SendNotificationsAfterSyncronisation:@"Success"];
            
        }
        else if (ResponseIdentifier==API_IDENTIFIER_USER_REG)
        {
           [self UpdateUserDetailsTableWithUserID];
            
        }
        else if (ResponseIdentifier==API_IDENTIFIER_SESSION_CREATION)
        {
            [self SetSessionDetailsToDataBase];
            
        }
        else if(ResponseIdentifier==API_IDENTIFIER_SESSION_JOIN)
        {
            [self SetJoinDetailsToDataBase];
        }
        else if(ResponseIdentifier==API_IDENTIFIER_SEARCH_FOR_JOIN_SESSION)
        {
            [self SetSearchSessionResultToDataBase];
        }
    }
    
    ResponseTimeData=nil;
    
    
}
-(void)SendNotificationsAfterSyncronisation:(NSString*)Status
{
    NSDictionary* dict = [NSDictionary dictionaryWithObject:
                          Status
                                                     forKey:@"Status"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SyncronisationParsingCompleted" object:self userInfo:dict];
}
-(void)UpdateUserDetailsTableWithUserID
{
    // NSLog(@"userID=%d",self.User_ID);
    appDelegateObject.CurrentUserID=self.User_ID;
    NSLog(@"%d",self.User_ID);
    NSString *updateQuery=[NSString stringWithFormat:@"update users set user_ID = %d",self.User_ID];
    [appDelegateObject.databaseObject updateDatabase:updateQuery];
    [self SendNotificationsAfterUserRegistration:@"Success"];
}
-(void)SendNotificationsAfterUserRegistration:(NSString*)Status
{
    NSDictionary* dict = [NSDictionary dictionaryWithObject:
                          Status
                                                     forKey:@"Status"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"UserRegistrationCompleted" object:self userInfo:dict];
}
-(void)SetSessionDetailsToDataBase
{
    NSString* query=@"delete from Session_Details";
    [appDelegateObject.databaseObject deleteFromDatabase:query];
    
    NSArray *InfoSplit=[self.CreatedDetailsInfo  componentsSeparatedByString:@" "];
    NSArray *expirationDetails=[self.sessionExpirationDetails componentsSeparatedByString:@" "];
   // NSLog(@"%@",CreatedDetailsInfo  );
    if ([InfoSplit count]>0)
    {
        
        NSString *Time=[InfoSplit objectAtIndex:1];
        NSString *Date=[InfoSplit objectAtIndex:0];
        
        NSString *expirationTime=[expirationDetails objectAtIndex:1];
        NSString *expirationDate=[expirationDetails objectAtIndex:0];
        
        
        
        self.CreatedUserName=appDelegateObject.CurrentUserName;
        NSString *query=[NSString stringWithFormat:@"insert into Session_Details ('Time','Date','User_ID','Session_Name','Session_Code','User_Name','Session_Expiration_Date','Session_Expiration_Time','Session_Has_Expired') values ('%@','%@','%d','%@','%@','%@','%@','%@','%@')",Time,Date,self.User_ID,self.Scene_Name,self.SessionCode,self.CreatedUserName,expirationDate,expirationTime,self.sessionExpirationStatus];
        NSLog(@"%@",query);
        
        [appDelegateObject.databaseObject insertIntoDatabase:query];
        
        
        [self SendNotificationsAfterSessionCreateAPI:@"Success"];
        
    }
    
}
-(void)SetJoinDetailsToDataBase
{
    
    NSArray *InfoSplit=[self.CreatedDetailsInfo  componentsSeparatedByString:@" "];
    if ([InfoSplit count]>0)
    {
        //bgBLwrplyCkJYtG3
        NSLog(@"%@infosplit",InfoSplit);
        
        NSString *Time=[InfoSplit objectAtIndex:1];
        NSString *Date=[InfoSplit objectAtIndex:0];
        
        NSString *query=[NSString stringWithFormat:@"insert into Join_Details ('Time','Date','User_ID','Session_Code') values ('%@','%@','%d','%@')",Time,Date,appDelegateObject.CurrentUserID,self.SessionCode];
        
        
        [appDelegateObject.databaseObject insertIntoDatabase:query];
        [self SendNotificationsAfterJoinAPI:@"Success"];
    }
    else
    {
        [self SendNotificationsAfterJoinAPI:@"Failed"];
        
    }
    
    
    
}
-(void)SetSearchSessionResultToDataBase
{
    if ([self.SearchSessionDetailsHolder count]==0)
    {
        // [self SendNotificationsAfterOpenAPI:@"Failed"];
        return;
    }
    else
    {
        NSString *DeleteQuery=@"Delete from Searchsession_Details";
        [appDelegateObject.databaseObject deleteFromDatabase:DeleteQuery];
        
        for (int i=0; i<[self.SearchSessionDetailsHolder count]; i++)
        {
            
            
            
            
            
            
            NSArray *details=[self.SearchSessionDetailsHolder objectAtIndex:i];
            
            NSString *Session_Code=[details objectAtIndex:0];
            NSString *Session_name=[details objectAtIndex:1];
            NSString *DateDetails=[details objectAtIndex:2];
            NSArray *InfoSplit=[DateDetails  componentsSeparatedByString:@" "];
            NSString *CreatedTime=[InfoSplit objectAtIndex:1];
            NSString *SessionCreatedDate=[InfoSplit objectAtIndex:0];
            NSString *session_created_USERID=[details objectAtIndex:3];
            NSString *session_Created_USERNAME=[details objectAtIndex:4];
            NSString *ExpiryDetails=[details objectAtIndex:5];
            NSArray *InfoSplitExpiry=[ExpiryDetails  componentsSeparatedByString:@" "];
            NSString *ExpiryDate=[InfoSplitExpiry objectAtIndex:1];
            NSString *ExpiryTime=[InfoSplitExpiry objectAtIndex:0];
            NSString *ExpiryStatus=[details objectAtIndex:6];
            
            
            // NSLog(@"%@",self.created_userid);
            NSString *query=[NSString stringWithFormat:@"insert into Searchsession_Details ('created_user_id','user_id','time','Date','username','Session_Code','Session_Name','Session_Expiry_Date','Session_Expiry_Time','Session_Expiry_Status') values ('%@','%d','%@','%@','%@','%@','%@','%@','%@','%@')",session_created_USERID,appDelegateObject.CurrentUserID,CreatedTime,SessionCreatedDate,session_Created_USERNAME,Session_Code,Session_name,ExpiryDate,ExpiryTime,ExpiryStatus];
            
            
            [appDelegateObject.databaseObject insertIntoDatabase:query];
        }
        [self SendNotificationsAfterJoinSearchAPI:@"Success"];
    }
    
    
}


-(void)SendNotificationsAfterSessionCreateAPI:(NSString*)Status
{
    NSDictionary* dict = [NSDictionary dictionaryWithObject:Status forKey:@"Status"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SessionCreateParsingCompleted" object:self userInfo:dict];
}
-(void)SendNotificationsAfterJoinAPI:(NSString*)Status
{
    NSDictionary* dict = [NSDictionary dictionaryWithObject:Status forKey:@"Status"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"JoinDetailsParsingCompleted" object:self userInfo:dict];
}
-(void)SendNotificationsAfterJoinSearchAPI:(NSString*)Status
{
    NSDictionary* dict = [NSDictionary dictionaryWithObject:
                          Status
                                                     forKey:@"Status"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"JoinSearchParsingCompleted" object:self userInfo:dict];
}



-(void) ShowAlertMessage:(NSString*)Title Message:(NSString*)message
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:Title message:message delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
}



@end
