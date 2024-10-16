//
//  Foundation+XZML.h
//  XZKit
//
//  Created by Xezun on 2021/10/19.
//

#import <Foundation/Foundation.h>
#import <XZML/XZMLDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (XZML)

/// 通过 XZML 字符串构造对象。
/// @param XZMLString XZML 字符串
/// @param attributes 默认属性
- (instancetype)initWithXZMLString:(nullable NSString *)XZMLString attributes:(nullable NSDictionary<NSString *, id> *)attributes NS_SWIFT_NAME(init(XZML:attributes:));

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

@interface NSString (XZML)

/// 通过 XZML 字符串构造对象。
/// @param XZMLString XZML 字符串
/// @param attributes 默认属性
- (instancetype)initWithXZMLString:(nullable NSString *)XZMLString attributes:(nullable NSDictionary<NSString *, id> *)attributes NS_SWIFT_NAME(init(XZML:attributes:));

/// 通过 XZML 字符串构造文本。
/// @param XZMLString XZML 字符串
- (instancetype)initWithXZMLString:(nullable NSString *)XZMLString NS_SWIFT_NAME(init(XZML:));

/// 将字符串中的 XZML 保留字符添加反斜线转义字符，以便将字符串作为纯文本插入到 XZML 中。
@property (nonatomic, readonly) NSMutableString *stringByEscapingXZMLCharacters NS_SWIFT_NAME(escapingXZMLCharacters);

@end

@interface NSMutableString (XZML)
@end

@interface NSCharacterSet (XZML)
/// XZML 的标记字符集。
/// @attention 新增 XZML 标记需更新此字符集。
@property (class, readonly) NSCharacterSet *XZMLCharacterSet;
/// 更新 XZML 标记符集。
/// @param aString 包含新增 XZML 标记符的字符串
+ (void)addXZMLCharactersInString:(NSString *)aString;
@end


NS_ASSUME_NONNULL_END

