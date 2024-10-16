//
//  XZMLParser.h
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import <Foundation/Foundation.h>
#import <XZML/XZMLDSL.h>
#import <XZML/XZMLDefines.h>

NS_ASSUME_NONNULL_BEGIN

/// 解析 XZML 的对象，不需要实例化。
@interface XZMLParser : NSObject

// MARK: - 公开方法

/// 解析 XZML 为富文本对象。
/// @param XZMLString XZML 字符串
/// @param attributes 默认属性
+ (NSMutableAttributedString *)parse:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;

/// 解析 XZML 为富文本。
/// @discussion 默认属性中，
/// @discussion 1、`NS-`属性，为所有文字默认属性；
/// @discussion 2、`XZML-`属性，为`XZML`元素样式解析时的默认值应用于XZML文本，并覆盖同名的默认属性。
/// @param XZMLString XZML
/// @param attributedString 接收 XZML 富文本的对象
/// @param attributes 默认属性 attributes
+ (void)attributedString:(NSMutableAttributedString *)attributedString parse:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;

/// 将 XZML 去掉样式，转为纯文本。
/// @param XZMLString XZML 字符串
/// @param string 接收 XZML 中纯文本的对象
/// @param attributes 默认属性，比如在安全模式下，会得到被替换的字符
+ (void)string:(NSMutableString *)string parse:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;

// MARK: - 子类可通过重写如下方法来自定义解析过程

/// 字符 character 是否为元素起始符，即，能否开始元素的解析。
/// - 返回 XZMLElementNotAnElement 表示 character 不是元素的起始字符；
/// - 返回其它值，表示以该值作为元素结束符，开始元素的识别。
/// - Parameter character: 待判断是否为元素起始符的字符
+ (XZMLElement)shouldBeginElement:(char)character;

/// 在元素 element 中是否遇识别到样式标记符号。
/// - Parameters:
///   - element: 当前正识别中的元素
///   - character: 待判断是否为样式标记符的字符
+ (BOOL)element:(XZMLElement)element shouldBeginAttribute:(char)character;

/// 开启解析元素。
/// - Parameters:
///   - element: 被解析的元素的标记
///   - attributes: 被解析的元素的富文本属性
+ (void)didBeginElement:(XZMLElement)element attributes:(NSMutableDictionary<NSAttributedStringKey, id> *)attributes;

/// 已识别出元素中的样式。
/// - Note: 在识别属性的过程中，可以通过属性来提前终止元素的解析，比如安全字符替换。
/// - Parameters:
///   - element: 识别中的元素
///   - style: 已识别的样式
///   - value: 识别出的样式值
///   - attributes: 当前元素的富文本属性
/// - Returns: 返回 nil 表示当前元素，则继续解析元素；返回富文本，则表示元素已不需要继续解析，直接使用返回的富文本。
+ (nullable NSAttributedString *)element:(XZMLElement)element didEndAttribute:(XZMLAttribute)style value:(NSString *)value attributes:(NSMutableDictionary<NSAttributedStringKey,id> *)attributes;

/// 已识别文本。
/// - Parameters:
///   - element: 当前识别中的元素
///   - text: 已识别出的文本
///   - fragment: 文本可能会被子元素分割，该参数表明当前文本是其中的是第几段
///   - attributes: 富文本属性
+ (nullable NSAttributedString *)element:(XZMLElement)element didEndText:(NSString *)text fragment:(NSUInteger)fragment attributes:(NSMutableDictionary<NSAttributedStringKey,id> *)attributes;

/// 元素识别结束
/// - Parameter element: 当前识别中的元素
+ (void)didEndElement:(XZMLElement)element;

@end


@class UITableView;

@interface XZMLParser (XZMLExtendedParser)

/// 设置字体名在 XZML 中的缩写。
/// @param fontName 字体名
/// @param abbreviation 字体名缩写
+ (void)setFontName:(nullable NSString *)fontName forAbbreviation:(NSString *)abbreviation;

/// 通过缩写获取字体名，如果不是缩写名，返回 abbreviation 自身。
/// @param abbreviation 字体名缩写
+ (NSString *)fontNameForAbbreviation:(NSString *)abbreviation;

@end



NS_ASSUME_NONNULL_END
