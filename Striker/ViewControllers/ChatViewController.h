//
//  ChatViewController.h
//  Striker
//
//  Created by James on 11/25/14.
//  Copyright (c) 2014 Semanggi. All rights reserved.
//

#import "JSMessagesViewController.h"

@interface ChatViewController : JSMessagesViewController
@property (nonatomic) int is_sender;
@property (nonatomic) int confirmed_id;

@property (nonatomic, strong) NSMutableDictionary * match;
@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (nonatomic) BOOL isSubmitted;
@end
