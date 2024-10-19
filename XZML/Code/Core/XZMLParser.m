//
//  XZMLParser.m
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import "XZMLParser.h"
#import "XZMLDSL.h"
@import XZExtensions;
@import XZDefines;

// 样式解析：返回值表示为是否跳过当前元素。
static XZMLReadingOptions XZMLAttributeFontParser(const XZMLParserContext context, XZMLElement element, NSString *value);
static XZMLReadingOptions XZMLAttributeColorParser(const XZMLParserContext context, XZMLElement element, NSString *value);
static XZMLReadingOptions XZMLAttributeDecorationParser(const XZMLParserContext context, XZMLElement element, NSString *value);
static XZMLReadingOptions XZMLAttributeSecurityParser(const XZMLParserContext context, XZMLElement element, NSString *value);
static XZMLReadingOptions XZMLAttributeLinkParser(const XZMLParserContext context, XZMLElement element, NSString *value);
static XZMLReadingOptions XZMLAttributeParagraphParser(const XZMLParserContext context, XZMLElement element, NSString *value);

/// 安全文本替代字符。默认替代字符为 `*` 星号。
/// @note 在元素属性中，有此属性有值表明这是一个安全文本。
static NSAttributedStringKey const XZMLSecurityMarkAttributeName  = @"XZMLSecurityMarkAttributeName";
/// 安全文本替代字符重复次数。
/// @note 0 表示重复次数默认与安全文本字符数相同。
static NSAttributedStringKey const XZMLSecurityRepeatAttributeName = @"XZMLSecurityRepeatAttributeName";

static NSString *XZMLAttributeTextParser(NSDictionary<NSAttributedStringKey, id> * _Nullable attributes, NSString *text);

@implementation XZMLParser

+ (void)attributedString:(NSMutableAttributedString * const)attributedString parse:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    /// XZML元素文本属性栈
    NSMutableArray * const _elementAttributes = [NSMutableArray arrayWithCapacity:32];
    NSMutableArray * const _textAttributes = [NSMutableArray arrayWithCapacity:32];
    
    XZMLParserContext __block _context = { nil, attributes };
    
    XZMLDSL(XZMLString, ^XZMLElement(char const character) {
        return [self shouldBeginElement:character];
    }, ^BOOL(XZMLElement const element, char const character) {
        return [self element:element shouldBeginAttribute:character];
    }, ^(XZMLElement const element) { // 开始识别元素
        id const newAttributes = [_elementAttributes.lastObject mutableCopy] ?: [NSMutableDictionary dictionary];
        [_elementAttributes addObject:newAttributes];
        [_textAttributes addObject:[NSMutableDictionary dictionary]];
        _context.elementAttributes = newAttributes;
        [self didBeginElement:element context:_context];
    }, ^XZMLReadingOptions (XZMLElement const element, XZMLElement const attribute, NSString *value) {
        // 解析元素属性
        _context.elementAttributes = _elementAttributes.lastObject;
        return [self element:element foundAttribute:attribute value:value context:_context];
    }, ^(XZMLElement element, NSString * _Nonnull text, NSUInteger fragment) {
        // 获得文本，可能是非元素文本
        NSMutableDictionary * const textAttributes = _textAttributes.lastObject;
        if (textAttributes.count == 0) {
            [textAttributes addEntriesFromDictionary:_elementAttributes.lastObject];
            [attributes enumerateKeysAndObjectsUsingBlock:^(NSAttributedStringKey  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([key hasPrefix:@"XZML"]) {
                    return; // 过滤 XZML 属性
                }
                if (textAttributes[key] == nil) {
                    textAttributes[key] = obj;
                }
            }];
        }
        NSAttributedString * const textAttributedString = [self element:element foundText:text fragment:fragment attributes:textAttributes];
        if (textAttributedString) {
            [attributedString appendAttributedString:textAttributedString];
        }
    }, ^(XZMLElement const element) {
        // 完成元素识别
        _context.elementAttributes = _elementAttributes.lastObject;
        [self didEndElement:element context:_context];
        [_elementAttributes removeLastObject];
        [_textAttributes removeLastObject];
    });
}

+ (NSMutableAttributedString *)parse:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes {
    NSMutableAttributedString * const attributedString = [NSMutableAttributedString new];
    [self attributedString:attributedString parse:XZMLString attributes:attributes];
    return attributedString;
}

+ (void)string:(NSMutableString *)string parse:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    NSMutableArray * const _attributes = [NSMutableArray array];
    
    if ([attributes[XZMLSecurityModeAttributeName] boolValue]) {
        [_attributes addObject:attributes];
    }
    
    XZMLParserContext __block _context = { nil, attributes };

    XZMLDSL(XZMLString, ^XZMLElement(char character) {
        return [self shouldBeginElement:character];
    }, ^BOOL(XZMLElement element, char character) {
        return [self element:element shouldBeginAttribute:character];
    }, ^(XZMLElement element) {
        id const attributes = [_attributes.lastObject mutableCopy];
        if (attributes) {
            [_attributes addObject:attributes];
        }
    }, ^XZMLReadingOptions(XZMLElement element, XZMLElement attribute, NSString *value) {
        if (attribute == XZMLAttributeSecurity) {
            _context.elementAttributes = _attributes.lastObject;
            return [self element:element foundAttribute:attribute value:value context:_context];
        }
        return XZMLReadingAll;
    }, ^(XZMLElement element, NSString *text, NSUInteger fragment) {
        id const attributes = _attributes.lastObject;
        [string appendString:XZMLAttributeTextParser(attributes, text)];
    }, ^(XZMLElement element) {
        [_attributes removeLastObject];
    });
}

#pragma mark - 解析过程

+ (XZMLElement)shouldBeginElement:(char)character {
    switch (character) {
        case '<':
            return '>';
        default:
            return XZMLElementNotAnElement;
    }
}

+ (BOOL)element:(XZMLElement)element shouldBeginAttribute:(char)character {
    switch (character) {
        case XZMLAttributeColor:
        case XZMLAttributeFont:
        case XZMLAttributeDecoration:
        case XZMLAttributeSecurity:
        case XZMLAttributeLink:
        case XZMLAttributeParagraph:
            return YES;
        default:
            return NO;
    }
}

+ (void)didBeginElement:(XZMLElement)element context:(const XZMLParserContext)context {
    
}

+ (XZMLReadingOptions)element:(XZMLElement)element foundAttribute:(XZMLAttribute)attribute value:(NSString *)value context:(const XZMLParserContext)context {
    switch (attribute) {
        case XZMLAttributeColor: {
            return XZMLAttributeColorParser(context, element, value);
        }
        case XZMLAttributeFont: {
            return XZMLAttributeFontParser(context, element, value);
        }
        case XZMLAttributeDecoration: {
            return XZMLAttributeDecorationParser(context, element, value);
        }
        case XZMLAttributeSecurity: {
            return XZMLAttributeSecurityParser(context, element, value);
        }
        case XZMLAttributeLink: {
            return XZMLAttributeLinkParser(context, element, value);
        }
        case XZMLAttributeParagraph: {
            return XZMLAttributeParagraphParser(context, element, value);
        }
        default: {
            XZLog(@"XZML：自定义属性 %c 暂不支持", attribute);
            return XZMLReadingAll;
        }
    }
}

+ (nullable NSAttributedString *)element:(XZMLElement)element foundText:(NSString *)text fragment:(NSUInteger)fragment attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    return [[NSAttributedString alloc] initWithString:XZMLAttributeTextParser(attributes, text) attributes:attributes];
}

+ (void)didEndElement:(XZMLElement)element context:(const XZMLParserContext)context {
    
}

@end

/// 字体名缩写。
static NSMutableDictionary<NSString *, NSString *> *_fontNameAbbreviations = nil;

@implementation XZMLParser (XZMLExtendedParser)

+ (void)setFontName:(NSString *)fontName forAbbreviation:(NSString *)abbreviation {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fontNameAbbreviations = [NSMutableDictionary dictionary];
    });
    _fontNameAbbreviations[abbreviation] = fontName;
}

+ (NSString *)fontNameForAbbreviation:(NSString *)abbreviation {
    return _fontNameAbbreviations[abbreviation] ?: abbreviation;
}

@end




#pragma mark - 样式解析

FOUNDATION_STATIC_INLINE UIColor *XZMLForegroundColorFromContext(const XZMLParserContext context, NSString *value) {
    // 解析指定颜色值
    UIColor *color = rgba(value, nil);
    if (color == nil) {
        // 没有指定颜色值，使用预设颜色值
        color = context.defaultAttributes[XZMLForegroundColorAttributeName];
        if (color == nil) {
            // 没有预设值，继承父元素
            if (context.defaultAttributes[NSForegroundColorAttributeName]) {
                return nil;
            }
            // 使用默认值
            return context.defaultAttributes[NSForegroundColorAttributeName];
        }
    }
    return color;
}

/// 只有在 xzml 中表明了 backgroundColor 的情况下，即有 @ 符号时，才能用此方法解析。
FOUNDATION_STATIC_INLINE UIColor *XZMLBackgroundColorFromContext(const XZMLParserContext context, NSString *value) {
    if (value.length < 3) {
        return context.defaultAttributes[XZMLForegroundColorAttributeName];
    }
    
    UIColor *color = rgba(value, nil);
    
    if (color == nil) {
        return context.defaultAttributes[XZMLForegroundColorAttributeName];
        // 没有指定颜色值，使用预设颜色值
        color = context.defaultAttributes[XZMLBackgroundColorAttributeName];
        if (color == nil) {
            // 没有预设值，继承父元素
            if (context.defaultAttributes[NSBackgroundColorAttributeName]) {
                return nil;
            }
            // 使用默认值
            return context.defaultAttributes[NSBackgroundColorAttributeName];
        }
    }
    return color;
}

XZMLReadingOptions XZMLAttributeColorParser(const XZMLParserContext context, XZMLElement const element, NSString * const value) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        if (values[0].length == 0) {
            if (values[1].length == 0) {
                if (values.count) {
                    <#statements#>
                }
            }
        }
        UIColor * const foregroundColor = XZMLForegroundColorFromContext(context, values[0]);
        if (foregroundColor) {
            context.elementAttributes[NSForegroundColorAttributeName] = foregroundColor;
        }
        
        UIColor * const backgroundColor = XZMLBackgroundColorFromContext(context, values[1]);
        if (backgroundColor) {
            context.elementAttributes[NSBackgroundColorAttributeName] = backgroundColor;
        }
    } else {
        UIColor *foregroundColor = XZMLForegroundColorFromContext(context, value);
        if (foregroundColor != nil) {
            context.elementAttributes[NSForegroundColorAttributeName] = foregroundColor;
        }
    }
    return XZMLReadingAll;
}

/// 字体：xzml > XZMLFontAttributeName > parent > default
/// 字号：xzml > parent > XZMLFontAttributeName > default
FOUNDATION_STATIC_INLINE UIFont * _Nullable XZMLFontFromContext(const XZMLParserContext context, NSString * _Nullable nameString, NSString * _Nullable sizeString) {
    NSString *name = nil;
    CGFloat   size = 0;
    UIFont   *font = nil;
    
    // 没有指定字体和字号
    if (nameString.length == 0 && sizeString.length == 0) {
    NO_NAME_SIZE:
        // 没有指定字体，使用预设字体
        font = context.defaultAttributes[XZMLFontAttributeName];
        if (font) {
            // 没有指定字号时，优先使用父元素的字号
            UIFont *parentFont = context.elementAttributes[XZMLFontAttributeName];
            if (parentFont) {
                return [font fontWithSize:parentFont.pointSize];
            }
            // 使用预设字号
            return font;
        }
        // 没有预设字体，使用父元素字体字号
        if (context.elementAttributes[NSFontAttributeName]) {
            return nil;
        }
        // 没有预设字体，父元素也没有字体，使用默认字体
        font = context.defaultAttributes[NSFontAttributeName];
#if DEBUG
        if (font == nil) {
            XZLog(@"[XZML] 解析字体失败，无法确定字体、字号");
        }
#endif
        return font;
    }
    
    // 没有指定字体
    if (nameString.length == 0) {
        size = sizeString.doubleValue;
        if (size <= 0 || isnan(size)) {
            goto NO_NAME_SIZE;
        }
    NO_NAME_ONLY:
        // 没有指定字体，使用预设字体
        font = context.defaultAttributes[XZMLFontAttributeName];
        if (font) {
            return [font fontWithSize:size];
        }
        // 没有预设字体，继承父元素字体
        font = context.elementAttributes[NSFontAttributeName];
        if (font) {
            return [font fontWithSize:size];
        }
        // 父元素没有字体，使用默认字体
        font = context.defaultAttributes[NSFontAttributeName];
        if (font) {
            return [font fontWithSize:size];
        }
        // 没有默认字体，使用系统字体
        XZLog(@"[XZML] 无法确定字体，使用系统字体");
        return [UIFont systemFontOfSize:size];
    }
    
    // 没有指定字号
    if (sizeString.length == 0) {
    NO_SIZE:
        name = [XZMLParser fontNameForAbbreviation:nameString];
        // 从父元素继承字号
        font = context.elementAttributes[NSFontAttributeName];
        if (font == nil) {
            // 没有父元素字号，使用预设字号
            font = context.defaultAttributes[XZMLFontAttributeName];
            if (font == nil) {
                // 没有预设字号，否则默认字号
                font = context.defaultAttributes[NSFontAttributeName];
                if (font == nil) {
                    XZLog(@"[XZML] 解析字体失败，无法确定字号");
                    return nil;
                }
            }
        } else if ([name isEqualToString:font.familyName]) {
            // 从父元素继承字号，且是同一字体
            return nil;
        }
        // 确定了字号
        size = font.pointSize;
        goto TRY_NAME_SIZE;
    }
    
    size = sizeString.doubleValue;
    if (size <= 0 || isnan(size)) {
        goto NO_SIZE;
    }
TRY_NAME_SIZE:
    name = [XZMLParser fontNameForAbbreviation:nameString];
    font = [UIFont fontWithName:name size:size];
    if (font == nil) {
        goto NO_NAME_ONLY; // 名字不合法
    }
    return font;
}

XZMLReadingOptions XZMLAttributeFontParser(const XZMLParserContext context, XZMLElement const element, NSString * const value) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        UIFont * font = XZMLFontFromContext(context, values[0], values[1]);
        if (font) {
            context.elementAttributes[NSFontAttributeName] = font;
        }
        
        // 字体基准线调整
        if (values.count > 2) {
            CGFloat const baselineOffset = values[2].floatValue;
            if (baselineOffset != 0) {
                context.elementAttributes[NSBaselineOffsetAttributeName] = @(baselineOffset);
            }
        }
    } else {
        // 仅指定了一个参数，优先作为字体名使用
        UIFont * font = XZMLFontFromContext(context, value, nil) ?: XZMLFontFromContext(context, nil, value);
        if (font) {
            context.elementAttributes[NSFontAttributeName] = font;
        }
    }
    return XZMLReadingAll;
}

/// 暂不支持通过 defaultAttributes 提供默认值。
XZMLReadingOptions XZMLAttributeDecorationParser(const XZMLParserContext context, XZMLElement const element, NSString * const value) {
    NSInteger style = 0;                             // 样式 0 删除线 1 下划线
    NSUnderlineStyle lines = NSUnderlineStyleSingle; // 线型 0 单线条 1 双线条 2 粗线条
    UIColor *color = nil;                            // 颜色 _ 默认色 x 指定色
    
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        style = values[0].integerValue;
        
        switch (values[1].integerValue) {
            case 1:
                lines = NSUnderlineStyleDouble;
                break;
            case 2:
                lines = NSUnderlineStyleThick;
                break;
            default:
                lines = NSUnderlineStyleSingle;
                break;
        }
        
        if (values.count > 2) {
            color = rgba(values[2], nil);
        }
    } else {
        style = value.integerValue;
    }
    
    if (style == 1) {
        context.elementAttributes[NSUnderlineStyleAttributeName] = @(lines);
        if (color != nil) {
            context.elementAttributes[NSUnderlineColorAttributeName] = color;
        }
    } else {
        context.elementAttributes[NSStrikethroughStyleAttributeName] = @(lines);
        if (color != nil) {
            context.elementAttributes[NSStrikethroughColorAttributeName] = color;
        }
        if (@available(iOS 10.3, *)) {
            // 解决 iOS 10.3 删除线不展示的问题
            if (context.elementAttributes[NSBaselineOffsetAttributeName] == nil) {
                context.elementAttributes[NSBaselineOffsetAttributeName] = @(0);
            }
        }
    }
    
    return XZMLReadingAll;
}

XZMLReadingOptions XZMLAttributeSecurityParser(const XZMLParserContext context, XZMLElement const element, NSString * const value) {
    // 只有安全模式下，才需要解析安全字符样式
    if ([context.defaultAttributes[XZMLSecurityModeAttributeName] boolValue]) {
        if ([value containsString:@"@"]) {
            NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
            
            NSString * const mark = values[0];
            context.elementAttributes[XZMLSecurityMarkAttributeName] = mark.length > 0 ? mark : @"*";
            
            NSInteger const repeat = values[1].integerValue;
            if (repeat > 0) {
                context.elementAttributes[XZMLSecurityRepeatAttributeName] = @(repeat);
                return XZMLReadingNone;
            }
        } else if (value.length > 0) {
            context.elementAttributes[XZMLSecurityMarkAttributeName] = value;
            // 多字符的安全符，以字符计算，而不是字节数，默认重复 1 次
            if ([value rangeOfComposedCharacterSequenceAtIndex:0].length < value.length) {
                context.elementAttributes[XZMLSecurityRepeatAttributeName] = @(1);
                return XZMLReadingNone;
            }
        } else {
            context.elementAttributes[XZMLSecurityMarkAttributeName] = @"*";
        }
        
        return XZMLReadingText;
    }
    // 非安全模式，不需要解析安全属性
    return XZMLReadingAll;
}

XZMLReadingOptions XZMLAttributeLinkParser(const XZMLParserContext context, XZMLElement element, NSString *value) {
    NSURL *url = [NSURL URLWithString:value];
    if (url != nil) {
        context.elementAttributes[NSLinkAttributeName] = url;
    } else {
        context.elementAttributes[NSLinkAttributeName] = value;
    }
    return XZMLReadingAll;
}

XZMLReadingOptions XZMLAttributeParagraphParser(const XZMLParserContext context, XZMLElement element, NSString *value) {
    if (value.length == 0) {
        return XZMLReadingAll;
    }
    
    NSMutableParagraphStyle * const style = [[NSMutableParagraphStyle alloc] init];
    
    const char *cValue = [value cStringUsingEncoding:NSASCIIStringEncoding];
    if (cValue == NULL) {
        return XZMLReadingAll;
    }
    NSUInteger const length = [value lengthOfBytesUsingEncoding:NSASCIIStringEncoding];
    
    NSRange range = NSMakeRange(0, 0);
    while (range.location < length) {
        NSInteger index = range.location;
        char mark = cValue[index];
        while (index < length) {
            if (mark == '@') {
                break;
            }
            if (mark >= 'A' && mark <= 'Z') {
                break;
            }
            if (mark >= 'a' && mark <= 'z') {
                break;
            }
            index += 1;
            mark = cValue[index];
        }
        range.length = index - range.location;
        
        NSString *value = nil;
        if (range.length > 0) {
            void * const bytes = (void *)(cValue + range.location);
            value = [[NSString alloc] initWithBytesNoCopy:bytes length:range.length encoding:NSASCIIStringEncoding freeWhenDone:NO];
        }
        
        switch (mark) {
            case 'H':
            case 'h': {
                style.minimumLineHeight = value.floatValue;
                break;
            }
            case 'M':
            case 'm': {
                style.maximumLineHeight = value.floatValue;
                break;
            }
            case 'X':
            case 'x': {
                style.lineHeightMultiple = value.floatValue;
                break;
            }
            case 'A':
            case 'a': {
                style.alignment = value.integerValue;
                break;
            }
            case 'K':
            case 'k': {
                style.lineBreakMode = value.integerValue;
                break;
            }
            case 'S':
            case 's': {
                style.lineSpacing = value.floatValue;
                break;
            }
            case 'W':
            case 'w': {
                style.baseWritingDirection = value.integerValue;
                break;
            }
            case 'F':
            case 'f': {
                style.firstLineHeadIndent = value.floatValue;
                break;
            }
            case 'I':
            case 'i': {
                style.headIndent = value.floatValue;
                break;
            }
            case 'T':
            case 't': {
                style.tailIndent = value.floatValue;
                break;
            }
            case 'P':
            case 'p': {
                style.paragraphSpacing = value.floatValue;
                break;
            }
            case 'B':
            case 'b': {
                style.paragraphSpacingBefore = value.floatValue;
                break;
            }
            case '@':
            case '\0': { // 没匹配到标记，或到了字符串末尾
                if (value) {
                    style.minimumLineHeight = value.floatValue;
                }
                break;
            }
            default:
                XZLog(@"暂不支持的段落样式：%c, %@", mark, value);
                break;
        }
        
        range.location = index + 1;
        range.length = 0;
    }
    
    context.elementAttributes[NSParagraphStyleAttributeName] = style;
    
    return XZMLReadingAll;
}

/// attributes 可能包含 XZMLSecurityMarkAttributeName/XZMLSecurityRepeatAttributeName 键
NSString *XZMLAttributeTextParser(NSDictionary<NSAttributedStringKey, id> *attributes, NSString *text) {
    NSString * const mark = attributes[XZMLSecurityMarkAttributeName];
    if (mark) {
        NSInteger const repeat = [attributes[XZMLSecurityRepeatAttributeName] integerValue];
        NSInteger const length = mark.length * (repeat > 0 ? repeat : text.length);
        return [mark stringByPaddingToLength:length withString:mark startingAtIndex:0];
    }
    return text;
}


