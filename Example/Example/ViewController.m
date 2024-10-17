//
//  ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "ViewController.h"
#import "SettingsViewController.h"
@import XZML;
@import XZExtensions;

@interface ViewController () <UITextViewDelegate> {
    NSMutableDictionary<NSAttributedStringKey, id> *_attributes;
}

@property (weak, nonatomic) IBOutlet UILabel *stringLabel;
@property (weak, nonatomic) IBOutlet UITextView *XZMLView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UISwitch *securityModeSwitch;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = rgb(0xf1f2f3);
    
    self.title = self.data[@"title"];
    
    _attributes = [NSMutableDictionary dictionaryWithDictionary:@{
        XZMLFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0],
        XZMLSecurityModeAttributeName: @(self.securityModeSwitch.isOn),
        XZMLForegroundColorAttributeName: UIColor.orangeColor,
        XZMLBackgroundColorAttributeName: UIColor.systemPinkColor
    }];
    
    NSString *xzml = self.data[@"xzml"];
    
    self.stringLabel.text = xzml;
    
    self.XZMLView.font = [UIFont systemFontOfSize:20.0];
    self.XZMLView.linkTextAttributes = @{ };
    self.XZMLView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData {
    NSString *xzml = self.data[@"xzml"];
//    self.XZMLView.attributedText = [[NSAttributedString alloc] initWithXZMLString:xzml attributes:_attributes];
    [self.XZMLView setXZMLText:xzml attributes:_attributes];
    self.textLabel.text = [[NSString alloc] initWithXZMLString:xzml attributes:_attributes];
}

- (IBAction)securitySwitchAction:(UISwitch *)sender {
    _attributes[XZMLForegroundColorAttributeName] = @(self.securityModeSwitch.isOn);
    [self reloadData];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    NSString *message = [NSString stringWithFormat:@"%@", URL];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"链接点击" message:message preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SettingsViewController *settingsVC = segue.destinationViewController;
    if ([settingsVC isKindOfClass:[SettingsViewController class]]) {
        settingsVC.attributes = _attributes;
    }
}

@end
