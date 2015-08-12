#import <UIKit/UIKit.h>
#import "UIViewController+ENPopUp.h"
#import "CalendarViewController.h"

@interface NewRequestViewController : UIViewController <DismissDayPopupViewController>

@property (strong, nonatomic) IBOutlet UIButton *dateButton;
@property (strong, nonatomic) IBOutlet UIButton *locationButton;
@property (strong, nonatomic) IBOutlet UIButton *ampmButton;
@property (strong, nonatomic) IBOutlet UIButton *maxBetButton;
@property (nonatomic, strong) NSString *senderName;
@property (nonatomic, strong) NSArray * calendarDays;
@property (strong, nonatomic) NSString * userId;

- (IBAction)dateClick:(id)sender;
- (IBAction)locationClick:(id)sender;
- (IBAction)ampmClick:(id)sender;
- (IBAction)maxBetClick:(id)sender;
- (IBAction)submitClick:(id)sender;

-(void) dismissDayPopupViewController: (NSDate*) date withStatus: (NSNumber *) status city:(NSString*)city duration:(int)duration;

@end
