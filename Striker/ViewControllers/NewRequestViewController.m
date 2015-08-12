#import "NewRequestViewController.h"
#import "ActionSheetDatePicker.h"
#import "ActionSheetStringPicker.h"
#import "NSDate+FastDate.h"
#import "LocationsViewController.h"
#import "DayPopupViewController.h"
#import "UIStoryboard+LDMain.h"
#import "MBProgressHUD.h"
#import "RequestsManager.h"
#import "MatchViewController.h"

@interface NewRequestViewController ()
{
    NSDate * requestDate;
    NSDictionary * matchedPerson;
}

@end

@implementation NewRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"New Request", @"");
    requestDate = [[NSDate date] getNextDayDate];
    
//    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self   action:@selector(backbtnclick)];
    
    self.navigationController.navigationBarHidden = NO;
    
}
//- (void) backbtnclick{
//     [self.navigationController popViewControllerAnimated:YES];
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)viewWillAppear:(BOOL)animated
//{
//    NSMutableArray * viewControllers = [self.navigationController.viewControllers mutableCopy];
//    if (![viewControllers[viewControllers.count - 2] isKindOfClass: [CalendarViewController class]])
//    {
//        CalendarViewController * calendarVC = [[UIStoryboard LDMainStoryboard] instantiateViewControllerWithIdentifier: @"calendarViewController"];
//        
//        NSMutableArray *viewControllers = [[self navigationController].viewControllers mutableCopy];
//        [viewControllers insertObject: calendarVC atIndex: viewControllers.count - 1];
//        [self navigationController].viewControllers = viewControllers;
//    }
//    self.navigationController.navigationBarHidden = NO;
//}


- (NSDate *) getTomorrow
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate: [NSDate date]];
    NSInteger theDay = [todayComponents day];
    NSInteger theMonth = [todayComponents month];
    NSInteger theYear = [todayComponents year];
    
    // now build a NSDate object for yourDate using these components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay];
    [components setMonth:theMonth];
    [components setYear:theYear];
    NSDate *thisDate = [gregorian dateFromComponents:components];
    
    // now build a NSDate object for the next day
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:1];
    NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
    return nextDate;
}

- (IBAction)dateClick:(id)sender
{
    ActionSheetDatePicker * actionSheetDatePicker = [[ActionSheetDatePicker alloc] initWithTitle:NSLocalizedString(@"Set Date", @"") datePickerMode:UIDatePickerModeDate selectedDate: requestDate doneBlock:^(ActionSheetDatePicker *picker, NSDate *selectedDate, id origin)
    {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate: selectedDate];
        
        NSInteger weekday = [weekdayComponents weekday];
        if (weekday == 7)
        {
            [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: NSLocalizedString(@"Appointments not available on Saturday.", @"") delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
            return;
        }
        requestDate = selectedDate;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat=@"dd MMMM yyyy";
        NSString * dateString = [[dateFormatter stringFromDate: requestDate] capitalizedString];
        [_dateButton setTitle: dateString forState: UIControlStateNormal];
        
    } cancelBlock: nil origin: sender];
    
    actionSheetDatePicker.minimumDate = [[NSDate date] getNextDayDate];
    actionSheetDatePicker.maximumDate = [[NSDate date] getNextYearDate];
    
    [actionSheetDatePicker showActionSheetPicker];
}

- (IBAction)locationClick:(id)sender
{
    [self performSegueWithIdentifier: @"showLocationsSegue" sender: self];
}

- (IBAction)ampmClick:(id)sender
{
    DayPopupViewController * dayPopupViewController = [[UIStoryboard LDMainStoryboard] instantiateViewControllerWithIdentifier:@"dayPopupStoryboadId"];
    dayPopupViewController.date = requestDate;
    
    NSString * currentState = _ampmButton.currentTitle;
    if ([currentState isEqualToString: @"AM"])
        dayPopupViewController.status = 1;
    else if ([currentState isEqualToString: @"PM"])
        dayPopupViewController.status = 2;

    dayPopupViewController.multipleSelection = NO;
    dayPopupViewController.dismissDelegate = self;
    dayPopupViewController.view.frame = CGRectMake(0, 0, 280, 170);
    [self presentPopUpViewController: dayPopupViewController];
}

- (IBAction)maxBetClick:(id)sender
{
    NSMutableArray *bets = [NSMutableArray array];
    
    for (int i = 50; i <= 200; i=i+25)
    {
        [bets addObject: [NSString stringWithFormat: @"%d", i]];
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Bet" rows:bets initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
     {
         [_maxBetButton setTitle: selectedValue forState: UIControlStateNormal];
     }
     cancelBlock: nil origin:sender];
}

- (IBAction)submitClick:(id)sender
{
    if (!_maxBetButton.currentTitle.length ||
        !_locationButton.currentTitle.length ||
        !_dateButton.currentTitle.length ||
        !_ampmButton.currentTitle.length)
    {
        [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: NSLocalizedString(@"Please, fill all fields", @"") delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
    }
    else
    {
        NSString * isAM = [_ampmButton.currentTitle isEqualToString: @"AM"] ? @"1" : @"2";
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [RequestsManager addRequestForUser: _userId withDate:requestDate withLocation: _locationButton.currentTitle withBet: _maxBetButton.currentTitle isAM: isAM withAnswer:^(NSString * error, NSDictionary * answer) {[MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error)
            {
                [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            else
            {
                if ([answer isKindOfClass: [NSArray class]])
                {
                    [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Done", @"") message: NSLocalizedString(@"Thanks for submitting a request. You will receive an email notification once we find a suitable match.", @"") delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
                
                    [self.navigationController popViewControllerAnimated: YES];
                }
                else
                {
                    matchedPerson = answer;
                    [self performSegueWithIdentifier: @"showMatchSegue" sender: self];
                }
            }
        }];
    }
}


-(void) dismissDayPopupViewController: (NSDate*) date withStatus: (NSNumber *) status city:(NSString*)city duration:(int)duration
{
    if (date)
    {
        if ([status intValue] == 1)
        {
            [_ampmButton setTitle: @"AM" forState: UIControlStateNormal];
        }
        else if ([status intValue] == 2)
        {
            [_ampmButton setTitle: @"PM" forState: UIControlStateNormal];
        }
        else
        {
            [_ampmButton setTitle: @"" forState: UIControlStateNormal];
        }
    }
    [self dismissPopUpViewControllerWithcompletion: nil];
}

-(NSString *) getDateStringByDate: (NSDate *) date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat=@"yyyy-MM-dd";
    NSString * formatedDate = [[dateFormatter stringFromDate: date] capitalizedString];
    return formatedDate;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString: @"showLocationsSegue"])
    {
        LocationsViewController * locationsVC = segue.destinationViewController;
        NSString * choosedLocation = _locationButton.currentTitle;
        if (choosedLocation.length > 0)
        locationsVC.checkedLocations = [@[choosedLocation] mutableCopy];
        else
        locationsVC.checkedLocations = nil;
        locationsVC.answerBlock = ^(NSString * location)
        {
            [_locationButton setTitle: location forState: UIControlStateNormal];
        };
    }
    else if ([segue.identifier isEqualToString: @"showMatchSegue"])
    {
        MatchViewController * matchVC = segue.destinationViewController;
        matchVC.matchedPerson = matchedPerson;
        matchVC.locationMatch = _locationButton.currentTitle;
        matchVC.dateMatch = requestDate;
        matchVC.amPmMatch = _ampmButton.currentTitle;
    }
}

@end
