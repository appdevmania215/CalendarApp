//
//  ChatViewController.m
//  Striker
//
//  Created by James on 11/25/14.
//  Copyright (c) 2014 Semanggi. All rights reserved.
//

#import "ChatViewController.h"
#import "MBProgressHUD.h"
#import "RequestsManager.h"
#import "UIImageView+AFNetworking.h"

@interface ChatViewController ()<JSMessagesViewDelegate, JSMessagesViewDataSource>


@property (strong, nonatomic) NSMutableArray *messageArray;
@property (nonatomic,strong) UIImage *willSendImage;
@property (strong, nonatomic) NSMutableArray *timestamps;
@property (strong, nonatomic) NSMutableArray *senderIdentifier;


@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *betLabel;
@property (strong, nonatomic) IBOutlet UIButton *confirmedButton;

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
//@property (strong, nonatomic) JSMessagesViewController *messageViewController;

@end

@implementation ChatViewController{
    NSMutableArray * chatHistory;
    NSTimer* myTimer ;
}

@synthesize messageArray, is_sender, confirmed_id;


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
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
    
    _nameLabel.text = [_match[@"bio"] isKindOfClass: [NSNull class]] ? @"" : [NSString stringWithFormat:@"%@", _match[@"bio"]];
    [self updateAvatar];

//    self.messageViewController = [[JSMessagesViewController alloc] init];
//    self.messageViewController.view.frame = self.chatView.bounds;
//    
//    [self addChildViewController:self.messageViewController];
//    [self.chatView addSubview:self.messageViewController.view];
//    
//    self.messageViewController.delegate = self;
//    self.messageViewController.dataSource = self;
    
    self.delegate = self;
    self.dataSource = self;
    self.title = @"ChatMessage";
    
    self.messageArray = [NSMutableArray array];
    self.timestamps = [NSMutableArray array];
    self.senderIdentifier = [NSMutableArray array];
    chatHistory = [NSMutableArray array];
    
   
    
}
- (IBAction)updateChat:(id)sender{
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [RequestsManager getLatestChat:confirmed_id is_sender:is_sender withAnswer:^(NSString * error, NSDictionary * answer) {
        if (error)
        {
            [[[UIAlertView alloc] initWithTitle: @"Error" message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        }
        else
        {
            
            NSArray* dict = answer[@"chat_history"];
            
            for( int i=0;i<dict.count; i++){
                NSString * text = dict[i][@"Text"];
                [self.messageArray addObject:[NSDictionary dictionaryWithObject:text forKey:@"Text"]];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                NSDate *date = [formatter dateFromString:dict[i][@"sent_time"]];
                [self.timestamps addObject:date];
                [self.senderIdentifier addObject:dict[i][@"is_sender"]];

                
            }
            if(dict.count !=0){
                [self.tableView reloadData];
                [self scrollToBottomAnimated:YES];
            }
            //[self finishSend];
            //[self.tableView reloadData];
            
        }
    }];

}
-(void) viewDidAppear:(BOOL)animated{
    int _userId = [[[NSUserDefaults standardUserDefaults] objectForKey: @"me"] objectForKey:@"id"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [RequestsManager getChatHistory:confirmed_id is_sender:is_sender withAnswer:^(NSString * error, NSDictionary * answer) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error)
        {
            //[[[UIAlertView alloc] initWithTitle: @"Error" message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        }
        else
        {
            
            NSArray* dict = answer[@"chat_history"];
            
            for( int i=0;i<dict.count; i++){
                NSString * text = dict[i][@"Text"];
                [self.messageArray addObject:[NSDictionary dictionaryWithObject:text forKey:@"Text"]];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                NSDate *date = [formatter dateFromString:dict[i][@"sent_time"]];
                [self.timestamps addObject:date];
                self.senderIdentifier[i] = dict[i][@"is_sender"];
            }
            //[self finishSend];
            [self.tableView reloadData];
            
            
            if(!myTimer){
                myTimer = [NSTimer scheduledTimerWithTimeInterval:2.6 target:self selector:@selector(updateChat:) userInfo:nil repeats: YES];
                [myTimer fire];
            }
            
            
        }
    }];

}
- (void) viewDidDisappear:(BOOL)animated{
    if(myTimer)
       [myTimer invalidate];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageArray.count;
}


#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [RequestsManager sendChat:confirmed_id is_sender:is_sender text:text withAnswer:^(NSString * error, NSDictionary * answer) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error)
        {
            [[[UIAlertView alloc] initWithTitle: @"Error" message: error delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        }
        else
        {
            
            NSDictionary* dict = answer[@"chat_history"];
            
            /*for( int i=0;i<dict.count; i++){
                NSString * text = dict[i][@"Text"];
                [self.messageArray addObject:[NSDictionary dictionaryWithObject:text forKey:@"Text"]];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                NSDate *date = [formatter dateFromString:dict[i][@"sent_time"]];
                [self.timestamps addObject:date];
                self.senderIdentifier[i] = dict[i][@"is_sender"];
            }
            [self.tableView reloadData];*/
            
            [self.messageArray addObject:[NSDictionary dictionaryWithObject:text forKey:@"Text"]];
            NSString * str = [NSString stringWithFormat:@"%d" , is_sender];
            [self.senderIdentifier addObject:str];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            NSDate *date = [formatter dateFromString:dict[@"sent_time"]];
            [self.timestamps addObject:date];
            [self finishSend];
            
        }
    }];
    
    
   
}

- (void)cameraPressed:(id)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.senderIdentifier[indexPath.row] intValue] == is_sender)
        return JSBubbleMessageTypeOutgoing;
    else
        return JSBubbleMessageTypeIncoming;
}

- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JSBubbleMessageStyleFlat;
}

- (JSBubbleMediaType)messageMediaTypeForRowAtIndexPath:(NSIndexPath *)indexPath{
    return JSBubbleMediaTypeText;
}

- (UIButton *)sendButton
{
    return [UIButton defaultSendButton];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    /*
     JSMessagesViewTimestampPolicyAll = 0,
     JSMessagesViewTimestampPolicyAlternating,
     JSMessagesViewTimestampPolicyEveryThree,
     JSMessagesViewTimestampPolicyEveryFive,
     JSMessagesViewTimestampPolicyCustom
     */
    return JSMessagesViewTimestampPolicyAll;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    /*
     JSMessagesViewAvatarPolicyIncomingOnly = 0,
     JSMessagesViewAvatarPolicyBoth,
     JSMessagesViewAvatarPolicyNone
     */
    return JSMessagesViewAvatarPolicyBoth;
}

- (JSAvatarStyle)avatarStyle
{
    /*
     JSAvatarStyleCircle = 0,
     JSAvatarStyleSquare,
     JSAvatarStyleNone
     */
    return JSAvatarStyleNone;
}

- (JSInputBarStyle)inputBarStyle
{
    /*
     JSInputBarStyleDefault,
     JSInputBarStyleFlat
     
     */
    return JSInputBarStyleFlat;
}

//  Optional delegate method
//  Required if using `JSMessagesViewTimestampPolicyCustom`
//
//  - (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
//

#pragma mark - Messages view data source
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"]){
        return [[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"];
    }
    return nil;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.timestamps objectAtIndex:indexPath.row];
}

- (UIImage *)avatarImageForIncomingMessage
{
    return nil;
}

- (UIImage *)avatarImageForOutgoingMessage
{
    return nil;
}

- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"]){
        return [[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"];
    }
    return nil;
    
}

#pragma UIImagePicker Delegate

#pragma mark - Image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Chose image!  Details:  %@", info);
    
    self.willSendImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.messageArray addObject:[NSDictionary dictionaryWithObject:self.willSendImage forKey:@"Image"]];
    [self.timestamps addObject:[NSDate date]];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
    
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
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
@end