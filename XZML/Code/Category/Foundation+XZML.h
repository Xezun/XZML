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
/// @param XZMLString XZML 字符串
/// @param attributes 默认属性
- (instancetype)initWithXZMLString:(nullable NSString *)XZMLString attributes:(nullable NSDictionary<NSString *, id> *)attributes NS_SWIFT_NAME(init(XZML:attributes:));
@end

@interface NSAttributedString (XZML) <XZMLSupporting>
/// 通过 XZML 字符串构造富文本。
/// @param XZMLString XZML 字符串
- (instancetype)initWithXZMLString:(nullable NSString *)XZMLString NS_SWIFT_NAME(init(XZML:));
@end

@interface NSMutableAttributedString (XZML)
/// 使用 XZML 添加富文本。
/// @param XZMLString XZML
/// @param attributes 默认属性
- (void)appendXZMLString:(nullable NSString *)XZMLString attributes:(nullable NSDictionary<NSString *,id> *)attributes NS_SWIFT_NAME(append(XZML:attributes:));
@end

@interface NSString (XZML) <XZMLSupporting>

/// 通过 XZML 字符串构造文本。
/// @param XZMLString XZML 字符串
- (instancetype)initWithXZMLString:(nullable NSString *)XZMLString NS_SWIFT_NAME(init(XZML:));

/// 将字符串中的 XZML 保留字符添加反斜线转义字符，以便将字符串作为纯文本插入到 XZML 中。
@property (nonatomic, readonly) NSMutableString *stringByEscapingXZMLCharacters NS_SWIFT_NAME(escapingXZMLCharacters);

@end

@interface NSMutableString (XZML)
@end


NS_ASSUME_NONNULL_END

