#import <UIKit/UIKit.h>

@interface MatchViewController : UIViewController

@property (nonatomic, strong) NSDictionary * matchedPerson;

@property (nonatomic, strong) NSDate * dateMatch;
@property (nonatomic, strong) NSString * locationMatch;
@property (nonatomic, strong) NSString * amPmMatch;
@property (nonatomic, strong) NSString * requestId;

@end
