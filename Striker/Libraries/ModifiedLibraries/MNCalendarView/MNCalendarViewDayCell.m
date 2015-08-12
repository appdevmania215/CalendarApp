//
//  MNCalendarViewDayCell.m
//  MNCalendarView
//
//  Created by Min Kim on 7/28/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarViewDayCell.h"

NSString *const MNCalendarViewDayCellIdentifier = @"MNCalendarViewDayCellIdentifier";

@interface MNCalendarViewDayCell()

@property(nonatomic,strong,readwrite) NSDate *date;
@property(nonatomic,strong,readwrite) NSDate *month;
@property(nonatomic,assign,readwrite) NSUInteger weekday;

@end

@implementation MNCalendarViewDayCell

- (void)setDate:(NSDate *)date
          month:(NSDate *)month
       calendar:(NSCalendar *)calendar {
  
  self.date     = date;
  self.month    = month;
  self.calendar = calendar;
  
  NSDateComponents *components =
  [self.calendar components:NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                   fromDate:self.date];
  
  NSDateComponents *monthComponents =
  [self.calendar components:NSMonthCalendarUnit
                   fromDate:self.month];
  
  self.weekday = components.weekday;
  self.titleLabel.text = [NSString stringWithFormat:@"%d", components.day];
  self.enabled = monthComponents.month == components.month;
  
  [self setNeedsDisplay];
}

- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  
  self.titleLabel.textColor =
  self.enabled ? UIColor.darkTextColor : UIColor.lightGrayColor;
  
  self.backgroundColor =
  self.enabled ? UIColor.whiteColor : [UIColor colorWithRed:.96f green:.96f blue:.96f alpha:1.f];
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGColorRef separatorColor = self.separatorColor.CGColor;
  
  CGSize size = self.bounds.size;
  
  if (self.weekday != 7) {
    CGFloat pixel = 1.f / [UIScreen mainScreen].scale;
    MNContextDrawLine(context,
                      CGPointMake(size.width - pixel, pixel),
                      CGPointMake(size.width - pixel, size.height),
                      separatorColor,
                      pixel);
  }
    
  if (_status != 0)
  {
      CGContextSetLineCap(context, kCGLineCapRound);
      CGContextSetLineWidth(context, MIN(size.width, size.height)/4);
      
      if (_status / 10 == 1 || _status / 10 == 3 )
          CGContextSetRGBStrokeColor(context, 0.50, 0.50, 1.00, 1.0);
      //CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
      else if (_status % 10 == 1 || _status % 10 == 3)
          CGContextSetRGBStrokeColor(context, 0.95, 0.95, 0.45, 1.0);
          //CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
      else
          CGContextSetRGBStrokeColor(context, 1, 1, 1, 1.0);
          //CGContextSetRGBStrokeColor(context, 0.50, 0.00, 0.50, 1.0);
          
      
      int beginX = size.width / 3.0;
      int beginY = size.height * 2.0 / 3.0;
      
      CGContextMoveToPoint(context, beginX, beginY);
      CGContextAddLineToPoint(context, beginX, beginY);
      CGContextStrokePath(context);
      
      if (_status / 10 == 2 || _status / 10 == 3 )
          CGContextSetRGBStrokeColor(context, 0.50, 0.50, 1.00, 1.0);
      else if (_status % 10 == 2 || _status % 10 == 3)
          CGContextSetRGBStrokeColor(context, 0.95,0.95,0.45, 1.0);
      else
          CGContextSetRGBStrokeColor(context, 1, 1, 1, 1.0);
      
      beginX = size.width * 2.0 / 3.0;
      
      CGContextMoveToPoint(context, beginX, beginY);
      CGContextAddLineToPoint(context, beginX, beginY);
      CGContextStrokePath(context);
      
      CGContextFlush(context);
  }
}

@end
