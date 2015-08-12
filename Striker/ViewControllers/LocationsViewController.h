#import <UIKit/UIKit.h>

typedef void (^ AnswerChoosedLocation)(NSString* answer);

@interface LocationsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray * checkedLocations;
@property (nonatomic) BOOL multipleSelection;
@property (nonatomic, strong) AnswerChoosedLocation answerBlock;
@property (nonatomic) NSString* city;
@end
