#import "MatchViewController.h"
#import "UIImageView+AFNetworking.h"
#import "RequestsManager.h"
#import "MBProgressHUD.h"

@interface MatchViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *betLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation MatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Match", @"");
    
    if ([_matchedPerson[@"avatar"] length])
    {
        [_avatarImageView setImageWithURL: [NSURL URLWithString: _matchedPerson[@"avatar"]]];
    }
    else if ([_matchedPerson[@"facebook_id"] length])
    {
        NSString * avatarUrl = [NSString stringWithFormat: @"http://graph.facebook.com/%@/picture?width=150&height=150", _matchedPerson[@"facebook_id"]];
        [_avatarImageView setImageWithURL: [NSURL URLWithString:avatarUrl]];
    }
    _nameLabel.text = _matchedPerson[@"bio"];
    _betLabel.text = [NSString stringWithFormat:@"$%@", _matchedPerson[@"bet"]];
    
    NSString * descriptionStr = _locationMatch;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    
    descriptionStr = [NSString stringWithFormat: @"%@\n%@", descriptionStr, [dateFormatter stringFromDate: _dateMatch]];
    
    dateFormatter.dateFormat=@"dd MMMM yyyy";
    
    descriptionStr = [NSString stringWithFormat: @"%@\n%@", descriptionStr, [[dateFormatter stringFromDate: _dateMatch] capitalizedString]];
    descriptionStr = [NSString stringWithFormat: @"%@\n%@", descriptionStr, _amPmMatch];
    
    _descriptionLabel.text = descriptionStr;
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
- (IBAction)submitReminderClick:(id)sender
{
    [MBProgressHUD showHUDAddedTo: self.view animated:YES];
    [RequestsManager resendInvitation: _matchedPerson[@"user_id"] forRequest: _matchedPerson[@"request_id"] withAnswer:^(NSString * error, NSArray * array) {
        [MBProgressHUD hideHUDForView: self.view animated: YES];
        if (error)
        {
            [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Done", @"") message: NSLocalizedString(@"One more e-mail was sent to matched person.", @"") delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        }
    }];
}


@end
