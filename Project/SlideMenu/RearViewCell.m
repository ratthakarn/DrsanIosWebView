//
//  RearViewCell.m
//  Universal
//
//  Created by Mu-Sonic on 07/11/2015.
//  Copyright © 2018 Sherdle. All rights reserved.
//

#import "RearViewCell.h"
#import "AppDelegate.h"

@implementation RearViewCell

- (void)awakeFromNib {
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    self.textLabel.textColor = MENU_TEXT_COLOR;

    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = SELECTED_COLOR;
    [self setSelectedBackgroundView:bgColorView];
    [super awakeFromNib];
}

- (void)prepareForReuse {
    self.imageView.image = nil;
    [super prepareForReuse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
