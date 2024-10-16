//
//  UIKit+XZML.h
//  XZKit
//
//  Created by Xezun on 2021/10/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XZMLTextView <NSObject>
- (void)setXZMLText:(nullable NSString *)XZMLString attributes:(nullable NSDictionary<NSString *, id> *)attributes;
- (void)setXZMLText:(nullable NSString *)XZMLString;
@end

@interface UILabel (XZML) <XZMLTextView>
@end

@interface UIButton (XZML)
- (void)setXZMLTitle:(nullable NSString *)XZMLString forState:(UIControlState)state attributes:(nullable NSDictionary<NSString *, id> *)attributes;
- (void)setXZMLTitle:(nullable NSString *)XZMLString forState:(UIControlState)state;
@end

@interface UITextView (XZML) <XZMLTextView>
@end

@interface UITextField (XZML) <XZMLTextView>
@end

NS_ASSUME_NONNULL_END
