#import "CalendarViewController.h"
#import "MNCalendarView.h"
#import "UIStoryboard+LDMain.h"
#import "DayPopupViewController.h"
#import "LocationsViewController.h"
#import "MBProgressHUD.h"
#import "RequestsManager.h"
#import "NSDate+FastDate.h"
#import "StrikesViewController.h"
#import "NewRequestViewController.h"
#import "RequestsManager.h"
#import "WelcomeViewController.h"
#import "ProfileViewController.h"


@interface CalendarViewController () <MNCalendarViewDelegate>
{
    MNCalendarView *calendarView;
    NSArray * locations;
    DayPopupViewController * dayPopupViewController;
    
    NSDictionary * strikes;
}

@property (nonatomic, strong) IBOutlet UIView * calendarParentView;
@property (nonatomic, strong) IBOutlet UIView * overlayView;
@property (nonatomic, strong) IBOutlet UIButton * leftbtn;
@property (nonatomic, strong) IBOutlet UIButton * rightbtn;


@property (nonatomic, strong) IBOutlet UILabel * strikesNotConfirmedLabel;

@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSArray * calendarDays;

@property (nonatomic, strong) NSMutableArray * updatedCalendarDays;

@end

NSMutableArray* stateArray;

@implementation CalendarViewController{
    BOOL isNextMonth;
    BOOL isPrevMonth;
    NSDate *currentFirstDateOfMonth;
    NSDate *currentLastDateOfMonth;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //preloading statelist for popup
    
    stateArray=[[NSMutableArray alloc]init];
    
    stateArray = [NSMutableArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"Alist" ofType:@"plist"]];
    
    
    
    isNextMonth = TRUE;
    isPrevMonth = FALSE;
    self.leftbtn.hidden = TRUE;
    self.rightbtn.hidden = FALSE;
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [_calendarParentView addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *recognizer1;
    recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeleft:)];
    [recognizer1 setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_calendarParentView addGestureRecognizer:recognizer1];
    
    
    
    
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Calendar", @"");
    
    _userId = [[[NSUserDefaults standardUserDefaults] objectForKey: @"me"] objectForKey:@"id"];
    _calendarDays = [[NSUserDefaults standardUserDefaults] objectForKey: @"calendar"];
    _updatedCalendarDays = [_calendarDays mutableCopy];;
    
    calendarView = [[MNCalendarView alloc] initWithFrame: _calendarParentView.bounds];
    calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    calendarView.fromDate = [NSDate date];
    
    
    NSDate *curDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:curDate]; // Get necessary date components
    
    // set last of month
    [comps setMonth:[comps month]+1];
    [comps setDay:0];
    
    currentLastDateOfMonth =[calendar dateFromComponents:comps];
    //Count toDate
    calendarView.toDate = currentLastDateOfMonth;
    
    calendarView.calendarDays = _updatedCalendarDays;
    calendarView.backgroundColor = UIColor.whiteColor;
    calendarView.delegate = self;
    [_calendarParentView addSubview: calendarView];
    [calendarView reloadData];
    
    _strikesNotConfirmedLabel.hidden = YES;
    
    
    [comps setDay:1];
    long m = comps.month-1;
    long y = comps.year;
    long d = comps.day;
    NSString *month;
    NSString *year;
    if(m<10){
        month = [NSString stringWithFormat:@"0%d",m];
    }else{
        month = [NSString stringWithFormat:@"%d",m];
    }
    year = [NSString stringWithFormat:@"%d",y];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy MM dd"];
    NSString *formated = [NSString stringWithFormat:@"%@ %@ 01",year,month];
    currentFirstDateOfMonth = [df dateFromString:formated];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(popupWasClosed:) name: CloseENPopUp object:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"help"] style: UIBarButtonItemStylePlain target:self action:@selector(helpClick:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"home"] style: UIBarButtonItemStylePlain target:self action: @selector(backClick:)];
    
    if (![[self.navigationController.viewControllers objectAtIndex: 1] isKindOfClass: [WelcomeViewController class]])
    {
        ProfileViewController * profileVC = [[UIStoryboard LDMainStoryboard] instantiateViewControllerWithIdentifier: @"ProfileViewController"];
        
        NSMutableArray *viewControllers = [[self navigationController].viewControllers mutableCopy];
        [viewControllers insertObject: profileVC atIndex: viewControllers.count - 1];
        [self navigationController].viewControllers = viewControllers;
    }
}

-(void) backClick: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}
                                                 
-(void) helpClick: (id) sender
{
    [self performSegueWithIdentifier: @"showHelpSegue" sender: self];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [RequestsManager getStrikes: _userId withAnswer:^(NSString * error, NSDictionary * answer) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error)
        {
            [[[UIAlertView alloc] initWithTitle: @"Error" message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        }
        else
        {
            strikes = answer;
            
            int notConfirmed = 0;
            NSArray * allData = [strikes[@"submits"] arrayByAddingObjectsFromArray: strikes[@"receives"]];
            for (int i = 0; i < allData.count; i++)
            {
                if ([allData[i][@"confirmed"] isKindOfClass: [NSNull class]])
                {
                    notConfirmed++;
                }
            }
            if (notConfirmed > 0)
            {
                _strikesNotConfirmedLabel.text = [NSString stringWithFormat:@"%d", notConfirmed];
                _strikesNotConfirmedLabel.hidden = NO;
            }
            else
            {
                _strikesNotConfirmedLabel.hidden = YES;
            }
            [self updateCalendarWithStrikes];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)locationsClick:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [RequestsManager getLocations: _userId withAnswer:^(NSString * error, NSArray * answer) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error)
        {
            [[[UIAlertView alloc] initWithTitle: @"Error" message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        }
        else
        {
            locations = answer;
            [self performSegueWithIdentifier: @"showLocationsSegue" sender: self];
        }
    }];
}



#pragma mark - MNCalendarViewDelegate

- (void)calendarView:(MNCalendarView *)calendarView didSelectDate:(NSDate *)date {
    dayPopupViewController = [[UIStoryboard LDMainStoryboard] instantiateViewControllerWithIdentifier:@"dayPopupStoryboadId"];
    dayPopupViewController.date = date;
    
    NSString * formatedDate = [self getDateStringByDate: date];
    for (NSDictionary * calendarDay in _updatedCalendarDays)
    {
        if ([calendarDay[@"day"] isEqualToString: formatedDate])
        {
            int status = [calendarDay[@"dayTime"] intValue];
            dayPopupViewController.status = status;
            dayPopupViewController.city = calendarDay[@"city"];
        }
    }
    
    dayPopupViewController.stateArray = stateArray;
    dayPopupViewController.multipleSelection = YES;
    dayPopupViewController.userId = _userId;
    dayPopupViewController.dismissDelegate = self;
    dayPopupViewController.view.frame = CGRectMake(0, 0, 280, 450);
    
    [self presentPopUpViewController: dayPopupViewController ];
}

- (void) popupWasClosed: (NSNotification *) notification
{
    /*int finalStatus = 0;
    if (dayPopupViewController.amEnabled)
        finalStatus += 1;
    if (dayPopupViewController.pmEnabled)
        finalStatus += 2;
    NSString * state;
    NSString * city;

    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [RequestsManager setCalendarDay: dayPopupViewController.date forUser: _userId withDayTime: finalStatus state: state city: city withAnswer:^(NSString * error, NSDictionary * answer) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error)
        {
            [[[UIAlertView alloc] initWithTitle: @"Error" message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        }
        else
        {
            [self dismissDayPopupViewController: dayPopupViewController.date withStatus:[NSNumber numberWithInt: finalStatus] duration:0];
        }
        dayPopupViewController = nil;
    }];*/
}

- (BOOL)calendarView:(MNCalendarView *)calendarView shouldSelectDate:(NSDate *)date {
    if ([[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate: date] weekday] == 7)
    {
        return NO;
    }
    if (([date compare: [NSDate date]] == NSOrderedAscending) || ([date compare: [[NSDate date] getNextYearDate]] == NSOrderedDescending))
    {
        return NO;
    }
    return YES;
}

-(void) dismissDayPopupViewController: (NSDate*) date withStatus: (NSNumber *) status city:(NSString*) city duration:(int) duration
{
    if (date)
    {
        
        int i=0;
        int index=0;
        while ( i<duration){
            
            NSDateComponents* comps = [[NSDateComponents alloc]init];
            comps.day = index;
            
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSRange weekdayRange = [calendar maximumRangeOfUnit:NSWeekdayCalendarUnit];
            NSDate* tomorrow = [calendar dateByAddingComponents:comps toDate:date options:nil];
            NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:tomorrow];
            NSUInteger weekdayOfDate = [components weekday];
            
            if (weekdayOfDate == weekdayRange.length) {
                
            }else{
                
                NSString * formatedDate = [self getDateStringByDate: tomorrow];
                
                NSDictionary * newCalendarDay = @{@"day": formatedDate, @"dayTime" : status, @"city": city};
                NSMutableArray * newCalendarDays = [_calendarDays mutableCopy];
                BOOL dayFound = NO;
                for (int i = 0; i < newCalendarDays.count; i++)
                {
                    NSDictionary * calendarDay = [newCalendarDays objectAtIndex: i];
                    if ([calendarDay[@"day"] isEqualToString: formatedDate])
                    {
                        dayFound = YES;
                        [newCalendarDays replaceObjectAtIndex: i withObject: newCalendarDay];
                        break;
                    }
                }
                if (!dayFound)
                {
                    [newCalendarDays addObject: newCalendarDay];
                }
                calendarView.calendarDays = _calendarDays = newCalendarDays;
                
                i++;
            }
            index++;
        }
        
        [self updateCalendarWithStrikes];
        
        [[NSUserDefaults standardUserDefaults] setObject: _calendarDays forKey: @"calendar"];
        [calendarView reloadData];
    }
    [self dismissPopUpViewControllerWithcompletion: nil];
}

-(void) updateCalendarWithStrikes
{
    _updatedCalendarDays = [_calendarDays mutableCopy];
    NSArray * allData = strikes[@"receives"];
    for (int i = 0; i < allData.count; i++)
    {
        if (![allData[i][@"confirmed"] isKindOfClass: [NSNull class]])
        {
            BOOL found = NO;
            //notConfirmed++;
            for (int j = 0; j < _updatedCalendarDays.count; j++)
            {
                NSMutableDictionary * calendarDay = [[_updatedCalendarDays objectAtIndex: j] mutableCopy];
                if ([calendarDay[@"day"] isEqualToString: allData[i][@"date"]])
                {
                    found = YES;
                    int currentStatus = [calendarDay[@"dayTime"] intValue];
                    if ([allData[i][@"am"] intValue])
                        calendarDay[@"dayTime"] = [NSNumber numberWithInt: currentStatus + 10];
                    else
                        calendarDay[@"dayTime"] = [NSNumber numberWithInt: currentStatus + 20];
                    _updatedCalendarDays[j] = calendarDay;
                }
            }
            if (!found)
            {
                NSMutableDictionary * calendarDay = [NSMutableDictionary dictionary];
                calendarDay[@"day"] = allData[i][@"date"];
                if ([allData[i][@"am"] intValue])
                    calendarDay[@"dayTime"] = [NSNumber numberWithInt: 10];
                else
                    calendarDay[@"dayTime"] = [NSNumber numberWithInt: 20];
                [_updatedCalendarDays addObject: calendarDay];
            }
            calendarView.calendarDays = _updatedCalendarDays;
            [calendarView reloadData];
        }
    }
}

-(IBAction) newRequestClick:(id)sender
{
    [self performSegueWithIdentifier: @"showNewRequestSegue" sender: self];
}

-(IBAction) strikesClick:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [RequestsManager getStrikes: _userId withAnswer:^(NSString * error, NSDictionary * answer) {
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
    //[self performSegueWithIdentifier: @"showNewRequestSegue" sender: self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString: @"showLocationsSegue"])
    {
        LocationsViewController * locationsVC = segue.destinationViewController;
        locationsVC.checkedLocations = [locations mutableCopy];
        locationsVC.multipleSelection = YES;
    }
    else if ([segue.identifier isEqualToString: @"showStrikesSegue"])
    {
        StrikesViewController * strikesVC = segue.destinationViewController;
        strikesVC.submitted = strikes[@"submits"];
        strikesVC.received = [strikes[@"receives"] mutableCopy];
        strikesVC.userId = _userId;
    }
    else if ([segue.identifier isEqualToString: @"showNewRequestSegue"])
    {
        NewRequestViewController * newRequestVC = segue.destinationViewController;
        newRequestVC.userId = _userId;
    }
}

    
-(NSString *) getDateStringByDate: (NSDate *) date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat=@"yyyy-MM-dd";
    NSString * formatedDate = [[dateFormatter stringFromDate: date] capitalizedString];
    return formatedDate;
}
#pragma swipe gesture
-(void)swipeleft:(UISwipeGestureRecognizer *)swipeGesture
{
    if (isNextMonth) {
        
        isPrevMonth = TRUE;
        self.leftbtn.hidden=FALSE;
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.month = 1;
        NSDate *nextMonth = [gregorian dateByAddingComponents:components toDate:currentFirstDateOfMonth options:0];
        NSDateComponents *nextMonthComponents = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:nextMonth];
        NSDateComponents *todayDayComponents = [gregorian components:NSDayCalendarUnit fromDate:currentFirstDateOfMonth];
        nextMonthComponents.day = todayDayComponents.day;
        currentFirstDateOfMonth = [gregorian dateFromComponents:nextMonthComponents];
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setDuration:0.13];
        [animation setTimingFunction:
         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [_calendarParentView.layer addAnimation:animation forKey:kCATransition];
        //[self.view addSubview:_overlayView];
        //[self.overlayView setFrame:CGRectMake(0,0,self.overlayView.frame.size.width,self.overlayView.frame.size.height)];
        
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:currentFirstDateOfMonth];
        [comps setMonth:[comps month]+1];
        [comps setDay:0];
        currentLastDateOfMonth = [calendar dateFromComponents:comps];
        
        calendarView = [[MNCalendarView alloc] initWithFrame: _calendarParentView.bounds];
        calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        if( [currentFirstDateOfMonth compare:[NSDate date]] == NSOrderedAscending )
            calendarView.fromDate = [NSDate date];
        else
            calendarView.fromDate = currentFirstDateOfMonth;
        
        if( [currentLastDateOfMonth compare:[[NSDate date] getNextYearDate]] == NSOrderedAscending )
            calendarView.toDate = currentLastDateOfMonth;
        else{
            calendarView.toDate = [[NSDate date] getNextYearDate];
            isNextMonth = FALSE;
            self.rightbtn.hidden = TRUE;
        }
        
        calendarView.calendarDays = _updatedCalendarDays;
        calendarView.backgroundColor = UIColor.whiteColor;
        calendarView.delegate = self;
        [calendarView reloadData];
        [_calendarParentView addSubview: calendarView];
        
    }
}

-(void)swipeRight:(UISwipeGestureRecognizer *)swipeGesture
{
    if (isPrevMonth) {
        isNextMonth = TRUE;
         self.rightbtn.hidden = FALSE;
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.month = -1;
        NSDate *nextMonth = [gregorian dateByAddingComponents:components toDate:currentFirstDateOfMonth options:0];
        NSDateComponents *nextMonthComponents = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:nextMonth];
        NSDateComponents *todayDayComponents = [gregorian components:NSDayCalendarUnit fromDate:currentFirstDateOfMonth];
        nextMonthComponents.day = todayDayComponents.day;
        currentFirstDateOfMonth = [gregorian dateFromComponents:nextMonthComponents];
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromLeft];
        [animation setDuration:0.13];
        [animation setTimingFunction:
         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [_calendarParentView.layer addAnimation:animation forKey:kCATransition];
        //[self.view addSubview:_overlayView];
        //[self.overlayView setFrame:CGRectMake(0,0,self.overlayView.frame.size.width,self.overlayView.frame.size.height)];
        
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:currentFirstDateOfMonth];
        [comps setMonth:[comps month]+1];
        [comps setDay:0];
        currentLastDateOfMonth = [calendar dateFromComponents:comps];
        
        calendarView = [[MNCalendarView alloc] initWithFrame: _calendarParentView.bounds];
        calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        if( [currentFirstDateOfMonth compare:[NSDate date]] == NSOrderedAscending ){
            calendarView.fromDate = [NSDate date];
            isPrevMonth = FALSE;
            self.leftbtn.hidden = TRUE;
        }
        else
            calendarView.fromDate = currentFirstDateOfMonth;
        
        if( [currentLastDateOfMonth compare:[[NSDate date] getNextYearDate]] == NSOrderedAscending )
            calendarView.toDate = currentLastDateOfMonth;
        else{
            calendarView.toDate = [[NSDate date] getNextYearDate];
            isPrevMonth = FALSE;
        }
        
        calendarView.calendarDays = _updatedCalendarDays;
        calendarView.backgroundColor = UIColor.whiteColor;
        calendarView.delegate = self;
        [calendarView reloadData];
        [_calendarParentView addSubview: calendarView];
        
    }

}
#pragma next and prev button click
- (IBAction)onClickNext:(id)sender{
    if (isNextMonth) {
        
        isPrevMonth = TRUE;
        self.leftbtn.hidden=FALSE;
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.month = 1;
        NSDate *nextMonth = [gregorian dateByAddingComponents:components toDate:currentFirstDateOfMonth options:0];
        NSDateComponents *nextMonthComponents = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:nextMonth];
        NSDateComponents *todayDayComponents = [gregorian components:NSDayCalendarUnit fromDate:currentFirstDateOfMonth];
        nextMonthComponents.day = todayDayComponents.day;
        currentFirstDateOfMonth = [gregorian dateFromComponents:nextMonthComponents];
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setDuration:0.13];
        [animation setTimingFunction:
         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [_calendarParentView.layer addAnimation:animation forKey:kCATransition];
        //[self.view addSubview:_overlayView];
        //[self.overlayView setFrame:CGRectMake(0,0,self.overlayView.frame.size.width,self.overlayView.frame.size.height)];
        
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:currentFirstDateOfMonth];
        [comps setMonth:[comps month]+1];
        [comps setDay:0];
        currentLastDateOfMonth = [calendar dateFromComponents:comps];
        
        calendarView = [[MNCalendarView alloc] initWithFrame: _calendarParentView.bounds];
        calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        if( [currentFirstDateOfMonth compare:[NSDate date]] == NSOrderedAscending )
            calendarView.fromDate = [NSDate date];
        else
            calendarView.fromDate = currentFirstDateOfMonth;
        
        if( [currentLastDateOfMonth compare:[[NSDate date] getNextYearDate]] == NSOrderedAscending )
            calendarView.toDate = currentLastDateOfMonth;
        else{
            calendarView.toDate = [[NSDate date] getNextYearDate];
            isNextMonth = FALSE;
            self.rightbtn.hidden = TRUE;
        }
        
        calendarView.calendarDays = _updatedCalendarDays;
        calendarView.backgroundColor = UIColor.whiteColor;
        calendarView.delegate = self;
        [calendarView reloadData];
        [_calendarParentView addSubview: calendarView];
        
    }
}

- (IBAction)onClickPrev:(id)sender
{
    if (isPrevMonth) {
        isNextMonth = TRUE;
        self.rightbtn.hidden = FALSE;
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.month = -1;
        NSDate *nextMonth = [gregorian dateByAddingComponents:components toDate:currentFirstDateOfMonth options:0];
        NSDateComponents *nextMonthComponents = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:nextMonth];
        NSDateComponents *todayDayComponents = [gregorian components:NSDayCalendarUnit fromDate:currentFirstDateOfMonth];
        nextMonthComponents.day = todayDayComponents.day;
        currentFirstDateOfMonth = [gregorian dateFromComponents:nextMonthComponents];
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromLeft];
        [animation setDuration:0.13];
        [animation setTimingFunction:
         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [_calendarParentView.layer addAnimation:animation forKey:kCATransition];
        //[self.view addSubview:_overlayView];
        //[self.overlayView setFrame:CGRectMake(0,0,self.overlayView.frame.size.width,self.overlayView.frame.size.height)];
        
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:currentFirstDateOfMonth];
        [comps setMonth:[comps month]+1];
        [comps setDay:0];
        currentLastDateOfMonth = [calendar dateFromComponents:comps];
        
        calendarView = [[MNCalendarView alloc] initWithFrame: _calendarParentView.bounds];
        calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        if( [currentFirstDateOfMonth compare:[NSDate date]] == NSOrderedAscending ){
            calendarView.fromDate = [NSDate date];
            self.leftbtn.hidden = TRUE;
            isPrevMonth = FALSE;
        }
        else
            calendarView.fromDate = currentFirstDateOfMonth;
        
        if( [currentLastDateOfMonth compare:[[NSDate date] getNextYearDate]] == NSOrderedAscending )
            calendarView.toDate = currentLastDateOfMonth;
        else{
            calendarView.toDate = [[NSDate date] getNextYearDate];
            isPrevMonth = FALSE;
        }
        
        calendarView.calendarDays = _updatedCalendarDays;
        calendarView.backgroundColor = UIColor.whiteColor;
        calendarView.delegate = self;
        [calendarView reloadData];
        [_calendarParentView addSubview: calendarView];
        
    }
}
@end
