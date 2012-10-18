//
//  AutosizeTableView.m
//  Lulu
//
//  Created by Dingzhong Weng on 8/27/12.
//  Copyright (c) 2012 Oasislulu. All rights reserved.
//

#import "AutosizeTableView.h"

@implementation AutosizeTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)reloadData{
    [super reloadData];
    [self layoutIfNeeded];
    CGRect newFrame = self.frame;
    newFrame.size.height = [self contentSize].height;
    self.frame = newFrame;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
