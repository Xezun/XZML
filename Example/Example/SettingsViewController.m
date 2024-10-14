//
//  SettingsViewController.m
//  Example
//
//  Created by 徐臻 on 2024/10/17.
//

#import "SettingsViewController.h"
#import "SelectFontSizeViewController.h"
@import XZML;

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)unwindToSettingsViewController:(UIStoryboardSegue *)unwindSegue {
    __kindof UIViewController * sourceViewController = unwindSegue.sourceViewController;
    if ([sourceViewController isKindOfClass:[SelectFontSizeViewController class]]) {
        SelectFontSizeViewController *selector = sourceViewController;
        NSString *fontName = selector.fontName;
        CGFloat fontSize = selector.fontSize;
        _attributes[XZMLFontAttributeName] = [UIFont fontWithName:fontName size:fontSize];
    }
}

@end
