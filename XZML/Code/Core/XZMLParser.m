//
//  XZMLParser.m
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import "XZMLParser.h"
@import XZExtensions;

// 样式解析：返回值表示为是否跳过当前元素。
static BOOL XZMLAttributeFontParser(XZMLParser *self, XZMLElement element, NSString *value);
static BOOL XZMLAttributeColorParser(XZMLParser *self, XZMLElement element, NSString *value);
static BOOL XZMLAttributeDecorationParser(XZMLParser *self, XZMLElement element, NSString *value);
static BOOL XZMLAttributeSecurityParser(XZMLParser *self, XZMLElement element, NSString *value);
static BOOL XZMLAttributeLinkParser(XZMLParser *self, XZMLElement element, NSString *value);
static BOOL XZMLAttributeParagraphParser(XZMLParser *self, XZMLElement element, NSString *value);
// 样式属性解析：从安全属性值获取安全字符。
static NSString *XZMLAttributeSecurityTextParser(XZMLElement element, NSString *value);

NSAttributedStringKey const XZMLFontAttributeName            = @"XZMLFontAttributeName";
NSAttributedStringKey const XZMLForegroundColorAttributeName = @"XZMLForegroundColorAttributeName";
NSAttributedStringKey const XZMLBackgroundColorAttributeName = @"XZMLBackgroundColorAttributeName";
NSAttributedStringKey const XZMLSecurityAttributeName        = @"XZMLSecurityAttributeName";

@implementation XZMLParser {
    @package
    /// 富文本
    NSMutableAttributedString *_attributedString;
    /// 安全模式
    BOOL     _security;
    UIFont  *_font;
    UIColor *_foregroundColor;
    UIColor *_backgroundColor;
    
    /// 非XZML元素文本属性
    NSDictionary<NSAttributedStringKey, id> * _Nullable _defaultAttributes;
    /// XZML元素文本属性栈
    NSMutableArray<NSMutableDictionary<NSAttributedStringKey, id> *> *_elementAttributes;
}

- (void)parse:(NSString *)XZMLString attributedString:(NSMutableAttributedString * const)attributedString defaultAttributes:(NSDictionary<NSAttributedStringKey,id> *)defaultAttributes {
    _attributedString = attributedString;
    
    _security         = [defaultAttributes[XZMLSecurityAttributeName] boolValue];
    _font             = [defaultAttributes objectForKey:XZMLFontAttributeName];
    _foregroundColor  = [defaultAttributes objectForKey:XZMLForegroundColorAttributeName];
    _backgroundColor  = [defaultAttributes objectForKey:XZMLBackgroundColorAttributeName];
    
    // XZML元素与普通文本之间属于同层，而不是上下层之间的关系，所以默认样式不能作为是元素的上级样式处理。
    // 即，默认样式不应该被元素继承，而是应该作为元素的补充样式使用。
    _defaultAttributes = defaultAttributes.copy;
    _elementAttributes = [NSMutableArray arrayWithObject:[NSMutableDictionary dictionary]];
    
    XZMLDSL(XZMLString, ^XZMLElement(char const character) {
        // 识别元素
        return [self shouldRecognizeElement:character];
    }, ^BOOL(XZMLElement const element, char const character) {
        // 识别元素属性
        return [self element:element shouldRecognizeAttribute:character];
    }, ^(XZMLElement const element) {
        // 开始识别元素
        [self didBeginElement:element];
    }, ^BOOL(XZMLElement const element, XZMLElement const attribute, NSString *value) {
        // 解析元素属性
        return [self element:element didRecognizeAttribute:attribute value:value];
    }, ^(XZMLElement element, NSString * _Nonnull text, NSUInteger fragment) {
        // 获得元素文本
        [self element:element didRecognizeText:text fragment:fragment];
    }, ^(XZMLElement const element) {
        // 完成元素识别
        [self didEndElement:element];
    });
}

- (NSMutableAttributedString *)parse:(NSString *)XZMLString defaultAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)defaultAttributes {
    NSMutableAttributedString * const attributedString = [NSMutableAttributedString new];
    [self parse:XZMLString attributedString:attributedString defaultAttributes:defaultAttributes];
    return attributedString;
}

- (void)parse:(NSString *)XZMLString string:(NSMutableString *)string defaultAttributes:(nullable NSDictionary<NSAttributedStringKey,id> *)defaultAttributes {
    _security = [defaultAttributes[XZMLSecurityAttributeName] boolValue];
    
    XZMLDSL(XZMLString, ^XZMLElement(char character) {
        return [self shouldRecognizeElement:character];
    }, ^BOOL(XZMLElement element, char character) {
        return [self element:element shouldRecognizeAttribute:character];
    }, ^(XZMLElement element) {
        // 元素开始
    }, ^BOOL(XZMLElement element, XZMLElement attribute, NSString *value) {
        if (_security && attribute == XZMLAttributeSecurity) {
            NSString *secureText = XZMLAttributeSecurityTextParser(element, value);
            [string appendString:secureText];
            return NO;
        }
        return YES;
    }, ^(XZMLElement element, NSString *text, NSUInteger fragment) {
        [string appendString:text];
    }, ^(XZMLElement element) {
        // 元素结束
    });
}

#pragma mark - 解析过程

- (XZMLElement)shouldRecognizeElement:(char)character {
    switch (character) {
        case '<':
            return '>';
        default:
            return XZMLElementNotAnElement;
    }
}

- (BOOL)element:(XZMLElement)element shouldRecognizeAttribute:(char)character {
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

- (void)didBeginElement:(XZMLElement)element {
    // 开始了新元素，新元素的属性压栈
    [_elementAttributes addObject:_elementAttributes.lastObject.mutableCopy];
}

- (BOOL)element:(XZMLElement)element didRecognizeAttribute:(XZMLAttribute)attribute value:(NSString *)value {
    switch (attribute) {
        case XZMLAttributeColor: {
            return XZMLAttributeColorParser(self, element, value);
        }
        case XZMLAttributeFont: {
            return XZMLAttributeFontParser(self, element, value);
        }
        case XZMLAttributeDecoration: {
            return XZMLAttributeDecorationParser(self, element, value);
        }
        case XZMLAttributeSecurity: {
            return XZMLAttributeSecurityParser(self, element, value);
        }
        case XZMLAttributeLink: {
            return XZMLAttributeLinkParser(self, element, value);
        }
        case XZMLAttributeParagraph: {
            return XZMLAttributeParagraphParser(self, element, value);
        }
        default: {
            NSLog(@"XZML：自定义属性 %c 暂不支持", attribute);
            return YES;
        }
    }
}

- (void)element:(XZMLElement)element didRecognizeText:(NSString *)text fragment:(NSUInteger)fragment {
    switch (element) {
        case XZMLElementNotAnElement: {
            // 普通文本
            NSDictionary *attributes = _defaultAttributes;
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
            [_attributedString appendAttributedString:attributedText];
            break;
        }
        default: {
            // 元素文本
            NSMutableDictionary * const attributes = _elementAttributes.lastObject;
            // 补全默认属性，将 _defaultAttributes 合入元素属性
            if (fragment == 0) {
                [_defaultAttributes enumerateKeysAndObjectsUsingBlock:^(NSAttributedStringKey key, id obj, BOOL *stop) {
                    if (attributes[key] == nil) {
                        attributes[key] = obj;
                    }
                }];
            }
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
            [_attributedString appendAttributedString:attributedText];
            break;
        }
    }
}

- (void)didEndElement:(XZMLElement)element {
    // 元素结束，属性退栈
    [_elementAttributes removeLastObject];
}

@end

static NSMutableDictionary *_keyedFontNames = nil;

@implementation XZMLParser (XZMLExtendedParser)

+ (void)setFontName:(NSString *)fontName forAbbreviation:(NSString *)abbreviation {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _keyedFontNames = [NSMutableDictionary dictionary];
    });
    _keyedFontNames[abbreviation] = fontName;
}

+ (NSString *)fontNameForAbbreviation:(NSString *)abbreviation {
    return _keyedFontNames[abbreviation] ?: abbreviation;
}

- (NSDictionary<NSAttributedStringKey,id> *)attributes {
    return _elementAttributes.lastObject;
}

- (void)setValue:(id)value forAttribute:(NSAttributedStringKey)attribute {
    _elementAttributes.lastObject[attribute] = value;
}

- (id)valueForAttribute:(NSString *)attribute {
    return _elementAttributes.lastObject[attribute];
}

@end



/// 设置字体：没有指定字体和字号，继承上层字号，使用默认字体。
static BOOL XZMLParserSetFontWithDefault(XZMLParser *self, UIFont *custom, UIFont *parent) {
    if (custom == nil) {
        return NO;
    }
    if (parent != nil) {
        UIFont * const font = [custom fontWithSize:parent.pointSize];
        [self setValue:font forAttribute:NSFontAttributeName];
    } else {
        [self setValue:custom forAttribute:NSFontAttributeName];
    }
    return YES;
};

/// 设置字体：仅指定了字号，继承上层字体，或使用默认字体。
static BOOL XZMLParserSetFontWithSize(XZMLParser *self, UIFont *custom, UIFont *parent, CGFloat size) {
    if (parent != nil) {
        [self setValue:[parent fontWithSize:size] forAttribute:NSFontAttributeName];
        return YES;
    }
    if (custom != nil) {
        [self setValue:[custom fontWithSize:size] forAttribute:NSFontAttributeName];
        return YES;
    }
    return NO;
};

/// 设置字体：同时指定了字体和字号。
static void XZMLParserSetFontWithNameSize(XZMLParser *self, UIFont *custom, UIFont *parent, NSString *key, CGFloat size) {
    NSString * const name = [self.class fontNameForAbbreviation:key];
    UIFont   * const font = [UIFont fontWithName:name size:size];
    if (font != nil) {
        [self setValue:font forAttribute:NSFontAttributeName];
    } else {
        if (!XZMLParserSetFontWithSize(self, custom, parent, size)) {
            NSLog(@"警告：无法确定 name=%@, size=%.2f 字体，请通过 defaultAttributes 参数指定解析时的默认字体", name, size);
        }
    }
};

/// 设置字体：仅设置了字体名。
static void XZMLParserSetFontWithName(XZMLParser *self, UIFont *custom, UIFont *parent, NSString *name) {
    if (parent != nil) {
        XZMLParserSetFontWithNameSize(self, custom, parent, name, parent.pointSize);
    } else if (custom != nil) {
        XZMLParserSetFontWithNameSize(self, custom, parent, name, custom.pointSize);
    } else {
        NSLog(@"警告：无法确定 %@ 字号，请在参数 defaultAttributes 中指定默认字体", name);
    }
};

#pragma mark - 样式解析

BOOL XZMLAttributeColorParser(XZMLParser * const self, XZMLElement const element, NSString * const value) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        UIColor *foregroundColor = nil;
        UIColor *backgroundColor = nil;
        
        if (values[0].length > 0) {
            foregroundColor = rgba(values[0], self->_foregroundColor);
            backgroundColor = rgba(values[1], self->_backgroundColor);
        } else {
            // 没有前景色，继承上层
            backgroundColor = rgba(values[1], self->_backgroundColor);
        }
        
        if (foregroundColor != nil) {
            [self setValue:foregroundColor forAttribute:NSForegroundColorAttributeName];
        }
        if (backgroundColor != nil) {
            [self setValue:backgroundColor forAttribute:NSBackgroundColorAttributeName];
        }
    } else {
        UIColor *foregroundColor = rgba(value, self->_foregroundColor);
        if (foregroundColor != nil) {
            [self setValue:foregroundColor forAttribute:NSForegroundColorAttributeName];
        }
    }
    return YES;
}

BOOL XZMLAttributeFontParser(XZMLParser * const self, XZMLElement const element, NSString * const value) {
    UIFont * const custom = self->_font;
    UIFont * const parent = [self valueForAttribute:NSFontAttributeName];
    
    if ([value containsString:@"@"]) {
        // 同时指定字体、字号，如果字体名省略则默认使用数字常规体。
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        NSString * const name = values[0];
        CGFloat    const size = values[1].floatValue;
        
        if (name.length > 0) {
            if (size > 0) {
                XZMLParserSetFontWithNameSize(self, custom, parent, name, size);
            } else {
                XZMLParserSetFontWithName(self, custom, parent, name);
            }
        } else if (size > 0) {
            if (!XZMLParserSetFontWithSize(self, custom, parent, size)) {
                NSLog(@"警告：无法确定 %@ 字体，请通过 defaultAttributes 参数指定解析时的默认字体", value);
            }
        } else {
            if (!XZMLParserSetFontWithDefault(self, custom, parent)) {
                NSLog(@"警告：无法确定 %@ 字体，请通过 defaultAttributes 参数指定解析时的默认字体", value);
            }
        }
        
        // 字体基准线调整
        if (values.count >= 3) {
            CGFloat const baselineOffset = values[2].floatValue;
            if (baselineOffset != 0) {
                [self setValue:@(baselineOffset) forAttribute:NSBaselineOffsetAttributeName];
            }
        }
    } else {
        // 仅指定了一个参数
        NSString * const name = value;
        if (name.length > 0) {
            XZMLParserSetFontWithName(self, custom, parent, name);
        } else {
            if (!XZMLParserSetFontWithDefault(self, custom, parent)) {
                NSLog(@"警告：无法确定 %@ 字体，请通过 defaultAttributes 参数指定解析时的默认字体", value);
            }
        }
    }
    return YES;
}

BOOL XZMLAttributeDecorationParser(XZMLParser * const self, XZMLElement const element, NSString * const value) {
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
        [self setValue:@(lines) forAttribute:NSUnderlineStyleAttributeName];
        if (color != nil) {
            [self setValue:color forAttribute:NSUnderlineColorAttributeName];
        }
    } else {
        [self setValue:@(lines) forAttribute:NSStrikethroughStyleAttributeName];
        if (color != nil) {
            [self setValue:color forAttribute:NSStrikethroughColorAttributeName];
        }
        if (@available(iOS 10.3, *)) {
            // 解决 iOS 10.3 删除线不展示的问题
            if ([self valueForAttribute:NSBaselineOffsetAttributeName] == nil) {
                [self setValue:@(0) forAttribute:NSBaselineOffsetAttributeName];
            }
        }
    }
    
    return YES;
}

BOOL XZMLAttributeSecurityParser(XZMLParser * const self, XZMLElement const element, NSString * const value) {
    // 安全模式下，整个元素用安全字符替换，并终止元素解析
    if (self->_security) {
        NSString *secureText = XZMLAttributeSecurityTextParser(element, value);
        [self element:element didRecognizeText:secureText fragment:0];
        return NO;
    }
    // 非安全模式，不需要解析安全属性
    return YES;
}

BOOL XZMLAttributeLinkParser(XZMLParser *self, XZMLElement element, NSString *value) {
    NSURL *url = [NSURL URLWithString:value];
    if (url != nil) {
        [self setValue:url forAttribute:NSLinkAttributeName];
    } else {
        [self setValue:value forAttribute:NSLinkAttributeName];
    }
    return YES;
}

BOOL XZMLAttributeParagraphParser(XZMLParser *self, XZMLElement element, NSString *value) {
    if (value.length == 0) {
        return YES;
    }
    
    NSMutableParagraphStyle * const style = [[NSMutableParagraphStyle alloc] init];
    
    const char *cValue = [value cStringUsingEncoding:NSASCIIStringEncoding];
    if (cValue == NULL) {
        return YES;
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
    
    [self setValue:style forAttribute:NSParagraphStyleAttributeName];
    
    return YES;
}

#pragma mark - 样式的属性解析

static NSString *XZMLAttributeSecurityTextParser(XZMLElement element, NSString *value) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        NSString * const mark   = values[0];
        NSInteger  const count  = [values[1] xz_integerValue:4 base:10];
        NSUInteger const length = mark.length;
        if (length == 0) {
            return [@"" stringByPaddingToLength:count withString:@"*" startingAtIndex:0];
        }
        return [@"" stringByPaddingToLength:count * length withString:mark startingAtIndex:0];
    } else {
        NSString * const mark   = value;
        NSUInteger const length = mark.length;
        if (length == 0) {
            return @"****";
        }
        return [@"" stringByPaddingToLength:4 * length withString:mark startingAtIndex:0];
    }
}


@implementation NSCharacterSet (XZML)

+ (NSCharacterSet *)XZMLCharacterSet {
    static NSCharacterSet *_characterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _characterSet = [NSCharacterSet characterSetWithCharactersInString:@"<@#&$*~^>"];
    });
    return _characterSet;
}

@end
