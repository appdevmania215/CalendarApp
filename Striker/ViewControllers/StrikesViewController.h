#import <UIKit/UIKit.h>
#import "CalendarViewController.h"
#import "MatchPopupViewController.h"
@interface StrikesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, DismissDayPopupViewController, MatchPopupViewControllerDelegate>

@property (nonatomic, strong) NSArray * submitted;
@property (nonatomic, strong) NSMutableArray * received;

@property (nonatomic, strong) NSArray * calendarDays;
@property (nonatomic, strong) NSString * userId;

-(void) dismissDayPopupViewController: (NSDate*) date withStatus: (NSNumber *) status city:(NSString*)city duration:(int)duration;

@end
