#import "StrikesViewController.h"
#import "MatchPopupViewController.h"
#import "UIViewController+ENPopUp.h"
#import "UIStoryboard+LDMain.h"
#import "CalendarViewController.h"
#import "RequestsManager.h"
#import "MBProgressHUD.h"
#import "ChatViewController.h"
@interface StrikesViewController ()

@property (strong, nonatomic) IBOutlet UITableView *submittedTableView;
@property (strong, nonatomic) IBOutlet UITableView *receivedTableView;

@property (strong, nonatomic) IBOutlet UILabel *submittedLabel;
@property (strong, nonatomic) IBOutlet UILabel *receivedLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmented;



@end

@implementation StrikesViewController{
    NSDictionary * strikes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_submitted){
    _userId = [[[NSUserDefaults standardUserDefaults] objectForKey: @"me"] objectForKey:@"id"];
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
            _submitted = strikes[@"submits"];
            _received = [strikes[@"receives"] mutableCopy];

            [self.submittedTableView reloadData];
            [self.receivedTableView reloadData];
        }
    }];
    }
    
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"My Appointments", @"");
    
    if (_received.count == 0)
    {
        _receivedTableView.hidden = YES;
        _receivedLabel.text = NSLocalizedString(@"No received matches", @"");
    }
    if (_submitted.count == 0)
    {
        _submittedTableView.hidden = YES;
        _submittedLabel.text = NSLocalizedString(@"No submitted matches", @"");
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(popupWasClosed:) name: CloseENPopUp object:nil];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"calendar"] style:UIBarButtonItemStylePlain target:self action:@selector(onCalendar)];
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void) onCalendar {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    [_segmented setSelectedSegmentIndex:0];
    NSMutableArray * viewControllers = [self.navigationController.viewControllers mutableCopy];
    if (![viewControllers[viewControllers.count - 2] isKindOfClass: [CalendarViewController class]])
    {
        CalendarViewController * calendarVC = [[UIStoryboard LDMainStoryboard] instantiateViewControllerWithIdentifier: @"calendarViewController"];
        
        NSMutableArray *viewControllers = [[self navigationController].viewControllers mutableCopy];
        [viewControllers insertObject: calendarVC atIndex: viewControllers.count - 1];
        [self navigationController].viewControllers = viewControllers;
    }
    [_submittedTableView reloadData];
    self.navigationController.navigationBarHidden = NO;
    
    _submittedTableView.hidden = FALSE;
    _receivedTableView.hidden = TRUE;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _submittedTableView && _submitted.count > 0)
    {
        return _submitted.count + 1;
    }
    else if (tableView == _receivedTableView && _received.count > 0)
    {
        return _received.count + 1;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * dataArray = nil;
    if (tableView == _submittedTableView)
    {
        dataArray = _submitted;
    }
    else
    {
        dataArray = _received;
    }
    if (indexPath.row == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"headerMatchCell"];
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bodyMatchCell"];
        
        UILabel * labelDate = (UILabel *)[cell viewWithTag: 1];
        labelDate.text = [ self formatedStringByDateString: dataArray[indexPath.row-1][@"date"]];
        
        NSString * amPmString = [dataArray[indexPath.row-1][@"am"] intValue] == 1 ? @"AM" : @"PM";
        UILabel * labelAmPm = (UILabel *)[cell viewWithTag: 2];
        labelAmPm.text = amPmString;
        
        UILabel * labelLocation = (UILabel *)[cell viewWithTag: 3];
        labelLocation.text = dataArray[indexPath.row-1][@"location"];
        
        NSString * confirmed = [dataArray[indexPath.row-1][@"confirmed"] isKindOfClass: [NSNull class]] ? @"X" : @"✓";
        UILabel * labelConfirmation = (UILabel *)[cell viewWithTag: 4];
        labelConfirmation.text = confirmed;
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return;
    
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    MatchPopupViewController * matchPopupVC = [[UIStoryboard LDMainStoryboard] instantiateViewControllerWithIdentifier:@"matchPopupStoryboadId"];
    matchPopupVC.dismissDelegate = self;
    
    if (tableView == _submittedTableView)
    {
        if(![_submitted[indexPath.row-1][@"confirmed"] isKindOfClass: [NSNull class]]){
            ChatViewController * chatviewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            chatviewcontroller.is_sender = 1;
            chatviewcontroller.confirmed_id = [_submitted[indexPath.row-1][@"confirmed"] intValue];
            
            chatviewcontroller.match = _submitted[indexPath.row - 1];
            chatviewcontroller.isSubmitted = YES;

            [self.navigationController pushViewController:chatviewcontroller animated:YES];
        }else{
            matchPopupVC.match = _submitted[indexPath.row - 1];
            matchPopupVC.isSubmitted = YES;
            matchPopupVC.view.frame = CGRectMake(0, 0, 280, 340);
            matchPopupVC.delegate = self;
            [self presentPopUpViewController: matchPopupVC];
        }
    }
    else
    {
        if(![_received[indexPath.row-1][@"confirmed"] isKindOfClass: [NSNull class]]){
            ChatViewController * chatviewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            chatviewcontroller.is_sender = 0;
            chatviewcontroller.confirmed_id = [_received[indexPath.row-1][@"confirmed"] intValue];
            _received[indexPath.row - 1] = [_received[indexPath.row - 1] mutableCopy];
            chatviewcontroller.match = _received[indexPath.row - 1];
            chatviewcontroller.isSubmitted = NO;
            [self.navigationController pushViewController:chatviewcontroller animated:YES];
        }else{
            _received[indexPath.row - 1] = [_received[indexPath.row - 1] mutableCopy];
            matchPopupVC.match = _received[indexPath.row - 1];
            matchPopupVC.isSubmitted = NO;
            matchPopupVC.view.frame = CGRectMake(0, 0, 280, 340);
            matchPopupVC.delegate = self;
            [self presentPopUpViewController: matchPopupVC];
        }
    }
    
    
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

- (void) popupWasClosed: (NSNotification *) notification
{
    [_receivedTableView reloadData];
}

-(void) dismissDayPopupViewController: (NSDate*) date withStatus: (NSNumber *) status city:(NSString*)city duration:(int)duration
{
    [self dismissPopUpViewControllerWithcompletion: nil];
    [_receivedTableView reloadData];
}

#pragma segmented

- (IBAction)onClickSegment:(id)sender{
    if(_segmented.selectedSegmentIndex==0){
        _submittedTableView.hidden = FALSE;
        _receivedTableView.hidden = TRUE;
    }else{
        _submittedTableView.hidden = TRUE;
        _receivedTableView.hidden = FALSE;
    }
}

-(IBAction) newRequestClick:(id)sender
{
    [self performSegueWithIdentifier: @"showNewRequestSegue" sender: self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showNewRequestSegue"]){
        //segue.destinationViewController.senderName = @"StrikerViewer";
    }
}
- (void) onOpenChat:(NSMutableDictionary *) match isSubmitted:(BOOL)isSubmitted{
    ChatViewController * chatviewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatviewcontroller.is_sender = 0;
    chatviewcontroller.confirmed_id = [match[@"confirmed"] intValue];
    
    chatviewcontroller.match = match;
    chatviewcontroller.isSubmitted = NO;
    [self.navigationController pushViewController:chatviewcontroller animated:YES];
}

@end
