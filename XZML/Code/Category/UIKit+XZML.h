//
//  UIKit+XZML.h
//  XZKit
//
//  Created by Xezun on 2021/10/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (XZML)

- (void)setAttributedTextWithXZMLString:(nullable NSString *)XZMLString defaultAttributes:(nullable NSDictionary<NSString *, id> *)defaultAttributes;
- (void)setAttributedTextWithXZMLString:(nullable NSString *)XZMLString;

@end

@interface UIButton (XZML)

- (void)setAttributedTitleWithXZMLString:(nullable NSString *)XZMLString forState:(UIControlState)state defaultAttributes:(nullable NSDictionary<NSString *, id> *)defaultAttributes;
- (void)setAttributedTitleWithXZMLString:(nullable NSString *)XZMLString forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
