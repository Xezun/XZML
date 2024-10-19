//
//  XZMLDefines.h
//  XZML
//
//  Created by 徐臻 on 2024/10/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 元素属性应用规则：
// 1、如果 XZML 指定了的样式属性的值（简称指定值），那么直接使用该值。
// 2、如果 XZML 只有样式标记，而没有指定值，那么可通过 XZML~AttributeName 键在 attributes 参数提供一个预设值。
// 3、如果指定值不合法，或没有提供预设值，那么元素将优先从父元素继承；顶层元素，则使用 attributes 参数中以 NS~AttributeName 为键的默认值。
// 4、如果指定值、预设值、父层值、默认值都没有，则会使用兜底值，比如字体会使用系统字体等。
// 5、样式属性可能会有多个子属性，但是通过 XZML~AttributeName 键，只能为默认的子属性提供预设值，比如字体样式属性，虽然设置的 UIFont 对象，包含字体的名称和大小，但只有字体名是预设值。
// 6、在 XZML 中，样式属性的子属性，除了预设值的子属性外，其它子属性值必须指定值，若为空，表示从父元素继承。

/// 通过此键为 XZML 样式预设字体名。
/// @discussion 值为 UIFont 对象。
/// @discussion 只有字体名是预设值，字体大小仅在指定值、父层值、默认值都不存在时才会使用。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLFontAttributeName;

/// 通过此键为 XZML 样式预设前景色。
/// @discussion 值为代表前景色的 UIColor 对象。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLForegroundColorAttributeName;

/// 通过此键为 XZML 样式预设文本修饰类型。
/// @discussion 值为代表文本修饰类型枚举 XZMLDecorationType 的值的 NSNumber 对象。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLDecorationAttributeName;

/// 通过此键为 XZML 样式预设安全模式。
/// @discussion 值为布尔值，YES 表示当前为安全模式，NO 为非安全模式。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLSecurityModeAttributeName;

/// 通过此键为 XZML 样式预设段落（最小）行高。
/// @discussion 值为代表文本段落最小行高的 CGFloat 值的 NSNumber 对象。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLLineHeightModeAttributeName;


/// 文本修饰类型枚举。
typedef NS_ENUM(NSUInteger, XZMLDecorationType) {
    /// 删除线
    XZMLDecorationTypeStrikethrough = 0,
    /// 下划线
    XZMLDecorationTypeUnderline,
};

NS_ASSUME_NONNULL_END
