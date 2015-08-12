#import <UIKit/UIKit.h>
#import "CalendarViewController.h"

@interface DayPopupViewController : UIViewController<UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate>
{
    BOOL keyboardIsShowing;
    CGFloat keyboardHeight;
}

@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * userId;

@property (nonatomic) int status;

@property (nonatomic) BOOL multipleSelection;

@property (nonatomic, weak) id <DismissDayPopupViewController> dismissDelegate;

@property (nonatomic) BOOL amEnabled;
@property (nonatomic) BOOL pmEnabled;
@property (nonatomic) NSString * city;
@property (nonatomic) NSMutableArray* stateArray;
@end
