//
//  Foundation+XZML.h
//  XZKit
//
//  Created by Xezun on 2021/10/19.
//

#import <Foundation/Foundation.h>
#import <XZML/XZMLParser.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XZMLSupporting <NSObject>
@optional
/// 通过 XZML 字符串构造对象。
/// @note 本协议声明在对象的可变类上，但是实现在对象的不可变类上，因此在可变类上重写此方法，可自定义构造时所使用的解析器。
/// @param XZMLString XZML 字符串
/// @param defaultAttributes 默认属性
- (instancetype)initWithXZMLString:(nullable NSString *)XZMLString defaultAttributes:(nullable NSDictionary<NSString *, id> *)defaultAttributes;
@end

@interface NSAttributedString (XZML)
/// 通过 XZML 字符串构造富文本。
/// @param XZMLString XZML 字符串
/// @param defaultAttributes 默认属性
+ (instancetype)attributedStringWithXZMLString:(nullable NSString *)XZMLString defaultAttributes:(nullable NSDictionary<NSString *, id> *)defaultAttributes;
/// 通过 XZML 字符串构造富文本。
/// @param XZMLString XZML 字符串
+ (instancetype)attributedStringWithXZMLString:(nullable NSString *)XZMLString;
/// 通过 XZML 字符串构造富文本。
/// @param XZMLString XZML 字符串
- (instancetype)initWithXZMLString:(nullable NSString *)XZMLString;
@end

@interface NSMutableAttributedString (XZML) <XZMLSupporting>
/// 使用 XZML 添加富文本。
/// @param XZMLString XZML
/// @param defaultAttributes 默认属性
- (void)appendAttributedStringWithXZMLString:(nullable NSString *)XZMLString defaultAttributes:(nullable NSDictionary<NSString *,id> *)defaultAttributes;
@end

@interface NSString (XZML)

/// 通过 XZML 字符串构造文本。
/// @param XZMLString XZML 字符串
/// @param defaultAttributes 默认属性
+ (instancetype)stringWithXZMLString:(nullable NSString *)XZMLString defaultAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)defaultAttributes;
/// 通过 XZML 字符串构造文本对象。
/// @param XZMLString XZML 字符串
+ (instancetype)stringWithXZMLString:(nullable NSString *)XZMLString;
/// 通过 XZML 字符串构造文本。
/// @param XZMLString XZML 字符串
- (instancetype)initWithXZMLString:(nullable NSString *)XZMLString;

/// 将字符串中的 XZML 保留字符添加反斜线转义字符，以便将字符串作为纯文本插入到 XZML 中。
@property (nonatomic, readonly) NSMutableString *stringByEscapingXZMLCharacters;

@end

@interface NSMutableString (XZML) <XZMLSupporting>
@end


NS_ASSUME_NONNULL_END

