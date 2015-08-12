#import "ProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+Resize.h"
#import "NSString+Email.h"
#import "RequestsManager.h"
#import "MBProgressHUD.h"
#import "ActionSheetStringPicker.h"
#import "CalendarViewController.h"
#import "NewRequestViewController.h"
#import "StrikesViewController.h"
#import "UIStoryboard+LDMain.h"
#import "UIActionSheet+Blocks.h"

typedef void (^ SuccessCalendarBlock)();

@interface ProfileViewController ()
{
    NSArray * calendarDays;
    NSDictionary * strikes;
}

@property (nonatomic, strong) IBOutlet UIImageView * avatarImageView;
@property (nonatomic, strong) IBOutlet UIImageView * verifiedImageView;
@property (nonatomic, strong) IBOutlet UILabel * nameLabel;
@property (nonatomic, strong) IBOutlet UILabel * locationLabel;

@property (nonatomic, strong) IBOutlet UITextField * bioTextField;
@property (nonatomic, strong) IBOutlet UITextField * emailTextField;
@property (nonatomic, strong) IBOutlet UITextField * bcTextField;
@property (nonatomic, strong) IBOutlet UITextField * idTextField;
@property (nonatomic, strong) IBOutlet UITextField * mobileTextField;
@property (nonatomic, strong) IBOutlet UITextField * addressTextField;

@property (nonatomic, strong) IBOutlet UIButton * cityButton;
@property (nonatomic, strong) IBOutlet UIButton * betButton;
@property (nonatomic, strong) IBOutlet UIButton * logoutButton;

@property (nonatomic, strong) IBOutlet UIScrollView * mainScrollView;

@property (nonatomic, strong) NSDictionary * userData;

@end

@implementation ProfileViewController

@synthesize userData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    userData = [[NSUserDefaults standardUserDefaults] objectForKey: @"me"];
    
    _nameLabel.text = userData[@"name"];
    _locationLabel.text = userData[@"location_facebook"];
    
    _bioTextField.text = userData[@"bio"];
    _emailTextField.text = userData[@"email"];
    _bcTextField.text = userData[@"bc_number"];
    _idTextField.text = userData[@"id_number"];
    _mobileTextField.text = userData[@"mobile"];
    _addressTextField.text = userData[@"address"];
    
    /*if ([userData[@"verified"] boolValue])
    {
        _verifiedImageView.image = [UIImage imageNamed:@"star_filled"];
    }*/
    
    [_cityButton setTitle: userData[@"city"] forState: UIControlStateNormal];
    [_betButton setTitle: userData[@"bet"] forState: UIControlStateNormal];
    
    _cityButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _betButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _logoutButton.layer.borderColor = [UIColor lightGrayColor].CGColor;

    if ([userData[@"avatar"] length])
    {
        [_avatarImageView setImageWithURL: [NSURL URLWithString: userData[@"avatar"]]];
    }
    else if ([userData[@"facebook_id"] length])
    {
        NSString * avatarUrl = [NSString stringWithFormat: @"http://graph.facebook.com/%@/picture?width=150&height=150", userData[@"facebook_id"]];
        [_avatarImageView setImageWithURL: [NSURL URLWithString:avatarUrl]];
    }
    [self updateStar];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) textChanged: (id) sender
{
    [self updateStar];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /*if (_emailTextField.text.length == 0 ||
        _bioTextField.text.length == 0 ||
        _bcTextField.text.length == 0 ||
        _idTextField.text.length == 0 ||
        _mobileTextField.text.length == 0 ||
        _addressTextField.text.length == 0
        )
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"") message: NSLocalizedString(@"Please, fill all fields", @"") delegate: nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return NO;
    }
    else*/ if (![_emailTextField.text IsValidEmail])
    {
        [[[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Email is invalid",@"") delegate:nil  cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        return NO;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [RequestsManager UpdateUserInfo: [self getDataFromForms] withAnswer:^(NSString * error, NSDictionary * answer) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error)
        {
            [[[UIAlertView alloc] initWithTitle: @"Error" message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
            [textField becomeFirstResponder];
        }
        else
        {
            self.userData = answer;
            [[NSUserDefaults standardUserDefaults] setObject: userData forKey: @"me"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self updateStar];
            //[[[UIAlertView alloc] initWithTitle: @"Complete" message: @"Data updated succesfully" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        }
    }];
    
    [textField resignFirstResponder];
    return YES;
}

- (void)keyboardDidShow: (NSNotification *) notif{
    CGSize keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _mainScrollView.height = self.view.height - keyboardSize.height-_mainScrollView.y;
}

- (void)keyboardDidHide: (NSNotification *) notif{
    _mainScrollView.height = self.view.height - _mainScrollView.y - 40;
}

-(NSDictionary*) getDataFromForms
{
    NSMutableDictionary * newDictionary = [NSMutableDictionary dictionary];
    newDictionary[@"user_bio"] = _bioTextField.text;
    newDictionary[@"user_email"] = _emailTextField.text;
    newDictionary[@"user_bc_number"] = _bcTextField.text;
    newDictionary[@"user_id_number"] = _idTextField.text;
    newDictionary[@"user_mobile"] = _mobileTextField.text;
    newDictionary[@"user_address"] = _addressTextField.text;
    if (userData[@"id"])
        newDictionary[@"user_id"] = userData[@"id"];
    
    return newDictionary;
}


- (void)geoNamesSearchController:(ILGeoNamesSearchController*)controller didFinishWithResult:(NSDictionary*)result
{
    [self dismissViewControllerAnimated:YES completion: nil];
    
    if(result) {
        NSString * locationName = [result objectForKey:kILGeoNamesAlternateNameKey];
        NSMutableDictionary * newDictionary = [[self getDataFromForms] mutableCopy];
        newDictionary[@"user_city"] = locationName;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [RequestsManager UpdateUserInfo: newDictionary withAnswer:^(NSString * error, NSDictionary * answer) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error)
            {
                [[[UIAlertView alloc] initWithTitle: @"Error" message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
            }
            else
            {
                //[[[UIAlertView alloc] initWithTitle: @"Complete" message: @"Data updated succesfully" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
                [_cityButton setTitle: locationName forState: UIControlStateNormal];
                NSMutableDictionary * newUserData = [userData mutableCopy];
                newUserData[@"city"] = locationName;
                userData = newUserData;
                [[NSUserDefaults standardUserDefaults] setObject: userData forKey: @"me"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self updateStar];
            }
        }];
    }
}

- (NSString*)geoNamesUserIDForSearchController:(ILGeoNamesSearchController*)controller {
    return @"ilgeonamessample";
}

-(IBAction) cityClick: (id)sender
{
    ILGeoNamesSearchController *searchController = [[ILGeoNamesSearchController alloc] init];
    searchController.delegate = self;
    
    searchController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:searchController animated:YES completion: nil];
}

-(IBAction) logoutClick: (id)sender
{
    [FBSession.activeSession closeAndClearTokenInformation];
    [self.navigationController popToRootViewControllerAnimated: YES];
}


-(IBAction) betClick: (id)sender
{
    NSMutableArray *bets = [NSMutableArray array];
    
    for (int i = 50; i <= 200; i=i+25)
    {
        [bets addObject: [NSString stringWithFormat: @"%d", i]];
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Bet" rows:bets initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
     {
         NSLog(@"Picker: %@", picker);
         
         NSMutableDictionary * newDictionary = [[self getDataFromForms] mutableCopy];
         
         newDictionary[@"user_bet"] = selectedValue;
         [MBProgressHUD showHUDAddedTo:self.view animated:YES];
         [RequestsManager UpdateUserInfo: newDictionary withAnswer:^(NSString * error, NSDictionary * answer) {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             if (error)
             {
                 [[[UIAlertView alloc] initWithTitle: @"Error" message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
             }
             else
             {
                 //[[[UIAlertView alloc] initWithTitle: @"Complete" message: @"Data updated succesfully" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
                 [_betButton setTitle: selectedValue forState: UIControlStateNormal];
                 
                 NSMutableDictionary * newUserData = [userData mutableCopy];
                 newUserData[@"bet"] = selectedValue;
                 userData = newUserData;
                 [[NSUserDefaults standardUserDefaults] setObject: userData forKey: @"me"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 [self updateStar];
             }
         }];
     }
     cancelBlock:^(ActionSheetStringPicker *picker)
     {
         NSLog(@"Block Picker Canceled");
     }
          origin:sender];
}


-(IBAction) calendarClick: (id)sender
{
    [self getCalendarRequest:^{
        [self performSegueWithIdentifier: @"showCalendarSegue" sender: self];
    }];
}

-(IBAction) strikesClick: (id)sender
{
    [self getCalendarRequest:^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [RequestsManager getStrikes: userData[@"id"] withAnswer:^(NSString * error, NSDictionary * answer) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error)
            {
                [[[UIAlertView alloc] initWithTitle: @"Error" message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
            }
            else
            {
                strikes = answer;
                //[self performSegueWithIdentifier: @"showCalendarSegue" sender: self];
                [self performSegueWithIdentifier: @"showStrikesSegue" sender: self];
            }
        }];
    }];
}

-(IBAction)newRequestClick:(id)sender
{
    [self getCalendarRequest:^{
        [self performSegueWithIdentifier: @"showNewRequestSegue" sender: self];
    }];
}

-(IBAction)updateAvatarClick:(id)sender
{
    [UIActionSheet showInView:self.view withTitle: NSLocalizedString(@"Select image from",@"") cancelButtonTitle: NSLocalizedString(@"Cancel",@"") destructiveButtonTitle: nil otherButtonTitles:@[NSLocalizedString(@"Camera",@""), NSLocalizedString(@"Gallery",@"")] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex)
     {
         if (buttonIndex == 1)
         {
             //currentChoosedPicker = 0;
             if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
             {
                 UIImagePickerController *vc = [UIImagePickerController new];
                 vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                 vc.delegate = self;
                 
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                     [self presentViewController:vc animated:YES completion:nil];
                 });
             }
             else
             {
                 [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Gallery unavailable", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
             }
         }
         else if (buttonIndex == 0)
         {
             //currentChoosedPicker = 0;
             if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
             {
                 UIImagePickerController *vc = [UIImagePickerController new];
                 vc.sourceType = UIImagePickerControllerSourceTypeCamera;
                 vc.delegate = self;
                 
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                     [self presentViewController:vc animated:YES completion:nil];
                 });
             }
             else
             {
                 [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Camera unavailable", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
             }
         }
         
     }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage;
    NSData *data = nil;
    
    originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (originalImage.size.width > 640 || originalImage.size.height > 640)
        originalImage = [self resizeImage:originalImage withMaxDimension:1024];
    data = UIImageJPEGRepresentation(originalImage, 0.3);
    
    if (data)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [RequestsManager AddAvatar: data forId: userData[@"id"] withAnswer:^(NSString * error, NSDictionary *answer) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error)
            {
                [[[UIAlertView alloc] initWithTitle:@"" message: NSLocalizedString(@"Can't upload avatar", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
            else
            {
                userData = answer;
                [[NSUserDefaults standardUserDefaults] setObject: userData forKey: @"me"];
                _avatarImageView.image = originalImage;
            }
        }];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"" message: NSLocalizedString(@"Image can't be opened", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    
    [self dismissViewControllerAnimated:YES completion: nil];
}

- (UIImage *)resizeImage:(UIImage *)image withMaxDimension:(CGFloat)maxDimension
{
    if (fmax(image.size.width, image.size.height) <= maxDimension) {
        return image;
    }
    
    CGFloat aspect = image.size.width / image.size.height;
    CGSize newSize;
    
    if (image.size.width > image.size.height) {
        newSize = CGSizeMake(maxDimension, maxDimension / aspect);
    } else {
        newSize = CGSizeMake(maxDimension * aspect, maxDimension);
    }
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    CGRect newImageRect = CGRectMake(0.0, 0.0, newSize.width, newSize.height);
    [image drawInRect:newImageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString: @"showNewRequestSegue"])
    {
        NewRequestViewController * newRequestVC = segue.destinationViewController;
        newRequestVC.userId = userData[@"id"];
        newRequestVC.calendarDays = calendarDays;
    }
    else if ([segue.identifier isEqualToString: @"showStrikesSegue"])
    {
        StrikesViewController * strikesVC = segue.destinationViewController;
        strikesVC.submitted = strikes[@"submits"];
        strikesVC.received = [strikes[@"receives"] mutableCopy];
        strikesVC.calendarDays = calendarDays;
        strikesVC.userId = userData[@"id"];
    }
}

- (void) getCalendarRequest: (SuccessCalendarBlock) sucess
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
            calendarDays = answer;
            [[NSUserDefaults standardUserDefaults] setObject: answer forKey: @"calendar"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            sucess();
        }
    }];
}

-(void) updateStar
{
    /*if ([userData[@"bio"] length] == 0 ||
            [userData[@"email"] length] == 0 ||
            [userData[@"bc_number"] length] == 0 ||
            [userData[@"id_number"] length] == 0 ||
            [userData[@"mobile"] length] == 0 ||
            [userData[@"address"] length] == 0 ||
            [userData[@"city"] length] == 0 ||
            [userData[@"bet"] length] == 0)*/
    
    if ([_bioTextField.text length] == 0 ||
        [_emailTextField.text length] == 0 ||
        [_bcTextField.text length] == 0 ||
        [_idTextField.text length] == 0 ||
        [_mobileTextField.text length] == 0 ||
        [_addressTextField.text length] == 0 ||
        [_cityButton.currentTitle length] == 0 ||
        [_betButton.currentTitle length] == 0)
    {
        _verifiedImageView.image = [UIImage imageNamed:@"star_empty"];
    }
    else
    {
        _verifiedImageView.image = [UIImage imageNamed:@"star_filled"];
    }
}


@end
