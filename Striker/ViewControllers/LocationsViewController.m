#import "LocationsViewController.h"
#import "RequestsManager.h"
#import "MBProgressHUD.h"
#import "CityCell.h"
@interface LocationsViewController ()

@property (nonatomic, strong) IBOutlet UITableView * mainTableView;

@property (nonatomic, strong) NSArray * locations;
@property (nonatomic, strong) NSString * userId;

@end

@implementation LocationsViewController{
    NSArray *cities;
    NSMutableDictionary *dictionary;
    NSMutableArray *statelist;
    UIPickerView *mypicker;
}

@synthesize locations, userId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableArray* array = [NSMutableArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"Alist" ofType:@"plist"]];
    dictionary = [array objectAtIndex:0];
    statelist = [array objectAtIndex:1];
    
    self.title = NSLocalizedString(@"Locations", @"");
    
    userId = [[[NSUserDefaults standardUserDefaults] objectForKey: @"me"] objectForKey: @"id"];
    
    NSString * doneButtonTitle = NSLocalizedString(@"Save", @"");
    if (!_multipleSelection)
    {
        doneButtonTitle = NSLocalizedString(@"Done", @"");
    }
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle: doneButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(doneList:)];
    
    self.navigationItem.rightBarButtonItem = anotherButton;
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) doneList: (id) sender
{
    if (!_multipleSelection)
    {
        
        NSString * city = @"";
        
        NSArray * selectedCol = [self.mainTableView indexPathsForSelectedRows];
        
        for (int i=0; i<[selectedCol count];i++) {
            NSIndexPath* path = (NSIndexPath*) selectedCol[i];
            NSString * state = statelist[path.section];
            cities = [dictionary objectForKey:state];
            NSString * selectedcity = cities[path.row];
            city=[NSString stringWithFormat:@"%@,%@", selectedcity, state];
           
        }

        
        NSString * choosedLocation = city;
        if (!choosedLocation)
            choosedLocation = @"";
        _answerBlock(choosedLocation);
        [self.navigationController popViewControllerAnimated: YES];
    }
    /*else
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [RequestsManager setLocations: _checkedLocations forUser: userId withAnswer:^(NSString *error, NSDictionary * answer) {
            if (error)
            {
                [[[UIAlertView alloc] initWithTitle: @"Error" message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            else
            {
                [self.navigationController popViewControllerAnimated: YES];
            }
        }];
    }*/
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationsCell"];
    
    NSString * state = statelist[indexPath.section];
    cities = [dictionary objectForKey:state];
    NSString * city = cities[indexPath.row];
    NSString * stateandcity = [NSString stringWithFormat:@"%@,%@", city,state];
    NSDictionary *data;
    _city = _checkedLocations[0];
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

@end
