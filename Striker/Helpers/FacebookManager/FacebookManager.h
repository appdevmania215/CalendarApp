//
//  FacebookManager.h
//  Striker
//
//  Created by Dzianis Asanovich on 9/29/14.
//  Copyright (c) 2014 Dzianis Asanovich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@class LoginViewController;

@interface FacebookManager : NSObject

@property (nonatomic, strong) LoginViewController * loginViewController;

+ (FacebookManager*) sharedInstance;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

@end
