//
//  FacebookManager.m
//  Striker
//
//  Created by Dzianis Asanovich on 9/29/14.
//  Copyright (c) 2014 Dzianis Asanovich. All rights reserved.
//

#import "FacebookManager.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"

@implementation FacebookManager

+ (FacebookManager*) sharedInstance
{
    static FacebookManager* facebookManager = nil;
    static dispatch_once_t predicate;
    dispatch_once( &predicate, ^{
        facebookManager = [[self alloc] init];
    } );
    return facebookManager;
}


- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        [MBProgressHUD hideHUDForView: _loginViewController.view animated:YES];

        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = NSLocalizedString(@"Something went wrong", @"");
            alertText = [FBErrorUtility userMessageForError:error];
            [[[UIAlertView alloc] initWithTitle: alertTitle message: alertText delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = NSLocalizedString(@"Session Error",@"");
                alertText = NSLocalizedString(@"Your current session is no longer valid. Please log in again.",@"");
                [[[UIAlertView alloc] initWithTitle: alertTitle message: alertText delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
            } else {
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                alertTitle = NSLocalizedString(@"Something went wrong",@"");
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                            [[[UIAlertView alloc] initWithTitle: alertTitle message: alertText delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{

}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        UINavigationController * navigationController = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        id loginVC = [navigationController topViewController];
        if ([loginVC isMemberOfClass: [LoginViewController class]])
        {
            [(LoginViewController*)loginVC facebookLoginData:result andError: error];
        }
    }];
}


@end
