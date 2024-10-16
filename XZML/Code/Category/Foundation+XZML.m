//
//  Foundation+XZML.m
//  XZKit
//
//  Created by Xezun on 2021/10/19.
//

#import "Foundation+XZML.h"
#import "XZMLParser.h"

@implementation NSAttributedString (XZML)

- (instancetype)initWithXZMLString:(NSString *)XZMLString attributes:(nullable NSDictionary<NSString *,id> *)attributes {
    NSMutableAttributedString * const attributedString = [[NSMutableAttributedString alloc] initWithXZMLString:XZMLString attributes:attributes];
    return [self initWithAttributedString:attributedString];
}

- (instancetype)initWithXZMLString:(NSString *)XZMLString {
    return [self initWithXZMLString:XZMLString attributes:nil];
}

@end

@implementation NSMutableAttributedString (XZML)

- (instancetype)initWithXZMLString:(NSString *)XZMLString attributes:(NSDictionary<NSString *,id> *)attributes {
    self = [self init];
    if (self) {
        [XZMLParser attributedString:self parse:XZMLString attributes:attributes];
    }
    return self;
}

- (void)appendXZMLString:(NSString *)XZMLString attributes:(nullable NSDictionary<NSString *,id> *)defaultAttributes {
    NSMutableAttributedString * const attributedString = [[NSMutableAttributedString alloc] initWithXZMLString:XZMLString attributes:defaultAttributes];
    [self appendAttributedString:attributedString];
}

@end


@implementation NSString (XZML)

- (instancetype)initWithXZMLString:(NSString *)XZMLString attributes:(nullable NSDictionary<NSString *,id> *)attributes {
    NSMutableString *string = [[NSMutableString alloc] initWithXZMLString:XZMLString attributes:attributes];
    return [self initWithString:string];
}

- (instancetype)initWithXZMLString:(NSString *)XZMLString {
    return [self initWithXZMLString:XZMLString attributes:nil];
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

- (instancetype)initWithXZMLString:(NSString *)XZMLString attributes:(nullable NSDictionary<NSString *,id> *)attributes {
    self = [self init];
    if (self) {
        [XZMLParser string:self parse:XZMLString attributes:attributes];
    }
    return self;
}

@end


@implementation NSCharacterSet (XZML)

+ (NSCharacterSet *)XZMLCharacterSet {
    static NSCharacterSet *_characterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _characterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"<@#&$*~^>"];
    });
    return _characterSet;
}

+ (void)addXZMLCharactersInString:(NSString *)aString {
    @synchronized (self) {
        NSMutableCharacterSet *set = (id)NSCharacterSet.XZMLCharacterSet;
        [set addCharactersInString:aString];
    }
}

@end
