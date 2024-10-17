//
//  XZMLDefines.h
//  XZML
//
//  Created by 徐臻 on 2024/10/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 通过此属性名指定 XZML 解析时的默认字体。
/// @discussion 值为 UIFont 对象。
/// @discussion 设置（未被字体标记修饰的文本的）默认字体直接使用 NSFontAttributeName 属性名。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLFontAttributeName;

/// 通过此属性名指定 XZML 解析时的默认前景色。
/// @discussion 值为代表前景色的 UIColor 对象。
/// @discussion 设置（未被颜色标记修饰的文本的）默认字体直接使用 NSForegroundColorAttributeName 属性名。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLForegroundColorAttributeName;

/// 通过此属性名指定 XZML 解析时的默认背景色。
/// @discussion 值为代表背景色的 UIColor 对象。
/// @discussion 设置（未被颜色标记修饰的文本的）默认字体直接使用 NSBackgroundColorAttributeName 属性名。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLBackgroundColorAttributeName;

/// 通过此属性名指定 XZML 解析时安全模式。
/// @discussion 值为布尔值，YES 表示当前为安全模式，NO 为非安全模式。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLSecurityModeAttributeName;

/// 安全文本替代字符。默认替代字符为 `*` 星号。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLSecurityMarkAttributeName;

/// 安全文本替代字符重复次数。
/// @note 如果设置 0 表示使用默认值：替代字符为单字符，重复次数默认与安全文本字符数相同；替代字符为多字符，重复次数为 1 次。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLSecurityRepeatAttributeName;


NS_ASSUME_NONNULL_END
