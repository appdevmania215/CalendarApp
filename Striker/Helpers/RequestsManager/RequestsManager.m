//
//  RequestsProxy.m
//  StateManagerTest
//
//  Created by Dzianis Asanovich on 10/24/13.
//  Copyright (c) 2013 Dzianis Asanovich. All rights reserved.
//

#import "RequestsManager.h"
#import "AFJSONRequestOperation.h"
#import "AppDelegate.h"
#import "NSString+MD5.h"
#import "NSString+UrlEncode.h"
#import "AFHTTPRequestOperationManager.h"

#define mainUrl @"http://striker-semanggi.rhcloud.com/api/ios_index.php"

//#define mainUrl @"http://classicsolitaire.co.uk/striker/ios_index.php"

@implementation RequestsManager

+ (RequestsManager*) sharedInstance
{
    static RequestsManager* requestsManager = nil;
    static dispatch_once_t predicate;
    dispatch_once( &predicate, ^{
        requestsManager = [[self alloc] init];
    });
    return requestsManager;
}


+(void) loginUserWithEmail: (NSString*) email andPassword: (NSString*) password withAnswer: (AnswerDictionaryBlock) answer
{
    NSString * body = [NSString stringWithFormat:@"user_email=%@&user_password=%@",
                       [email urlencode],
                       [password MD5]
                       ];
    [RequestsManager loginWithBody: body andAnswer: answer];
}


+(void) loginUserWithFacebook: (NSDictionary*) facebookData withAnswer: (AnswerDictionaryBlock) answer;
{
    NSString * facebookId = facebookData[@"id"];
    NSString * email = facebookData[@"email"];
    NSString * name = facebookData[@"name"];
    
    NSString * body = [NSString stringWithFormat:@"user_facebook_id=%@", [facebookId urlencode]];
    body = [NSString stringWithFormat: @"%@&user_bio=%@", body, [name urlencode]];
    if (email.length > 0)
    {
        body = [NSString stringWithFormat: @"%@&user_email=%@", body, [email urlencode]];
    }
    
    [RequestsManager loginWithBody: body andAnswer: answer];
}


+(void) loginWithBody: (NSString*) body andAnswer: (AnswerDictionaryBlock) answer
{
    NSString * url = [NSString stringWithFormat:@"%@?function=login&%@", mainUrl, [self getApplicationKey]];
    
    [self callRequestForUrl: url andBody: body andAnswer: answer];
}

+(void) UpdateUserInfo: (NSDictionary*) data withAnswer: (AnswerDictionaryBlock) answer
{
    NSString * url = [NSString stringWithFormat:@"%@?function=editUser&%@", mainUrl, [self getApplicationKey]];
    
    NSString * body = @"";
    for( NSString *aKey in [data allKeys] )
    {
        body = [NSString stringWithFormat: @"%@%@=%@&", body, [aKey urlencode], [[data objectForKey: aKey] urlencode]];
    }
    
    if ([body length] > 0)
    {
        body = [body substringToIndex:[body length] - 1];
    }
    
    [self callRequestForUrl: url andBody: body andAnswer: answer];
}

+(void) getCalendar: (NSString*) userId withAnswer: (AnswerArrayBlock) answer
{
    NSString * url = [NSString stringWithFormat:@"%@?function=getCalendar&%@", mainUrl, [self getApplicationKey]];

    [self callRequestForUrl: url andBody: [NSString stringWithFormat:@"user_id=%@", userId] andAnswer: answer];
}

+(void) setCalendarDay: (NSDate*) day forUser: (NSString*) userId withDayTime: (int) dayTime city:(NSString*) city duration: (int) duration withAnswer: (AnswerDictionaryBlock) answer
{
    NSString * url = [NSString stringWithFormat:@"%@?function=editCalendar&%@", mainUrl, [self getApplicationKey]];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat=@"yyyy-MM-dd";
    NSString * formatedDay = [[dateFormatter stringFromDate: day] capitalizedString];
    
    NSString * body = [NSString stringWithFormat: @"user_id=%@&day=%@&dayTime=%d&city=%@&duration=%d", userId, [formatedDay urlencode], dayTime, [city urlencode], duration];
    
    [self callRequestForUrl: url andBody: body andAnswer: answer];
}

+(void) getLocations: (NSString*) userId withAnswer: (AnswerArrayBlock) answer
{
    NSString * url = [NSString stringWithFormat:@"%@?function=getLocations&%@", mainUrl, [self getApplicationKey]];
    
    [self callRequestForUrl: url andBody: [NSString stringWithFormat:@"user_id=%@", userId] andAnswer: answer];
}

+(void) setLocations: (NSArray*) locations forUser: (NSString*) userId withAnswer: (AnswerDictionaryBlock) answer;
{
    NSString * url = [NSString stringWithFormat:@"%@?function=setLocations&%@", mainUrl, [self getApplicationKey]];
    
    NSString * body = [NSString stringWithFormat: @"user_id=%@&locations=", userId];
    for (NSString * location in locations)
    {
        body = [NSString stringWithFormat: @"%@%@|", body, [location urlencode]];
    }
    if ([body length] > 0)
        body = [body substringToIndex:[body length] - 1];
    
        
    [self callRequestForUrl: url andBody: body andAnswer: answer];
}

+(void) resendInvitation: (NSString*) candidateId forRequest:(NSString*) requestId withAnswer: (AnswerArrayBlock) answer
{
    NSString * url = [NSString stringWithFormat:@"%@?function=resendInvitation&%@", mainUrl, [self getApplicationKey]];
    
    NSString * body = [NSString stringWithFormat: @"user_id=%@&request_id=%@", candidateId, requestId];
    
    [self callRequestForUrl: url andBody: body andAnswer: answer];
}

+(void) getStrikes: (NSString*) userId withAnswer: (AnswerDictionaryBlock) answer
{
    NSString * url = [NSString stringWithFormat:@"%@?function=getAllStrikes&%@", mainUrl, [self getApplicationKey]];
    
    [self callRequestForUrl: url andBody: [NSString stringWithFormat:@"user_id=%@", userId] andAnswer: answer];
}

+(void) getChatHistory: (int) confirmed_id is_sender:(int) is_sender withAnswer: (AnswerDictionaryBlock) answer
{
    NSString * url = [NSString stringWithFormat:@"%@?function=getChatHistory&%@", mainUrl, [self getApplicationKey]];
    
    [self callRequestForUrl: url andBody: [NSString stringWithFormat:@"confirmed_id=%d&is_sender=%d", confirmed_id, is_sender] andAnswer: answer];
}
+(void) getLatestChat: (int) confirmed_id is_sender:(int) is_sender withAnswer: (AnswerDictionaryBlock) answer
{
    NSString * url = [NSString stringWithFormat:@"%@?function=getLatestChat&%@", mainUrl, [self getApplicationKey]];
    
    [self callRequestForUrl: url andBody: [NSString stringWithFormat:@"confirmed_id=%d&is_sender=%d", confirmed_id, is_sender] andAnswer: answer];
}
+(void) sendChat: (int) confirmed_id is_sender:(int) is_sender text: (NSString*) text withAnswer: (AnswerDictionaryBlock) answer
{
    NSString * url = [NSString stringWithFormat:@"%@?function=sendChat&%@", mainUrl, [self getApplicationKey]];
    
    [self callRequestForUrl: url andBody: [NSString stringWithFormat:@"confirmed_id=%d&is_sender=%d&Text=%@", confirmed_id, is_sender, [text urlencode]] andAnswer: answer];
}

+(void) confirmRequest: (NSString*) token withAnswer: (AnswerDictionaryBlock) answer
{
    NSString * url = [NSString stringWithFormat:@"%@?function=confirmRequest&%@", mainUrl, [self getApplicationKey]];
    
    NSString * body = [NSString stringWithFormat: @"token=%@", token];
    
    [self callRequestForUrl: url andBody: body andAnswer: answer];
}

+(void) addRequestForUser: (NSString*) userId withDate: (NSDate *) date withLocation: (NSString *) location withBet: (NSString *) bet isAM: (NSString *) isAM  withAnswer: (AnswerDictionaryBlock) answer
{
    NSString * url = [NSString stringWithFormat:@"%@?function=addNewRequest&%@", mainUrl, [self getApplicationKey]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat=@"yyyy:MM:dd";
    NSString * formatedDay = [[dateFormatter stringFromDate: date] capitalizedString];
    
    NSString * body = [NSString stringWithFormat: @"user_id=%@&date=%@&location=%@&bet=%@&am=%@",
                       userId, [formatedDay urlencode], [location urlencode], bet, isAM];
    
    [self callRequestForUrl: url andBody: body andAnswer: answer];
}

+(void) AddAvatar: (NSData*) image forId: (NSString*) userId withAnswer:(AnswerDictionaryBlock)answer
{
    NSString * url = [NSString stringWithFormat:@"%@?function=updateAvatar&user_id=%@&%@", mainUrl, userId, [self getApplicationKey]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:url parameters: nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         [formData appendPartWithFileData: image name: @"avatar" fileName: [NSString stringWithFormat: @"%@.jpg", @"avatar"] mimeType: @"image/jpeg"];
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSNumber * isSuccess = [responseObject objectForKey:@"success"];
         if (![isSuccess boolValue])
         {
             NSString * errorMessage = [self getErrorWithAnswer:responseObject];
             answer(errorMessage, nil);
         }
         else
         {
             answer(nil, [responseObject objectForKey: @"data"]);
         }
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         answer(NSLocalizedString(@"Server unavailable. Check internet connection", @""), nil);
     }];
}

+(void)callRequestForUrl: (NSString*) url andBody: (NSString *) body andAnswer: (AnswerBlock) answer
{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]];
    
    if (body)
    {
        request.HTTPMethod = @"POST";
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    }
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest: request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         NSNumber * isSuccess = [JSON objectForKey:@"success"];
         if (![isSuccess boolValue])
         {
             NSString * errorMessage = [JSON objectForKey:@"message"];;
             answer(errorMessage, nil);
         }
         else
         {
             answer(nil, [JSON objectForKey: @"data"]);
         }
     }
     failure:^(NSURLRequest *request , NSURLResponse *response , NSError *error , id JSON)
     {
         answer(NSLocalizedString(@"Server unavailable. Check internet connection", @""), nil);
     }];
    
    [operation start];
}

+(NSString*) getErrorWithAnswer: (NSDictionary *) JSON
{
    NSString * errorMessage = nil;
    if ([[JSON objectForKey:@"message"] isEqualToString:@"Error with: Wrong Password"])
    {
        errorMessage = NSLocalizedString(@"Server decline request by security reasons. Please, check your datetime", @"");
    }
    else if ([[JSON objectForKey:@"message"] isEqualToString:@"Password is incorrect"])
    {
        errorMessage = NSLocalizedString(@"Password is incorrect", @"");
    }
    else if ([[JSON objectForKey:@"message"] isEqualToString:@"Please, use facebook login for this account"])
    {
        errorMessage = NSLocalizedString(@"Please, use facebook login for this account", @"");
    }
    else if ([[JSON objectForKey:@"message"] isEqualToString:@"User with this e-mail already exists"])
    {
        errorMessage = NSLocalizedString(@"User with this e-mail already exists", @"");
    }
    else if ([[JSON objectForKey:@"message"] isEqualToString:@"This request already exists"])
    {
        errorMessage = NSLocalizedString(@"This request already exists", @"");
    }
    else if ([[JSON objectForKey:@"message"] isEqualToString:@"Request already confirmed"])
    {
        errorMessage = NSLocalizedString(@"Request already confirmed", @"");
    }
    else
    {
        errorMessage = NSLocalizedString(@"Server error", @"");
    }
    return errorMessage;
}

+(NSString*) getApplicationKey
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMM"];
    [dateFormatter setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
    NSString *token= [dateFormatter stringFromDate: [NSDate date]];
    token = [token stringByAppendingString:@"strikerkey"];
    return [NSString stringWithFormat:@"application_key=%@", [token MD5]];
}

@end
