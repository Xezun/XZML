//
//  Foundation+XZML.m
//  XZKit
//
//  Created by Xezun on 2021/10/19.
//

#import "Foundation+XZML.h"

@implementation NSAttributedString (XZML)

+ (instancetype)attributedStringWithXZMLString:(nullable NSString *)XZMLString defaultAttributes:(nullable NSDictionary<NSString *, id> *)defaultAttributes {
    return [[self alloc] initWithXZMLString:XZMLString defaultAttributes:defaultAttributes];
}

+ (instancetype)attributedStringWithXZMLString:(NSString *)XZMLString {
    return [self attributedStringWithXZMLString:XZMLString defaultAttributes:nil];
}

- (instancetype)initWithXZMLString:(NSString *)XZMLString defaultAttributes:(NSDictionary<NSString *,id> *)defaultAttributes {
    if (XZMLString == nil) {
        return [self init];
    }
    if ([self isKindOfClass:NSMutableAttributedString.class]) {
        self = [self init];
        if (self) {
            [[XZMLParser new] parse:XZMLString attributedString:(id)self defaultAttributes:defaultAttributes];
        }
        return self;
    }
    id const attributedString = [[NSMutableAttributedString alloc] initWithXZMLString:XZMLString defaultAttributes:defaultAttributes];
    return [self initWithAttributedString:attributedString];
}

- (instancetype)initWithXZMLString:(NSString *)XZMLString {
    return [self initWithXZMLString:XZMLString defaultAttributes:nil];
}

@end

@implementation NSMutableAttributedString (XZML)

- (void)appendAttributedStringWithXZMLString:(NSString *)XZMLString defaultAttributes:(nullable NSDictionary<NSString *,id> *)defaultAttributes {
    NSMutableAttributedString * const attributedString = [[NSMutableAttributedString alloc] initWithXZMLString:XZMLString defaultAttributes:defaultAttributes];
    [self appendAttributedString:attributedString];
}

@end


@implementation NSString (XZML)

+ (instancetype)stringWithXZMLString:(NSString *)XZMLString defaultAttributes:(NSDictionary<NSAttributedStringKey,id> *)defaultAttributes {
    return [[self alloc] initWithXZMLString:XZMLString defaultAttributes:defaultAttributes];
}

+ (instancetype)stringWithXZMLString:(NSString *)XZMLString {
    return [self stringWithXZMLString:XZMLString defaultAttributes:nil];
}

- (instancetype)initWithXZMLString:(NSString *)XZMLString defaultAttributes:(NSDictionary<NSAttributedStringKey,id> *)defaultAttributes {
    if (XZMLString == nil) {
        return [self init];
    }
    if ([self isKindOfClass:NSMutableString.class]) {
        self = [self init];
        if (self) {
            [XZMLParser.new parse:XZMLString string:(id)self defaultAttributes:defaultAttributes];
        }
        return self;
    }
    NSMutableString *string = [NSMutableString stringWithXZMLString:XZMLString defaultAttributes:defaultAttributes];
    return [self initWithString:string];
}

- (instancetype)initWithXZMLString:(NSString *)XZMLString {
    return [self initWithXZMLString:XZMLString defaultAttributes:nil];
}

- (NSMutableString *)stringByEscapingXZMLCharacters {
    NSUInteger        const length  = self.length;
    NSCharacterSet  * const XZMLSet = [NSCharacterSet XZMLCharacterSet];
    NSMutableString * const stringM = [NSMutableString stringWithCapacity:length + 20];
    
    for (NSInteger i = 0; i < length; ) {
        NSRange    const range     = [self rangeOfComposedCharacterSequenceAtIndex:i];
        i += range.length;
        
        NSString * const substring = [self substringWithRange:range];
        if (range.length == 1) {
            unichar const character = [self characterAtIndex:range.location];
            if ([XZMLSet characterIsMember:character]) {
                [stringM appendString:@"\\"];
            }
        }
        [stringM appendString:substring];
    }
    
    return stringM;
}

@end

@implementation NSMutableString (XZML)

@end


