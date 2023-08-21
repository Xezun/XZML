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
@property (weak, nonatomic) IBOutlet UISwitch *securitySwitch;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = rgb(0xf1f2f3);
    self.textLabel.backgroundColor = UIColor.whiteColor;
    
    [XZMLParser setFontName:@"AmericanTypewriter" forAbbreviation:@"D"];
    [XZMLParser setFontName:@"AmericanTypewriter-Bold" forAbbreviation:@"B"];
    
    [XZMLParser setFontName:@"PingFangSC-Light" forAbbreviation:@"L"];
    [XZMLParser setFontName:@"PingFangSC-Regular" forAbbreviation:@"T"];
    [XZMLParser setFontName:@"PingFangSC-Medium" forAbbreviation:@"M"];
    [XZMLParser setFontName:@"PingFangSC-Semibold" forAbbreviation:@"S"];
    
    [self.securitySwitch sendActionsForControlEvents:UIControlEventValueChanged];
    
    NSString *urlString = @"https://www.baidu.com/s?wd=XZML&ua=app#home".xz_stringByAddingURIEncoding.stringByEscapingXZMLCharacters;
    NSString *xmmlString = [NSString stringWithFormat:@"<%@~F00#S@20&百度一下> <T@20&333#你就知道>", urlString];
    self.textView.linkTextAttributes = @{ };
    self.textView.attributedText     = [[NSAttributedString alloc] initWithXZMLString:xmmlString];
    self.textView.delegate           = self;
}

- (IBAction)securitySwitchAction:(UISwitch *)sender {
    id const attributes = @{
        NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:17.0],
        XZMLFontAttributeName: [UIFont fontWithName:@"AmericanTypewriter" size:17.0],
        XZMLSecurityAttributeName: @(self.securitySwitch.isOn),
        XZMLForegroundColorAttributeName: UIColor.orangeColor,
        XZMLBackgroundColorAttributeName: UIColor.purpleColor,
    };
    
    void (^const appendXZML)(NSMutableAttributedString *, NSString *, NSDictionary *, BOOL) = ^(NSMutableAttributedString *attributedText, NSString *XZMLString, NSDictionary *attributes, BOOL spacing) {
        [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:XZMLString attributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:14.0],
            NSForegroundColorAttributeName: UIColor.grayColor
        }]];
        [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [attributedText appendAttributedStringWithXZMLString:XZMLString defaultAttributes:attributes];
        [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:spacing ? @"\n\n" : @"\n"]];
    };
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithXZMLString:@"" defaultAttributes:attributes];
    
    appendXZML(attributedText, @"在 <S&XZML> 中，<F00#元素的位置>是任意的。", attributes, YES);
    
    appendXZML(attributedText, @"<#默认前景色> <@#默认背景色>", attributes, NO);
    appendXZML(attributedText, @"<0F0#绿色前景色<@AAA#继承绿色前景色>>", attributes, YES);
    
    appendXZML(attributedText, @"<F00#红色前景色> <@F00#红色背景色>", attributes, NO);
    appendXZML(attributedText, @"<FFF@000#白色前景+黑色背景色>", attributes, YES);
    
    appendXZML(attributedText, @"日利率 0.02% 0.08%", attributes, NO);
    appendXZML(attributedText, @"日利率 <&0.02% 0.08%>", attributes, YES);
    
    appendXZML(attributedText, @"日利率 <D&0.02% 0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <@20&0.02% 0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <D@20&0.02%> 0.08%", attributes, YES);
    appendXZML(attributedText, @"日利率 <B@20&0.02%> 0.08%", attributes, YES);
    
    appendXZML(attributedText, @"日利率 <&0.02%> <AAA#$0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <&0.02%> <AAA#0$0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <&0.02%> <AAA#0@0$0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <&0.02%> <AAA#0@1$0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <&0.02%> <AAA#0@2$0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <&0.02%> <AAA#0@2@F00$0.08%>", attributes, YES);
    
    appendXZML(attributedText, @"日利率 <&0.02%> <AAA#1$0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <&0.02%> <AAA#1@0$0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <&0.02%> <AAA#1@1$0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <&0.02%> <AAA#1@2$0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <&0.02%> <AAA#1@2@F00$0.08%>", attributes, YES);
    
    appendXZML(attributedText, @"日利率 <&*0.02%> <AAA#$*0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <*&0.02%> <*AAA#$0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <@8*<&0.02%> <AAA#$0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <&谢绝查看*0.02%> <AAA#$0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <AAA#谢绝查看@1*000#&0.02%> <AAA#暂不公开@1*$0.08%>", attributes, NO);
    appendXZML(attributedText, @"日利率 <&@0*0.02%> <AAA#@0*$0.08%>", attributes, YES);
    
    self.textLabel.attributedText = attributedText;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    NSLog(@"点击了链接: %@ %@", URL, NSStringFromRange(characterRange));
    return NO;
}



@end
