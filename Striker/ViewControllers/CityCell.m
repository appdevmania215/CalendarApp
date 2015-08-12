//
//  CityCell.m
//  Striker
//
//  Created by James on 11/17/14.
//  Copyright (c) 2014 Semanggi. All rights reserved.
//

#import "CityCell.h"

@implementation CityCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
    if(selected == true){
        self.selectedStatus.backgroundColor = [UIColor colorWithRed:0.95 green: 0.95 blue:0.45 alpha:1.0];
    }else{
        self.selectedStatus.backgroundColor = [UIColor lightGrayColor];
    }
    
    // Configure the view for the selected state
}

- (void)configureCellWithData:(NSDictionary *)data
{
    self.labelCityName.text = data[@"CityName"];
    NSString* selected= data[@"selected"];
    if([selected isEqualToString:@"1"]){
         //self.selectedStatus.backgroundColor = [UIColor colorWithRed:0.5 green: 1.0 blue:0.5 alpha:1.0];
         //self.selected = true;
    }else{
        //self.selectedStatus.backgroundColor = [UIColor lightGrayColor];
        //self.selected = false;
    }  
    
}

@end
