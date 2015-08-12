//
//  CityCell.h
//  Striker
//
//  Created by James on 11/17/14.
//  Copyright (c) 2014 Semanggi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelCityName;
@property (weak, nonatomic) IBOutlet UIView *selectedStatus;

- (void)configureCellWithData:(NSDictionary *)data;

@end
