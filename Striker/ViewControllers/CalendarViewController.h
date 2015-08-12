#import <UIKit/UIKit.h>
#import "UIViewController+ENPopUp.h"

@protocol DismissDayPopupViewController <NSObject>

-(void) dismissDayPopupViewController: (NSDate*) date withStatus: (NSNumber *) status city:(NSString*) city duration:(int) duration;

@end


@interface CalendarViewController : UIViewController <DismissDayPopupViewController>

-(void) dismissDayPopupViewController: (NSDate*) date withStatus: (NSNumber *) status city:(NSString*) city duration:(int) duration;


@end
