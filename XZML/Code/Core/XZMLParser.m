//
//  XZMLParser.m
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import "XZMLParser.h"
@import XZExtensions;

// 样式解析：返回值表示为是否跳过当前元素。
static XZMLDSLMode XZMLAttributeFontParser(NSMutableDictionary<NSAttributedStringKey, id> *attributes, XZMLElement element, NSString *value);
static XZMLDSLMode XZMLAttributeColorParser(NSMutableDictionary<NSAttributedStringKey, id> *attributes, XZMLElement element, NSString *value);
static XZMLDSLMode XZMLAttributeDecorationParser(NSMutableDictionary<NSAttributedStringKey, id> *attributes, XZMLElement element, NSString *value);
static XZMLDSLMode XZMLAttributeSecurityParser(NSMutableDictionary<NSAttributedStringKey, id> *attributes, XZMLElement element, NSString *value);
static XZMLDSLMode XZMLAttributeLinkParser(NSMutableDictionary<NSAttributedStringKey, id> *attributes, XZMLElement element, NSString *value);
static XZMLDSLMode XZMLAttributeParagraphParser(NSMutableDictionary<NSAttributedStringKey, id> *attributes, XZMLElement element, NSString *value);

/// 标记元素是否为安全样式文本。
static NSAttributedStringKey const XZMLAttributeSecurityElementAttributeName = @"XZMLAttributeSecurityElementAttributeName";

static NSString *XZMLTextParser(NSMutableDictionary<NSAttributedStringKey, id> *attributes, NSString *text);

@implementation XZMLParser

+ (void)attributedString:(NSMutableAttributedString * const)attributedString parse:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    /// XZML元素文本属性栈
    NSMutableArray<NSMutableDictionary<NSAttributedStringKey, id> *> * const _elementAttributes = [NSMutableArray array];
    [_elementAttributes addObject:attributes.mutableCopy ?: [NSMutableDictionary dictionary]];
    
    XZMLDSL(XZMLString, ^XZMLElement(char const character) {
        // 识别元素
        return [self shouldBeginElement:character];
    }, ^BOOL(XZMLElement const element, char const character) {
        // 识别元素属性
        return [self element:element shouldBeginAttribute:character];
    }, ^(XZMLElement const element) {
        // 开始识别元素
        id const attributes = _elementAttributes.lastObject.mutableCopy;
        [_elementAttributes addObject:attributes];
        [self didBeginElement:element attributes:attributes];
    }, ^XZMLDSLMode (XZMLElement const element, XZMLElement const attribute, NSString *value) {
        // 解析元素属性
        id const attributes = _elementAttributes.lastObject;
        return [self element:element didEndAttribute:attribute value:value attributes:attributes];
    }, ^(XZMLElement element, NSString * _Nonnull text, NSUInteger fragment) {
        // 获得元素文本
        id const attributes = _elementAttributes.lastObject;
        NSAttributedString *elementString = [self element:element didEndText:text fragment:fragment attributes:attributes];
        if (attributedString) {
            [attributedString appendAttributedString:elementString];
        }
    }, ^(XZMLElement const element) {
        [_elementAttributes removeLastObject];
        // 完成元素识别
        [self didEndElement:element];
    });
}

+ (NSMutableAttributedString *)parse:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes {
    NSMutableAttributedString * const attributedString = [NSMutableAttributedString new];
    [self attributedString:attributedString parse:XZMLString attributes:attributes];
    return attributedString;
}

+ (void)string:(NSMutableString *)string parse:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    NSMutableDictionary *_attributes = [NSMutableDictionary dictionary];
    if ([attributes[XZMLSecurityModeAttributeName] boolValue]) {
        _attributes[XZMLSecurityModeAttributeName] = attributes[XZMLSecurityModeAttributeName];
        _attributes[XZMLSecurityMarkAttributeName] = attributes[XZMLSecurityMarkAttributeName];
        _attributes[XZMLSecurityRepeatAttributeName] = attributes[XZMLSecurityRepeatAttributeName];
    }

    XZMLDSL(XZMLString, ^XZMLElement(char character) {
        return [self shouldBeginElement:character];
    }, ^BOOL(XZMLElement element, char character) {
        return [self element:element shouldBeginAttribute:character];
    }, ^(XZMLElement element) {
        // 元素开始
    }, ^XZMLDSLMode(XZMLElement element, XZMLElement attribute, NSString *value) {
        if (attribute == XZMLAttributeSecurity) {
            return [self element:element didEndAttribute:attribute value:value attributes:_attributes];
        }
        return XZMLDSLModeAll;
    }, ^(XZMLElement element, NSString *text, NSUInteger fragment) {
        [string appendString:XZMLTextParser(_attributes, text)];
    }, ^(XZMLElement element) {
        // 元素结束
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

+ (void)didBeginElement:(XZMLElement)element attributes:(NSMutableDictionary<NSAttributedStringKey,id> *)attributes {
    
}

+ (BOOL)element:(XZMLElement)element didEndAttribute:(XZMLAttribute)attribute value:(NSString *)value attributes:(NSMutableDictionary<NSAttributedStringKey,id> *)attributes {
    switch (attribute) {
        case XZMLAttributeColor: {
            return XZMLAttributeColorParser(attributes, element, value);
        }
        case XZMLAttributeFont: {
            return XZMLAttributeFontParser(attributes, element, value);
        }
        case XZMLAttributeDecoration: {
            return XZMLAttributeDecorationParser(attributes, element, value);
        }
        case XZMLAttributeSecurity: {
            return XZMLAttributeSecurityParser(attributes, element, value);
        }
        case XZMLAttributeLink: {
            return XZMLAttributeLinkParser(attributes, element, value);
        }
        case XZMLAttributeParagraph: {
            return XZMLAttributeParagraphParser(attributes, element, value);
        }
        default: {
            NSLog(@"XZML：自定义属性 %c 暂不支持", attribute);
            return YES;
        }
    }
}

+ (nullable NSAttributedString *)element:(XZMLElement)element didEndText:(NSString *)text fragment:(NSUInteger)fragment attributes:(NSMutableDictionary<NSAttributedStringKey,id> *)attributes {
    return [[NSAttributedString alloc] initWithString:XZMLTextParser(attributes, text) attributes:attributes];
}

+ (void)didEndElement:(XZMLElement)element {
    
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
        return NO;
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
    } else {
        if (!XZMLParserSetFontWithSize(attributes, custom, parent, size)) {
            NSLog(@"警告：无法确定 name=%@, size=%.2f 字体，请通过 defaultAttributes 参数指定解析时的默认字体", name, size);
        }
    }
};

/// 设置字体：仅设置了字体名。
static void XZMLParserSetFontWithName(NSMutableDictionary<NSAttributedStringKey, id> * const attributes, UIFont *custom, UIFont *parent, NSString *name) {
    if (parent != nil) {
        XZMLParserSetFontWithNameSize(attributes, custom, parent, name, parent.pointSize);
    } else if (custom != nil) {
        XZMLParserSetFontWithNameSize(attributes, custom, parent, name, custom.pointSize);
    } else {
        NSLog(@"警告：无法确定 %@ 字号，请在参数 defaultAttributes 中指定默认字体", name);
    }
};

#pragma mark - 样式解析

XZMLDSLMode XZMLAttributeColorParser(NSMutableDictionary<NSAttributedStringKey, id> * const attributes, XZMLElement const element, NSString * const value) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        UIColor *foregroundColor = nil;
        UIColor *backgroundColor = nil;
        
        if (values[0].length > 0) {
            foregroundColor = rgba(values[0], attributes[XZMLForegroundColorAttributeName]);
            backgroundColor = rgba(values[1], attributes[XZMLBackgroundColorAttributeName]);
        } else {
            // 没有前景色，继承上层
            backgroundColor = rgba(values[1], attributes[XZMLBackgroundColorAttributeName]);
        }
        
        if (foregroundColor != nil) {
            attributes[NSForegroundColorAttributeName] = foregroundColor;
        }
        if (backgroundColor != nil) {
            attributes[NSBackgroundColorAttributeName] = backgroundColor;
        }
    } else {
        UIColor *foregroundColor = rgba(value, attributes[XZMLForegroundColorAttributeName]);
        if (foregroundColor != nil) {
            attributes[NSForegroundColorAttributeName] = foregroundColor;
        }
    }
    return XZMLDSLModeAll;
}

XZMLDSLMode XZMLAttributeFontParser(NSMutableDictionary<NSAttributedStringKey, id> * const attributes, XZMLElement const element, NSString * const value) {
    UIFont * const custom = attributes[XZMLFontAttributeName];
    UIFont * const parent = attributes[NSFontAttributeName];
    
    if ([value containsString:@"@"]) {
        // 同时指定字体、字号，如果字体名省略则默认使用数字常规体。
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        NSString * const name = values[0];
        CGFloat    const size = values[1].floatValue;
        
        if (name.length > 0) {
            if (size > 0) {
                XZMLParserSetFontWithNameSize(attributes, custom, parent, name, size);
            } else {
                XZMLParserSetFontWithName(attributes, custom, parent, name);
            }
        } else if (size > 0) {
            if (!XZMLParserSetFontWithSize(attributes, custom, parent, size)) {
                NSLog(@"警告：无法确定 %@ 字体，请通过 defaultAttributes 参数指定解析时的默认字体", value);
            }
        } else {
            if (!XZMLParserSetFontWithDefault(attributes, custom, parent)) {
                NSLog(@"警告：无法确定 %@ 字体，请通过 defaultAttributes 参数指定解析时的默认字体", value);
            }
        }
        
        // 字体基准线调整
        if (values.count >= 3) {
            CGFloat const baselineOffset = values[2].floatValue;
            if (baselineOffset != 0) {
                attributes[NSBaselineOffsetAttributeName] = @(baselineOffset);
            }
        }
    } else {
        // 仅指定了一个参数
        NSString * const name = value;
        if (name.length > 0) {
            XZMLParserSetFontWithName(attributes, custom, parent, name);
        } else {
            if (!XZMLParserSetFontWithDefault(attributes, custom, parent)) {
                NSLog(@"警告：无法确定 %@ 字体，请通过 defaultAttributes 参数指定解析时的默认字体", value);
            }
        }
    }
    return XZMLDSLModeAll;
}

XZMLDSLMode XZMLAttributeDecorationParser(NSMutableDictionary<NSAttributedStringKey, id> * const attributes, XZMLElement const element, NSString * const value) {
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
        attributes[NSUnderlineStyleAttributeName] = @(lines);
        if (color != nil) {
            attributes[NSUnderlineColorAttributeName] = color;
        }
    } else {
        attributes[NSStrikethroughStyleAttributeName] = @(lines);
        if (color != nil) {
            attributes[NSStrikethroughColorAttributeName] = color;
        }
        if (@available(iOS 10.3, *)) {
            // 解决 iOS 10.3 删除线不展示的问题
            if (attributes[NSBaselineOffsetAttributeName] == nil) {
                attributes[NSBaselineOffsetAttributeName] = @(0);
            }
        }
    }
    
    return XZMLDSLModeAll;
}

XZMLDSLMode XZMLAttributeSecurityParser(NSMutableDictionary<NSAttributedStringKey, id> * const attributes, XZMLElement const element, NSString * const value) {
    // 只有安全模式下，才需要解析安全字符样式
    if ([attributes[XZMLSecurityModeAttributeName] boolValue]) {
        // 标记这是一个安全样式元素
        attributes[XZMLAttributeSecurityElementAttributeName] = @(YES);
        
        if ([value containsString:@"@"]) {
            NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
            
            NSString * const mark = values[0];
            if (mark.length > 0) {
                attributes[XZMLSecurityMarkAttributeName] = mark;
            }
            
            NSInteger  const repeat = [values[1] xz_integerValue:4 base:10];
            if (repeat > 0) {
                attributes[XZMLSecurityRepeatAttributeName] = @(repeat);
                return XZMLDSLModeNone;
            }
        } else {
            NSString * const mark = value;
            if (mark.length > 0) {
                attributes[XZMLSecurityMarkAttributeName] = mark;
            }
            return XZMLDSLModeText;
        }
        
        if ([attributes[XZMLSecurityRepeatAttributeName] unsignedIntValue] > 0) {
            return XZMLDSLModeNone;
        }
        return XZMLDSLModeText;
    }
    // 非安全模式，不需要解析安全属性
    return XZMLDSLModeAll;
}

XZMLDSLMode XZMLAttributeLinkParser(NSMutableDictionary<NSAttributedStringKey, id> * const attributes, XZMLElement element, NSString *value) {
    NSURL *url = [NSURL URLWithString:value];
    if (url != nil) {
        attributes[NSLinkAttributeName] = url;
    } else {
        attributes[NSLinkAttributeName] = value;
    }
    return XZMLDSLModeAll;
}

XZMLDSLMode XZMLAttributeParagraphParser(NSMutableDictionary<NSAttributedStringKey, id> * const attributes, XZMLElement element, NSString *value) {
    if (value.length == 0) {
        return XZMLDSLModeAll;
    }
    
    NSMutableParagraphStyle * const style = [[NSMutableParagraphStyle alloc] init];
    
    const char *cValue = [value cStringUsingEncoding:NSASCIIStringEncoding];
    if (cValue == NULL) {
        return XZMLDSLModeAll;
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
                NSLog(@"暂不支持的段落样式：%c, %@", mark, value);
                break;
        }
        
        range.location = index + 1;
        range.length = 0;
    }
    
    attributes[NSParagraphStyleAttributeName] = style;
    
    return XZMLDSLModeAll;
}

NSString *XZMLTextParser(NSMutableDictionary<NSAttributedStringKey, id> *attributes, NSString *text) {
    if ([attributes[XZMLAttributeSecurityElementAttributeName] boolValue]) {
        NSString * const mark = attributes[XZMLSecurityMarkAttributeName] ?: @"*";
        NSInteger const repeat = [attributes[XZMLSecurityRepeatAttributeName] integerValue];
        NSInteger const length = mark.length * (repeat > 0 ? repeat : text.length);
        return [mark stringByPaddingToLength:length withString:mark startingAtIndex:0];
    }
    return text;
}


