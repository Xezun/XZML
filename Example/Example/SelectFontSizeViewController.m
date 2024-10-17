//
//  SelectFontSizeViewController.m
//  Example
//
//  Created by 徐臻 on 2024/10/17.
//

#import "SelectFontSizeViewController.h"

@interface SelectFontSizeViewController ()

@end

@implementation SelectFontSizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    if ([sender isKindOfClass:UITableViewCell.class]) {
        self.fontSize = sender.textLabel.text.doubleValue;
    }
}

@end
