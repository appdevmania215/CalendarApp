#import "MatchPopupViewController.h"
#import "MBProgressHUD.h"
#import "RequestsManager.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+Resize.h"
#import "ChatViewController.h"

@interface MatchPopupViewController ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *betLabel;
@property (strong, nonatomic) IBOutlet UIButton *confirmedButton;

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation MatchPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_isSubmitted)
        _titleLabel.text = NSLocalizedString(@"Submitted", @"");
    else
        _titleLabel.text = NSLocalizedString(@"Received", @"");
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString: _match[@"date"]];
    
    NSString * descriptionStr = _match[@"location"];
    
    [dateFormatter setDateFormat:@"EEEE"];
    
    descriptionStr = [NSString stringWithFormat: @"%@\n%@", descriptionStr, [dateFormatter stringFromDate: dateFromString]];
    
    dateFormatter.dateFormat=@"dd MMMM yyyy";
    
    descriptionStr = [NSString stringWithFormat: @"%@\n%@", descriptionStr, [[dateFormatter stringFromDate: dateFromString] capitalizedString]];
    NSString * amPmString = [_match[@"am"] intValue] == 1 ? @"AM" : @"PM";
    
    descriptionStr = [NSString stringWithFormat: @"%@\n%@", descriptionStr, amPmString];
    
    _descriptionLabel.text = descriptionStr;
    
    NSString * confirmedString = [_match[@"confirmed"] isKindOfClass: [NSNull class]] ? NSLocalizedString(@"Not Confirmed", @"") : NSLocalizedString(@"Confirmed", @"");
    [_confirmedButton setTitle: confirmedString forState: UIControlStateNormal];
    
    NSString * betString = [_match[@"bet"] isKindOfClass: [NSNull class]] ? @"" : [NSString stringWithFormat:@"$%@", _match[@"bet"]];
    _betLabel.text = betString;
    [self updateAvatar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSString*)formatedStringByDateString: (NSString*) dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:dateString];
    
    dateFormatter.dateFormat=@"dd MMM yyyy";
    NSString * newDateString = [[dateFormatter stringFromDate: dateFromString] capitalizedString];
    
    return newDateString;
}

-(IBAction)confirmClick:(id)sender
{
    if (!_isSubmitted && [_confirmedButton.currentTitle isEqualToString: NSLocalizedString(@"Not Confirmed", @"")])
    {
        [MBProgressHUD showHUDAddedTo: self.view animated:YES];
        [RequestsManager confirmRequest: _match[@"token"] withAnswer:^(NSString * error, NSDictionary * answer) {
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            if (error)
            {
                [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            else
            {
                //[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Done", @"") message: NSLocalizedString(@"Match was confirmed!", @"") delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
                _isSubmitted = YES;
                [_confirmedButton setTitle: NSLocalizedString(@"Confirmed", @"") forState: UIControlStateNormal];
                _match[@"confirmed"] = answer[@"confirmed"];
                [self updateAvatar];
                [self addCheckMark];
                [self.delegate onOpenChat:_match isSubmitted:NO];
                [self dismissPopUpViewController];
                /*ChatViewController * chatviewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                chatviewcontroller.is_sender = 0;
                chatviewcontroller.confirmed_id = [_match[@"confirmed"] intValue];
                
                chatviewcontroller.match = _match;
                chatviewcontroller.isSubmitted = NO;
                [self.navigationController pushViewController:chatviewcontroller animated:YES];*/

                
                
            }
        }];
    }
}

-(void) updateAvatar
{
    if ([_match[@"avatar"] isKindOfClass: [NSString class]] && [_match[@"avatar"] length])
    {
        [_avatarImageView setImageWithURL: [NSURL URLWithString: _match[@"avatar"]]];
    }
    else
    {
        if ([_match[@"facebook_id"] isKindOfClass: [NSNull class]])
            return;
        if ([_match[@"facebook_id"] length] && [_confirmedButton.currentTitle isEqualToString: NSLocalizedString(@"Confirmed", @"")])
        {
            NSString * avatarUrl = [NSString stringWithFormat: @"http://graph.facebook.com/%@/picture?width=150&height=150", _match[@"facebook_id"]];
            [_avatarImageView setImageWithURL: [NSURL URLWithString:avatarUrl]];
        }
    }
}

-(void) addCheckMark
{
    UILabel * yellowCheckMark = [[UILabel alloc] initWithFrame: CGRectMake((self.view.superview.width - 50)/2, 0, 50, 50)];
    yellowCheckMark.y = self.view.y + self.view.height + 10;
    yellowCheckMark.font = [UIFont systemFontOfSize: 20];
    yellowCheckMark.backgroundColor = [UIColor yellowColor];
    yellowCheckMark.layer.cornerRadius = 25;
    yellowCheckMark.layer.masksToBounds = YES;
    yellowCheckMark.textAlignment = NSTextAlignmentCenter;
    yellowCheckMark.text = @"✓";
    
    [self.view.superview addSubview: yellowCheckMark];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_dismissDelegate dismissDayPopupViewController: nil withStatus: nil city:nil duration:0];
    });
}

@end
