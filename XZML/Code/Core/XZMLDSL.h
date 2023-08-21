//
//  XZMLDSL.h
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// XZML 元素标记字符，一般使用成对的 ASCII 字符作为元素标记字符。
/// @note XZML 使用结束标记符来代表或区分元素。
typedef char XZMLElement;
/// XZML 属性标记字符，一般使用 ASCII 特殊标点符号作为标记字符。
typedef char XZMLAttribute;

enum : XZMLElement {
    /// 标识非 XZML 元素的标记。
    XZMLElementNotAnElement = '\0'
};

enum : XZMLAttribute {
    /// 标识 XZML 元素中普通文本的属性。
    XZMLAttributeText = '\0'
};

/// XZML 元素识别器。
/// @discussion 返回元素的结束标记符，表示 character 是一个元素的开始标记符。
/// @discussion 返回 XZMLElementNotAnElement 表示 character 不是元素标记符。
/// @param character 元素的开始标记
/// @returns 返回元素的结束标记
typedef XZMLElement (^XZMLDSLElementRecognizer)(char character);

/// XZML 元素属性识别器。
/// @param element 当前正识别的元素
/// @param character 标记符
/// @return 参数 character 是否为元素属性标记符
typedef BOOL (^XZMLDSLAttributeRecognizer)(XZMLElement element, char character);

/// 开始识别元素。
/// @param element 元素的结束标记符
typedef void (^XZMLDSLDidBeginElement)(XZMLElement element);

/// 识别了属性。
/// @param element 元素
/// @param attribute 属性
/// @param value 属性原始值
/// @returns 返回 NO 将终止解析当前元素及子元素
typedef BOOL (^XZMLDSLDidRecognizeAttribute)(XZMLElement element, XZMLElement attribute, NSString *value);

/// 识别了文本。
/// @discussion 元素文本会被子元素分隔，从而导致元素的文本会被分段识别。
/// @note 一旦开始了识别文本 XZML 将不再识别样式。
/// @param element 元素，如果为 XZMLElementNotAnElement 则表示文本不在元素内
/// @param text 文本
/// @param fragment 当前被识别的文本是当前元素的第几段文本，从0计数
typedef void (^XZMLDSLDidRecognizeText)(XZMLElement element, NSString *text, NSUInteger fragment);

/// 识别元素结束，或者整个字符串识别结束。
/// @param element 元素的结束标记符
typedef void (^XZMLDSLDidEndElement)(XZMLElement element);

/// XZML 语法分析。
/// @discussion XZML 是一种简化的超文本标记语言，只将 ASCII 字符作为元素和属性标记字符，支持简单的标记和套用规则，用最少的字符描述富文本。
/// @param XZMLString 字符串
/// @param elementRecognizer 元素识别
/// @param attributeRecognizer 元素属性识别
/// @param didBeginElement 开始识别元素事件
/// @param didRecognizeAttribute 识别出了属性事件
/// @param didRecognizeText 识别出了文本事件
/// @param didEndElement 元素识别结束事件
FOUNDATION_EXPORT void XZMLDSL(NSString *XZMLString, NS_NOESCAPE XZMLDSLElementRecognizer elementRecognizer, NS_NOESCAPE XZMLDSLAttributeRecognizer attributeRecognizer, NS_NOESCAPE XZMLDSLDidBeginElement didBeginElement, NS_NOESCAPE XZMLDSLDidRecognizeAttribute didRecognizeAttribute, NS_NOESCAPE XZMLDSLDidRecognizeText didRecognizeText, NS_NOESCAPE XZMLDSLDidEndElement didEndElement);


NS_ASSUME_NONNULL_END
