//
//  RequestsProxy.h
//  StateManagerTest
//
//  Created by Dzianis Asanovich on 10/24/13.
//  Copyright (c) 2013 Dzianis Asanovich. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ AnswerDictionaryBlock)(NSString*, NSDictionary *);
typedef void (^ AnswerArrayBlock)(NSString*, NSArray *);
typedef void (^ AnswerStringBlock)(NSString*, NSString *);

typedef void (^ AnswerBlock)(NSString*, id);


@interface RequestsManager : NSObject

+ (RequestsManager*) sharedInstance;

+(void) loginUserWithEmail: (NSString*) email andPassword: (NSString*) password withAnswer: (AnswerDictionaryBlock) answer;
+(void) loginUserWithFacebook: (NSDictionary*) facebookData withAnswer: (AnswerDictionaryBlock) answer;
+(void) loginWithBody: (NSString*) body andAnswer: (AnswerDictionaryBlock) answer;

+(void) UpdateUserInfo: (NSDictionary*) data withAnswer: (AnswerDictionaryBlock) answer;

+(void) getCalendar: (NSString*) userId withAnswer: (AnswerArrayBlock) answer;
+(void) setCalendarDay: (NSDate*) day forUser: (NSString*) userId withDayTime: (int) dayTime city:(NSString*)city duration:(int) duration withAnswer: (AnswerDictionaryBlock) answer;

+(void) getLocations: (NSString*) userId withAnswer: (AnswerArrayBlock) answer;
+(void) setLocations: (NSArray*) locations forUser: (NSString*) userId withAnswer: (AnswerDictionaryBlock) answer;

+(void) resendInvitation: (NSString*) candidateId forRequest:(NSString*) requestId withAnswer: (AnswerArrayBlock) answer;
+(void) getStrikes: (NSString*) userId withAnswer: (AnswerDictionaryBlock) answer;
+(void) confirmRequest: (NSString*) token withAnswer: (AnswerDictionaryBlock) answer;

+(void) addRequestForUser: (NSString*) userId withDate: (NSDate *) date withLocation: (NSString *) location withBet: (NSString *) bet isAM: (NSString *) isAM withAnswer: (AnswerDictionaryBlock) answer;

+(void) AddAvatar: (NSData*) image forId: (NSString*) userId withAnswer:(AnswerDictionaryBlock)answer;
+(void) getChatHistory: (int) confirmed_id is_sender:(int) is_sender withAnswer: (AnswerDictionaryBlock) answer;
+(void) sendChat: (int) confirmed_id is_sender:(int) is_sender text: (NSString*) text withAnswer: (AnswerDictionaryBlock) answer;
+(void) getLatestChat: (int) confirmed_id is_sender:(int) is_sender withAnswer: (AnswerDictionaryBlock) answer;
@end
