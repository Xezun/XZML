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

/// 标记元素是否为安全样式文本。
static NSAttributedStringKey const XZMLAttributeSecurityElementAttributeName = @"XZMLAttributeSecurityElementAttributeName";

static NSString *XZMLAttributeTextParser(NSDictionary<NSAttributedStringKey, id> * _Nullable attributes, NSString *text);

@implementation XZMLParser

+ (void)attributedString:(NSMutableAttributedString * const)attributedString parse:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    /// XZML元素文本属性栈
    NSMutableArray * const _elementAttributes = [NSMutableArray arrayWithCapacity:32];
    NSMutableArray * const _textAttributes = [NSMutableArray arrayWithCapacity:32];
    
    XZMLParserContext __block _context = { nil, attributes };
    
    XZMLDSL(XZMLString, ^XZMLElement(char const character) {
        // 识别元素
        return [self shouldBeginElement:character];
    }, ^BOOL(XZMLElement const element, char const character) {
        // 识别元素属性
        return [self element:element shouldBeginAttribute:character];
    }, ^(XZMLElement const element) {
        // 开始识别元素
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
                    return;
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



/// 设置字体：没有指定字体和字号，继承上层字号，使用默认字体。
static BOOL XZMLParserSetFontWithDefault(NSMutableDictionary<NSAttributedStringKey, id> * const attributes, UIFont *custom, UIFont *parent) {
    if (custom == nil) {
        return NO; // 与父元素字体字号相同
    }
    if (parent != nil) {
        UIFont * const font = [custom fontWithSize:parent.pointSize];
        attributes[NSFontAttributeName] = font;
    } else {
        attributes[NSFontAttributeName] = custom;
    }
    return YES;
};

/// 设置字体：仅指定了字号，继承上层字体，或使用默认字体。
static BOOL XZMLParserSetFontWithSize(NSMutableDictionary<NSAttributedStringKey, id> * const attributes, UIFont *custom, UIFont *parent, CGFloat size) {
    if (parent != nil) {
        attributes[NSFontAttributeName] = [parent fontWithSize:size];
        return YES;
    }
    if (custom != nil) {
        attributes[NSFontAttributeName] = [custom fontWithSize:size];
        return YES;
    }
    return NO;
};

/// 设置字体：同时指定了字体和字号。
static void XZMLParserSetFontWithNameSize(NSMutableDictionary<NSAttributedStringKey, id> * const attributes, UIFont *custom, UIFont *parent, NSString *key, CGFloat size) {
    NSString * const name = [XZMLParser fontNameForAbbreviation:key];
    UIFont   * const font = [UIFont fontWithName:name size:size];
    if (font != nil) {
        attributes[NSFontAttributeName] = font;
    } else if (!XZMLParserSetFontWithSize(attributes, custom, parent, size)) {
        XZLog(@"警告：无法确定 name=%@, size=%.2f 字体，请通过 defaultAttributes 参数指定解析时的默认字体", name, size);
    }
};

/// 设置字体：仅设置了字体名。
static void XZMLParserSetFontWithName(NSMutableDictionary<NSAttributedStringKey, id> * const attributes, UIFont *custom, UIFont *parent, NSString *name) {
    if (parent != nil) {
        XZMLParserSetFontWithNameSize(attributes, custom, parent, name, parent.pointSize);
    } else if (custom != nil) {
        XZMLParserSetFontWithNameSize(attributes, custom, parent, name, custom.pointSize);
    } else {
        XZLog(@"警告：无法确定 %@ 字号，请在参数 defaultAttributes 中指定默认字体", name);
    }
};

FOUNDATION_STATIC_INLINE UIColor *XZMLForegroundColorFromContext(const XZMLParserContext context, NSString *value) {
    UIColor * const color = rgba(value, nil);
    if (color) {
        return color;
    }
    return context.elementAttributes[NSForegroundColorAttributeName] ? nil : (context.defaultAttributes[XZMLForegroundColorAttributeName] ?: context.defaultAttributes[NSForegroundColorAttributeName]);
}

FOUNDATION_STATIC_INLINE UIColor *XZMLBackgroundColorFromContext(const XZMLParserContext context, NSString *value) {
    UIColor * const color = rgba(value, nil);
    if (color) {
        return color;
    }
    return context.elementAttributes[NSBackgroundColorAttributeName] ? nil : (context.defaultAttributes[XZMLBackgroundColorAttributeName] ?: context.defaultAttributes[NSBackgroundColorAttributeName]);
}

#pragma mark - 样式解析

XZMLReadingOptions XZMLAttributeColorParser(const XZMLParserContext context, XZMLElement const element, NSString * const value) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
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

FOUNDATION_STATIC_INLINE UIFont * _Nullable XZMLFontFromContext(const XZMLParserContext context, NSString * _Nullable nameString, NSString * _Nullable sizeString) {
    NSString *name = nil;
    CGFloat size = 0;
    UIFont *font = nil;
    
    if (nameString.length == 0 && sizeString.length == 0) {
    bad_name_size: // name/size 都不合法
        if (context.elementAttributes[NSFontAttributeName]) {
            return nil; // 使用父元素字体
        }
        return context.defaultAttributes[XZMLFontAttributeName] ?: context.defaultAttributes[NSFontAttributeName];
    }
    
    if (nameString.length == 0) {
        size = sizeString.doubleValue;
        if (size <= 0 || isnan(size)) {
            goto bad_name_size;
        }
    bad_name_only: // 仅 name 不合法
        font = context.elementAttributes[NSFontAttributeName];
        if (font) {
            if (font.pointSize == size) {
                return nil;
            }
            return [font fontWithSize:size];
        }
        font = context.defaultAttributes[XZMLFontAttributeName] ?: context.defaultAttributes[NSFontAttributeName];
        return [font fontWithSize:size];
    }
    
    if (sizeString.length == 0) {
    bad_size: // size 不合法，name 还未判断
        name = [XZMLParser fontNameForAbbreviation:nameString];
        font = context.elementAttributes[NSFontAttributeName];
        if (font) {
            if ([name isEqualToString:font.familyName]) {
                return nil;
            }
            font = [UIFont fontWithName:name size:font.pointSize];
            if (font == nil) {
                goto bad_name_size;
            }
            return font;
        }
        font = context.defaultAttributes[XZMLFontAttributeName] ?: context.defaultAttributes[NSFontAttributeName];
        if (font == nil) {
            return nil; // 不能确定 fontSize
        }
        CGFloat const size = font.pointSize;
        font = [UIFont fontWithName:name size:size];
        if (font) {
            return font;
        }
        return [UIFont systemFontOfSize:size]; // 不能确定 fontName 使用系统字体
    }
    
    size = sizeString.doubleValue;
    if (size <= 0 || isnan(size)) {
        goto bad_size;
    }
    name = [XZMLParser fontNameForAbbreviation:nameString];
    font = [UIFont fontWithName:name size:size];
    if (font == nil) {
        goto bad_name_only; // 名字不合法
    }
    return font;
}

XZMLReadingOptions XZMLAttributeFontParser(const XZMLParserContext context, XZMLElement const element, NSString * const value) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        NSString * const name = values[0];
        CGFloat    const size = values[1].floatValue;
        
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
        // 仅指定了一个参数，当作
        UIFont * font = XZMLFontFromContext(context, value, nil) ?: XZMLFontFromContext(context, nil, value);
        if (font) {
            context.elementAttributes[NSFontAttributeName] = font;
        }
    }
    return XZMLReadingAll;
}

XZMLReadingOptions XZMLAttributeDecorationParser(const XZMLParserContext context, XZMLElement const element, NSString * const value) {
    NSInteger style = 0;                             // 样式
    NSUnderlineStyle lines = NSUnderlineStyleSingle; // 线型
    UIColor *color = nil;                            // 颜色
    
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        NSUInteger const count = values.count;
        
        style = values[0].integerValue;
        if (count >= 2) {
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
        }
        if (count >= 3) {
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
        // 标记这是一个安全样式元素
        context.elementAttributes[XZMLAttributeSecurityElementAttributeName] = @(YES);
        
        if ([value containsString:@"@"]) {
            NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
            
            NSString * const mark = values[0];
            if (mark.length > 0) {
                context.elementAttributes[XZMLSecurityMarkAttributeName] = mark;
            }
            
            NSInteger const repeat = values[1].integerValue;
            if (repeat > 0) {
                context.elementAttributes[XZMLSecurityRepeatAttributeName] = @(repeat);
                return XZMLReadingNone;
            }
        } else {
            NSString * const mark = value;
            if (mark.length > 0) {
                context.elementAttributes[XZMLSecurityMarkAttributeName] = mark;
                // 多字符的安全符，默认重复 1 次
                if ([mark rangeOfComposedCharacterSequenceAtIndex:0].length < mark.length) {
                    context.elementAttributes[XZMLSecurityRepeatAttributeName] = @(1);
                    return XZMLReadingNone;
                }
            }
            return XZMLReadingText;
        }
        
        if ([context.elementAttributes[XZMLSecurityRepeatAttributeName] unsignedIntValue] > 0) {
            return XZMLReadingNone;
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

NSString *XZMLAttributeTextParser(NSDictionary<NSAttributedStringKey, id> *attributes, NSString *text) {
    if ([attributes[XZMLAttributeSecurityElementAttributeName] boolValue]) {
        NSString * const mark = attributes[XZMLSecurityMarkAttributeName] ?: @"*";
        NSInteger const repeat = [attributes[XZMLSecurityRepeatAttributeName] integerValue];
        NSInteger const length = mark.length * (repeat > 0 ? repeat : text.length);
        return [mark stringByPaddingToLength:length withString:mark startingAtIndex:0];
    }
    return text;
}


