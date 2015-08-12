#import <UIKit/UIKit.h>
#import "CalendarViewController.h"

@protocol MatchPopupViewControllerDelegate <NSObject>

- (void) onOpenChat:(NSMutableDictionary *) match isSubmitted:(BOOL)isSubmitted;

@end
@interface MatchPopupViewController : UIViewController

@property (weak, nonatomic) id<MatchPopupViewControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableDictionary * match;
@property (nonatomic) BOOL isSubmitted;

@property (nonatomic, weak) id <DismissDayPopupViewController> dismissDelegate;

@end
