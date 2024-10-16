//
//  ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "ViewController.h"
@import XZML;
@import XZExtensions;

@interface ViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UISwitch *securityModeSwitch;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = rgb(0xf1f2f3);
    self.textLabel.backgroundColor = UIColor.whiteColor;
    
    self.textLabel.text = self.XZMLString;
    self.textView.font = [UIFont systemFontOfSize:20.0];
    self.textView.linkTextAttributes = @{ };
    self.textView.delegate           = self;
    
    [self securitySwitchAction:self.securityModeSwitch];
}

- (IBAction)securitySwitchAction:(UISwitch *)sender {
    id const attributes = @{
        NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:17.0],
        XZMLFontAttributeName: [UIFont fontWithName:@"AmericanTypewriter" size:17.0],
        XZMLSecurityModeAttributeName: @(self.securityModeSwitch.isOn),
        XZMLForegroundColorAttributeName: UIColor.orangeColor,
        XZMLBackgroundColorAttributeName: UIColor.purpleColor,
    };
    
    [self.textView setXZMLText:self.XZMLString attributes:attributes];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    NSString *message = [NSString stringWithFormat:@"点击了链接: %@ %@", URL, NSStringFromRange(characterRange)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    return NO;
}



@end
