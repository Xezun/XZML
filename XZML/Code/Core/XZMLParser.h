//
//  XZMLParser.h
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import <Foundation/Foundation.h>
#import <XZML/XZMLDSL.h>

NS_ASSUME_NONNULL_BEGIN

/// @attention 新增枚举请同时调整 NSCharacterSet.XZMLCharacterSet 字符集。
enum : XZMLAttribute {
    /// 文本前景色、背景色样式。
    /// 格式：前景色、@背景色、前景色@背景色
    /// @discussion 颜色使用十六进制 RGB/RGBA 值。
    /// @discussion 1、仅前景色（无`@`符号）时，表示仅设置前景色，背景色继承上层。
    /// @discussion 2、无前景色（有`@`符号）时，表示仅设置背景色，前景色继承上层。
    /// @discussion 3、其它情形，表示示同时指定前景色和背景色。
    /// @discussion 4、解析颜色时，以`defaultAttributes`设置的值作为默认值，如没有设置默认值，则不处理。
    /// @discussion 5、通过键名 XZMLForegroundColorAttributeName、XZMLBackgroundColorAttributeName 设置默认值。
    XZMLAttributeColor = '#',
    /// 文本字体字号样式。
    /// 格式：字体、@字号、字体@字号、字体@字号@基准线偏移
    /// @discussion 使用 XZMLFontAttributeName 设置解析时的默认字号。
    /// @discussion 1、仅指定字体时，按根据上层字体、默认解析字体、默认字体的先后顺序继承字号，找不到字号不处理；
    /// @discussion 2、仅指定字号时，按根据上层字体、默认解析字体、默认字体的先后顺序继承字体，找不到字体不处理；
    /// @discussion 3、同时指定字体字号时，如果无法生成字体，那么回退到仅字号的情形处理；
    /// @discussion 4、使用 +setFoneName:forAbbreviation: 方法注册字体名缩写，以减少`XZML`的长度。
    /// @note 推荐字体缩写约定
    /// @discussion 1、数字常规：DR、D
    /// @discussion 2、数字粗体：DB、B
    /// @discussion 3、文本细体：TL、L
    /// @discussion 4、文本常规：TR、T
    /// @discussion 5、文本中等：TM、M
    /// @discussion 6、文本中粗：TS、S
    XZMLAttributeFont = '&',
    /// 文本修饰样式。
    /// 格式：样式、样式@线型、样式@线型@颜色
    /// @discussion【样式】0，删除线（默认）；1，下划线
    /// @discussion【线型】0，单线条（默认）；1，双线条；2，粗线条
    /// @discussion【颜色】RGB/RGBA 颜色值，默认与文本颜色相同
    /// @attention 文本修饰，包含多个样式，因此使用属性默认值解析，设置文本修饰样式，只会覆盖上层相同样式的设置。
    /// @discussion 比如设置删除线样式，上层设置删除线样式会被覆盖，但是上层的下划线样式会保留。
    /// @discussion 可以使用两个`$`可同时指定下划线和删除线。
    XZMLAttributeDecoration = '$',
    /// 安全模式下需用替代字符占位的文本样式。
    /// 格式：替代符号、@重复次数、替代符号@重复次数。
    /// @discussion 替代符号默认为`*`星号，重复次数为4次，即4个`*`星号。
    /// @discussion 安全模式替换时，忽略所有子元素。
    /// @attention 在安全模式下，星号`*`之后样式、文本、子元素都会被忽略，因此通过`*`的位置控制替代字符的样式。
    /// @discussion 比如将删除线样式放在`*`之后，安全模式下，替代字符不会展示删除线。
    XZMLAttributeSecurity = '*',
    /// 超链接。
    /// @discussion 将使用 NSURL 或 NSString 创建富文本 NSLinkAttributeName 属性。
    XZMLAttributeLink = '~',
    /// 段落。
    /// @discussion 支持的段落属性包括：
    /// @discussion H：minimumLineHeight 最小行高，默认
    /// @discussion M：maximumLineHeight 最大行高
    /// @discussion X：lineHeightMultiple 多倍行高
    /// @discussion A：alignment 对齐方式，与枚举值对应
    /// @discussion K：lineBreakMode 断行方式，与枚举值对应
    /// @discussion S：lineSpacing 行间距（行与行之间的距离）
    /// @discussion W：baseWritingDirection 书写方向，与枚举值对应
    /// @discussion F：firstLineHeadIndent 首行缩进
    /// @discussion I：headIndent 头缩进
    /// @discussion T：tailIndent 尾缩进
    /// @discussion P：paragraphSpacing 段间距
    /// @discussion B：paragraphSpacingBefore 段前距
    /// @discussion 格式：[值][标记]
    /// @discussion 如果未指定样式标记符，则默认为最小行高`H`样式。示例：
    /// @code
    /// NSString *XZML1 = @"<20H30M^Paragraph>";   // 最小行高 20.0 point 最大行高 30.0 point
    /// NSString *XZML2 = @"<1.5X^Paragraph>";     // 1.5 倍行高
    /// NSString *XZML3 = @"<1.5X^Paragraph>";     // 1.5 倍行高
    /// NSString *XZML4 = @"<34F20X^Paragraph>";   // 首行缩进 34.0 point 行高 20.0 point
    /// @endcode
    /// @discussion 由于样式标记的存在，样式间隔符`@`是可选的，样式顺序也是任意的。
    XZMLAttributeParagraph = '^',
};

@interface NSCharacterSet (XZML)
/// XZML 的标记字符集。
/// @attention 新增 XZML 标记需更新此字符集。
@property (class, readonly) NSCharacterSet *XZMLCharacterSet;
@end

@class XZMLParser;

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
FOUNDATION_EXPORT NSAttributedStringKey const XZMLSecurityAttributeName;

@interface XZMLParser : NSObject

// MARK: - 公开方法

/// 解析 XZML 为富文本。
/// @discussion 默认属性中，
/// @discussion 1、`NS-`属性，为所有文字默认属性；
/// @discussion 2、`XZML-`属性，为`XZML`元素样式解析时的默认值应用于XZML文本，并覆盖同名的默认属性。
/// @param XZMLString XZML
/// @param attributedString 接收 XZML 富文本的对象
/// @param defaultAttributes 默认属性
- (void)parse:(NSString *)XZMLString attributedString:(NSMutableAttributedString *)attributedString defaultAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)defaultAttributes;
/// 解析 XZML 为富文本对象。
/// @param XZMLString XZML 字符串
/// @param defaultAttributes 默认属性
- (NSMutableAttributedString *)parse:(NSString *)XZMLString defaultAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)defaultAttributes;

/// 解析 XZML 为纯文本。
/// @param XZMLString XZML 字符串
/// @param string 接收 XZML 中纯文本的对象
/// @param defaultAttributes 默认属性，比如在安全模式下，会得到被替换的字符
- (void)parse:(NSString *)XZMLString string:(NSMutableString *)string defaultAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)defaultAttributes;

// MARK: - 事件方法

- (XZMLElement)shouldRecognizeElement:(char)character;
- (BOOL)element:(XZMLElement)element shouldRecognizeAttribute:(char)character;

- (void)didBeginElement:(XZMLElement)element;
- (BOOL)element:(XZMLElement)element didRecognizeAttribute:(XZMLAttribute)attribute value:(NSString *)value;
- (void)element:(XZMLElement)element didRecognizeText:(NSString *)text fragment:(NSUInteger)fragment;
- (void)didEndElement:(XZMLElement)element;

@end


@interface XZMLParser (XZMLExtendedParser)

/// 设置字体名缩写。
/// @param fontName 字体名
/// @param abbreviation 字体名缩写
+ (void)setFontName:(nullable NSString *)fontName forAbbreviation:(NSString *)abbreviation;
/// 通过缩写获取字体名，如果不是缩写名，返回 abbreviation 自身。
/// @param abbreviation 字体名缩写
+ (NSString *)fontNameForAbbreviation:(NSString *)abbreviation;

/// 当前正被解析的元素的富文本属性。如果没有元素被解析，则为默认属性。
@property (nonatomic, readonly) NSDictionary<NSAttributedStringKey, id> *attributes;
/// 设置富文本属性，仅对当前正在解析的元素生效。
/// @param value 属性值
/// @param attribute 属性名
- (void)setValue:(nullable id)value forAttribute:(NSAttributedStringKey)attribute;
/// 获取当前正被解析的元素的指定富文本属性。
/// @param attribute 属性名
- (nullable id)valueForAttribute:(NSAttributedStringKey)attribute;

@end



NS_ASSUME_NONNULL_END
