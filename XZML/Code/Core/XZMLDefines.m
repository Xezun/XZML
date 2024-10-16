//
//  XZMLDefines.m
//  XZML
//
//  Created by 徐臻 on 2024/10/15.
//

#import "XZMLDefines.h"

NSAttributedStringKey const XZMLFontAttributeName            = @"XZMLFontAttributeName";
NSAttributedStringKey const XZMLForegroundColorAttributeName = @"XZMLForegroundColorAttributeName";
NSAttributedStringKey const XZMLBackgroundColorAttributeName = @"XZMLBackgroundColorAttributeName";
NSAttributedStringKey const XZMLPrivacyAttributeName         = @"XZMLPrivacyAttributeName";

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
