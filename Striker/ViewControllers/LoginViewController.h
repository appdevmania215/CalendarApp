#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

-(void) facebookLoginData: (NSDictionary*) facebookData andError: (NSError *) error;

@end
