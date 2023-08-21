//
//  UIKit+XZML.m
//  XZKit
//
//  Created by Xezun on 2021/10/19.
//

#import "UIKit+XZML.h"
#import "Foundation+XZML.h"

@implementation UILabel (XZML)

- (void)setAttributedTextWithXZMLString:(NSString *)XZMLString defaultAttributes:(nullable NSDictionary<NSString *,id> *)defaultAttributes {
    // 读取字体、字体颜色的默认值
    if (defaultAttributes[NSFontAttributeName] == nil || defaultAttributes[NSForegroundColorAttributeName] == nil) {
        self.text = nil;
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:defaultAttributes.count + 2];
        attributes[NSFontAttributeName]            = self.font;
        attributes[NSForegroundColorAttributeName] = self.textColor;
        if (defaultAttributes.count > 0) {
            [attributes addEntriesFromDictionary:defaultAttributes];
        }
        defaultAttributes = attributes;
    }
    self.attributedText = [[NSMutableAttributedString alloc] initWithXZMLString:XZMLString defaultAttributes:defaultAttributes];
}

- (void)setAttributedTextWithXZMLString:(NSString *)XZMLString {
    [self setAttributedTextWithXZMLString:XZMLString defaultAttributes:nil];
}

@end

@implementation UIButton (XZML)

- (void)setAttributedTitleWithXZMLString:(NSString *)XZMLString forState:(UIControlState)state defaultAttributes:(nullable NSDictionary<NSString *,id> *)defaultAttributes {
    // 读取字体、字体颜色的默认值
    if (defaultAttributes[NSFontAttributeName] == nil || defaultAttributes[NSForegroundColorAttributeName] == nil) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:defaultAttributes.count + 2];
        attributes[NSFontAttributeName]            = self.titleLabel.font;
        attributes[NSForegroundColorAttributeName] = [self titleColorForState:state] ?: [self titleColorForState:(UIControlStateNormal)];
        if (defaultAttributes.count > 0) {
            [attributes addEntriesFromDictionary:defaultAttributes];
        }
        defaultAttributes = attributes;
    }
    id const title = [[NSMutableAttributedString alloc] initWithXZMLString:XZMLString defaultAttributes:defaultAttributes];
    [self setAttributedTitle:title forState:state];
}

- (void)setAttributedTitleWithXZMLString:(NSString *)XZMLString forState:(UIControlState)state {
    [self setAttributedTitleWithXZMLString:XZMLString forState:state defaultAttributes:nil];
}

@end
