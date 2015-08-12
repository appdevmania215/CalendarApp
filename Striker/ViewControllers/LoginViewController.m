#import "LoginViewController.h"
#import "ProfileViewController.h"
#import "FacebookManager.h"
#import "RequestsManager.h"
#import "MBProgressHUD.h"
#import "NSString+Email.h"


@interface LoginViewController ()
{
    NSDictionary * userData;
}

@property (nonatomic, strong) IBOutlet UITextField * emailTextField;
@property (nonatomic, strong) IBOutlet UITextField * passwordTextField;

- (IBAction) loginClick:(id)sender;
- (IBAction) loginUsingFacebookClick:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [FacebookManager sharedInstance].loginViewController = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginUsingFacebookClick:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_location"] allowLoginUI:YES completionHandler: ^(FBSession *session, FBSessionState state, NSError *error) {
        NSLog(@"error");
         [[FacebookManager sharedInstance] sessionStateChanged:session state:state error:error];
     }];
}

- (IBAction) loginClick:(id)sender
{
    if (!_emailTextField.text.length)
    {
        [[[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Please enter email",@"") delegate:nil  cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        return;
    }
    else if (!_passwordTextField.text.length)
    {
        [[[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Please enter password",@"") delegate:nil  cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        return;
    }
    //NSString * email = _emailTextField.text;
    //BOOL isVal = [email IsValidEmail];
    if (![_emailTextField.text IsValidEmail])
    {
        [[[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Email is invalid",@"") delegate:nil  cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [RequestsManager loginUserWithEmail: _emailTextField.text andPassword: _passwordTextField.text withAnswer:^(NSString * error, NSDictionary * answer) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error)
        {
            [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error",@"") message:error delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        }
        else
        {
            userData = answer;
            [[NSUserDefaults standardUserDefaults] setObject: answer forKey: @"me"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self afterLogin];
        }
    }];
}

-(void) facebookLoginData: (NSDictionary*) facebookData andError: (NSError *) error
{
    if (error)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error",@"") message: error.localizedDescription delegate: nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else
    {
        [RequestsManager loginUserWithFacebook: facebookData withAnswer:^(NSString * error, NSDictionary * answer) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error)
            {
                [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message:error delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
            }
            else
            {
                NSMutableDictionary * enjoyedData = [answer mutableCopy];
                [enjoyedData setObject: facebookData[@"name"] forKey: @"name"];
                if (facebookData[@"location"][@"name"])
                {
                    NSString * location = facebookData[@"location"][@"name"];
                    [enjoyedData setObject: location forKey: @"location_facebook"];
                }
                userData = enjoyedData;
                
                [[NSUserDefaults standardUserDefaults] setObject: answer forKey: @"me"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self afterLogin];
            }
        }];
    }
}

-(void) afterLogin
{
    if (userData[@"created"])
    {
        [self performSegueWithIdentifier:@"showWelcomeSegue" sender:nil];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [RequestsManager getCalendar: userData[@"id"] withAnswer:^(NSString * error, NSArray * answer) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error)
            {
                [[[UIAlertView alloc] initWithTitle: @"Error" message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject: answer forKey: @"calendar"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self performSegueWithIdentifier:@"showCalendarSegue" sender:nil];
                
            }
        }];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

/*- (IBAction)textFinished:(UITextField *)textField {
    [textField resignFirstResponder];
}*/



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
