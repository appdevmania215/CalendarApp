#import "DayPopupViewController.h"
#import "RequestsManager.h"
#import "MBProgressHUD.h"
#import "CityCell.h"


@interface DayPopupViewController ()

@property (nonatomic, strong) IBOutlet UIButton * amButton;
@property (nonatomic, strong) IBOutlet UIButton * pmButton;

@property (nonatomic, strong) IBOutlet UILabel * dateLabel;
@property (nonatomic, strong) IBOutlet UILabel * weekdayLabel;

@property (nonatomic, strong) IBOutlet UIButton * saveButton;
@property (nonatomic, strong) IBOutlet UIButton * cancelButton;

@property (nonatomic, strong) IBOutlet UIView * dotAmView;
@property (nonatomic, strong) IBOutlet UIView * dotPmView;

@property (nonatomic, strong) IBOutlet UITextField * durationText;
@property (nonatomic, strong) IBOutlet UITableView * cityTableView;


@end

@implementation DayPopupViewController
{
    NSArray *cities;
    NSMutableDictionary *dictionary;
    NSMutableArray *statelist;
    UIPickerView *mypicker;
   
}

@synthesize date, userId;

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)note
{
    CGRect frame = self.view.frame;
    frame.origin.y -= 160;
    
    [UIView animateWithDuration:0.3f animations:^ {
        
        self.view.frame = frame; //CGRectMake(0, -160, 320, 480);
    }];
//    CGRect keyboardBounds;
//    NSValue *aValue = [note.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
//    
//    [aValue getValue:&keyboardBounds];
//    keyboardHeight = keyboardBounds.size.height;
//    if (!keyboardIsShowing)
//    {
//        keyboardIsShowing = YES;
//        CGRect frame = self.view.frame;
//        frame.size.height -= 168;
//        
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationBeginsFromCurrentState:YES];
//        [UIView setAnimationDuration:0.3f];
//        self.view.frame = frame;
//        [UIView commitAnimations];
//    }
}


- (void)keyboardWillHide:(NSNotification *)note
{
    CGRect frame = self.view.frame;
    frame.origin.y += 160;
    
    [UIView animateWithDuration:0.3f animations:^ {
        self.view.frame = frame;
    }];
    
//    CGRect keyboardBounds;
//    NSValue *aValue = [note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
//    [aValue getValue: &keyboardBounds];
//    
//    keyboardHeight = keyboardBounds.size.height;
//    if (keyboardIsShowing)
//    {
//        keyboardIsShowing = NO;
//        CGRect frame = self.view.frame;
//        frame.size.height += 168;
//        
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationBeginsFromCurrentState:YES];
//        [UIView setAnimationDuration:0.3f];
//        self.view.frame = frame;
//        [UIView commitAnimations];
//        
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [_durationText setInputAccessoryView:_toolbar];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 428, 320, 40)];
    
    //create buttons and set their corresponding selectors
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onBtnDone:)];

    //add buttons to the toolbar
    [toolbar setItems:[NSArray arrayWithObjects:done, nil]];
    
    [_durationText setInputAccessoryView:toolbar];
    
   
    dictionary = [_stateArray objectAtIndex:0];
    statelist = [_stateArray objectAtIndex:1];
       // Do any additional setup after loading the view.
    
    if (_status % 10 == 1 || _status % 10 == 3)
        _amEnabled = YES;
    if (_status % 10 == 2 || _status % 10 == 3)
        _pmEnabled = YES;
    
    [self updateColors];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    _weekdayLabel.text = [dateFormatter stringFromDate: date];
    
    dateFormatter.dateFormat=@"dd MMMM yyyy";
    _dateLabel.text = [[dateFormatter stringFromDate:date] capitalizedString];
    
    _saveButton.hidden = _cancelButton.hidden = NO;
    
    
    if ([NSStringFromClass([_dismissDelegate class]) isEqualToString:@"NewRequestViewController"]){
        _saveButton.hidden = _cancelButton.hidden = YES;
        self.cityTableView.hidden = YES;
    }
        
    
}

- (IBAction)onBtnDone:(id)sender
{
    [self.view endEditing:YES];
}
   
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelClick:(id)sender
{
    [_dismissDelegate dismissDayPopupViewController: nil withStatus: nil city:nil duration:0];
}

//finalStatus 0 = no Selection, 1 - am, 2 - pm, 3 - am+pm
-(IBAction)okClick:(id)sender
{
    if (!_multipleSelection)
    {
        int finalStatus = 0;
        if (_amEnabled)
            finalStatus += 1;
        if (_pmEnabled)
            finalStatus += 2;
        
        [_dismissDelegate dismissDayPopupViewController:date withStatus:[NSNumber numberWithInt: finalStatus] city:nil duration:0];
    }
    else
    {
        int finalStatus = 0;
        if (_amEnabled)
            finalStatus += 1;
        if (_pmEnabled)
            finalStatus += 2;
        
        
        NSString * city = @"";
        int duration = self.durationText.text.intValue;
        
        NSArray * selectedCol = [self.cityTableView indexPathsForSelectedRows];
        
        for (int i=0; i<[selectedCol count];i++) {
            NSIndexPath* path = (NSIndexPath*) selectedCol[i];
            NSString * state = statelist[path.section];
            cities = [dictionary objectForKey:state];
            NSString * selectedcity = cities[path.row];
            if(![city isEqualToString:@""]){
                city=[NSString stringWithFormat:@"%@|%@,%@", city, selectedcity,state];
            }else{
                city=[NSString stringWithFormat:@"%@,%@", selectedcity,state];
            }
        }
       
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [RequestsManager setCalendarDay: date forUser: userId withDayTime: finalStatus city:city duration:duration withAnswer:^(NSString * error, NSDictionary * answer) {
            if (error)
            {
                [[[UIAlertView alloc] initWithTitle: @"Error" message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            else
            {
                [_dismissDelegate dismissDayPopupViewController:date withStatus:[NSNumber numberWithInt: finalStatus] city: city duration: duration];
            }
        }];
        
    }
}

-(IBAction)amClick:(id)sender
{
    if (!_multipleSelection)
    {
        _amEnabled = YES;
        _pmEnabled = NO;
        [self okClick: nil];
    }
    else
    {
        _amEnabled = !_amEnabled;
    }
    
    [self updateColors];
}

-(IBAction)pmClick:(id)sender
{
    if (!_multipleSelection)
    {
        _amEnabled = NO;
        _pmEnabled = YES;
        [self okClick: nil];
    }
    else
    {
        _pmEnabled = !_pmEnabled;
    }

    [self updateColors];
}

-(void) updateColors
{
    if (!_amEnabled)
    {
        _amButton.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha: 1.0];
        _dotAmView.backgroundColor = [UIColor colorWithRed:0.5 green: 0.5 blue:0.5 alpha: 1.0];
    }
    else
    {
        _dotAmView.backgroundColor = _amButton.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.45 alpha: 1.0];
        //_dotAmView.backgroundColor = [UIColor colorWithRed:0.5 green: 0.5 blue:1 alpha: 1.0];
    }
    if (!_pmEnabled)
    {
        _pmButton.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha: 1.0];
        _dotPmView.backgroundColor = [UIColor colorWithRed:0.5 green: 0.5 blue:0.5 alpha: 1.0];
    }
    else
    {
        _pmButton.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.45 alpha: 1.0];
        //_dotPmView.backgroundColor = [UIColor colorWithRed:0.5 green: 0.5 blue:1 alpha: 1.0];
    }
    
    if (_status / 10 == 1 || _status /10 == 3)
    {
        _amEnabled = NO;
        _dotAmView.backgroundColor = _amButton.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:1 alpha: 1.0];
        _amButton.enabled = NO;
    }
    if (_status / 10 == 2 || _status /10 == 3)
    {
        _pmEnabled = NO;
        _dotPmView.backgroundColor = _pmButton.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:1 alpha: 1.0];
        _pmButton.enabled = NO;
    }
}

#pragma mark - CityTableView DataSource Implementation
- (id)objectAtIndexPath:(NSIndexPath *)indexPath isSelected: (NSString*)selected
{
    cities = [dictionary objectForKey:statelist[indexPath.section]];
    NSDictionary *data = @{@"CityName": [cities objectAtIndex:indexPath.row],@"selected": selected};
    return data;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return statelist.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    cities = [dictionary objectForKey:statelist[section]];
    return [cities count];
}
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell"];
    
    NSString * state = statelist[indexPath.section];
    cities = [dictionary objectForKey:state];
    NSString * city = cities[indexPath.row];
    NSString * stateandcity = [NSString stringWithFormat:@"%@,%@", city, state];
    NSDictionary *data;
    if([_city containsString: stateandcity]){
        data = [self objectAtIndexPath:indexPath isSelected:@"1"];
        [cell configureCellWithData:data];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }else{
        
        data = [self objectAtIndexPath:indexPath isSelected:@"0"];
        [cell configureCellWithData:data];
    }
    
    return cell;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10,0,300,60)];
    customView.backgroundColor = [UIColor darkGrayColor];
    customView.alpha = 0.5;
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.frame = CGRectMake(10,1,200,20);
    headerLabel.text =  statelist[section];
    headerLabel.textColor = [UIColor blueColor];
  	[customView addSubview:headerLabel];
    
    return customView;
}
#pragma TextField
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

 /*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
