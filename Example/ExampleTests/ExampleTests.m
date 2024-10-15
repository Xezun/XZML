//
//  ExampleTests.m
//  ExampleTests
//
//  Created by Xezun on 2023/7/27.
//

#import <XCTest/XCTest.h>
@import XZML;
@import XZExtensions;

@interface ExampleTests : XCTestCase

@end

@implementation ExampleTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testXZMLToString {
    NSString *string = [NSString stringWithXZMLString:@"日利率 <*0.02%>" defaultAttributes:@{
        XZMLPrivacyAttributeName: @(YES)
    }];
    XCTAssert([string isEqualToString:@"日利率 ****"]);
}

- (void)testApplePerformance {
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:20000];
    
    // 0.132
    [self measureBlock:^{
        for (NSInteger i = 0; i < 20000; i++) {
            NSString *string = @"日利率 0.02% 0.08%";
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
            [attributedString addAttributes:@{
                NSForegroundColorAttributeName: UIColor.blackColor,
                NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:12.0]
            } range:NSMakeRange(0, 3)];
            [attributedString addAttributes:@{
                NSForegroundColorAttributeName: UIColor.blackColor,
                NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:12.0]
            } range:NSMakeRange(4, 5)];
            
            [attributedString addAttributes:@{
                NSForegroundColorAttributeName: UIColor.grayColor,
                NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:12.0]
            } range:NSMakeRange(10, 5)];
            [arrayM addObject:attributedString];
        }
    }];
}

- (void)testXZMLPerformance {
    NSString *xmml1 = @"日利率 <&*0.02%> <#$0.08%>";
    NSString *xmml2 = @"最低日利率 <&*0.02%> （年化利率 <&7.2%>)";
    
    id const attributes = @{
        NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:12],
        NSForegroundColorAttributeName: rgb(0x000),
        XZMLFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:12.0],
        XZMLForegroundColorAttributeName: rgb(0x999999)
    };
    
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:20000];
    
    // MacBook Pro: 0.497 0.496 0.531 0.519 0.539
    // iPhone 12 Pro: 0.193、0.194、0.193
    [self measureBlock:^{
        for (NSInteger i = 0; i < 10000; i++) {
            NSAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithXZMLString:xmml1 defaultAttributes:attributes];
            [arrayM addObject:attributedString1];
            
            NSAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithXZMLString:xmml2 defaultAttributes:attributes];
            [arrayM addObject:attributedString2];
        }
    }];
}

- (void)testXZMLParserPerformance {
    NSString *xmml1 = @"日利率 <&*0.02%> <#$0.08%>";
    NSString *xmml2 = @"最低日利率 <&*0.02%> （年化利率 <&7.2%>)";
    
    XZMLParser *pareser = [XZMLParser new];
    id const attributes = @{
        NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:12],
        NSForegroundColorAttributeName: rgb(0x000),
        XZMLFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:12.0],
        XZMLForegroundColorAttributeName: rgb(0x999999)
    };
    
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:20000];
    
    // iPhone 12 Pro: 0.192
    [self measureBlock:^{
        for (NSInteger i = 0; i < 10000; i++) {
            NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] init];
            [pareser parse:xmml1 attributedString:attributedString1 attributes:attributes];
            [arrayM addObject:attributedString1];
            
            NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] init];
            [pareser parse:xmml2 attributedString:attributedString2 attributes:attributes];
            [arrayM addObject:attributedString2];
        }
    }];
}

- (void)testLongXZMLPerformance {
    NSString *xmml1 = @"日利率 <&*0.02%> <#$0.08%> 日利率 <&*0.03%> <#$0.09%> 日利率 <&*0.04%> <#$0.10%> 日利率 <&*0.05%> <#$0.11%> 日利率 <&*0.02%> <#$0.09%> 日利率 <&*0.03%> <#$0.10%> 日利率 <&*0.04%> <#$0.11%> 日利率 <&*0.05%> <#$0.12%> 日利率 <&*0.02%> <#$0.10%> 日利率 <&*0.03%> <#$0.11%> 日利率 <&*0.04%> <#$0.12%> 日利率 <&*0.05%> <#$0.13%> 日利率 <&*0.02%> <#$0.11%> 日利率 <&*0.03%> <#$0.12%> 日利率 <&*0.04%> <#$0.13%> 日利率 <&*0.05%> <#$0.14%> 日利率 <&*0.02%> <#$0.12%> 日利率 <&*0.03%> <#$0.13%> 日利率 <&*0.04%> <#$0.14%> 日利率 <&*0.05%> <#$0.15%> 日利率 <&*0.02%> <#$0.13%> 日利率 <&*0.03%> <#$0.14%> 日利率 <&*0.04%> <#$0.15%> 日利率 <&*0.05%> <#$0.16%> 日利率 <&*0.02%> <#$0.14%> 日利率 <&*0.03%> <#$0.15%> 日利率 <&*0.04%> <#$0.16%> 日利率 <&*0.05%> <#$0.17%> 日利率 <&*0.02%> <#$0.15%> 日利率 <&*0.03%> <#$0.16%> 日利率 <&*0.04%> <#$0.17%> 日利率 <&*0.05%> <#$0.18%> 日利率 <&*0.02%> <#$0.16%> 日利率 <&*0.03%> <#$0.17%> 日利率 <&*0.04%> <#$0.18%> 日利率 <&*0.05%> <#$0.19%> 日利率 <&*0.02%> <#$0.17%> 日利率 <&*0.03%> <#$0.18%> 日利率 <&*0.04%> <#$0.19%> 日利率 <&*0.05%> <#$0.20%> 日利率 <&*0.02%> <#$0.18%> 日利率 <&*0.03%> <#$0.19%> 日利率 <&*0.04%> <#$0.20%> 日利率 <&*0.05%> <#$0.21%> 日利率 <&*0.02%> <#$0.19%> 日利率 <&*0.03%> <#$0.20%> 日利率 <&*0.04%> <#$0.21%> 日利率 <&*0.05%> <#$0.22%> 日利率 <&*0.02%> <#$0.20%> 日利率 <&*0.03%> <#$0.21%> 日利率 <&*0.04%> <#$0.22%> 日利率 <&*0.05%> <#$0.23%> 日利率 <&*0.02%> <#$0.21%> 日利率 <&*0.03%> <#$0.22%> 日利率 <&*0.04%> <#$0.23%> 日利率 <&*0.05%> <#$0.24%> 日利率 <&*0.02%> <#$0.22%> 日利率 <&*0.03%> <#$0.23%> 日利率 <&*0.04%> <#$0.24%> 日利率 <&*0.05%> <#$0.25%> 日利率 <&*0.02%> <#$0.23%> 日利率 <&*0.03%> <#$0.24%> 日利率 <&*0.04%> <#$0.25%> 日利率 <&*0.05%> <#$0.26%> 日利率 <&*0.02%> <#$0.24%> 日利率 <&*0.03%> <#$0.25%> 日利率 <&*0.04%> <#$0.26%> 日利率 <&*0.05%> <#$0.27%> 日利率 <&*0.02%> <#$0.25%> 日利率 <&*0.03%> <#$0.26%> 日利率 <&*0.04%> <#$0.27%> 日利率 <&*0.05%> <#$0.28%> 日利率 <&*0.02%> <#$0.26%> 日利率 <&*0.03%> <#$0.27%> 日利率 <&*0.04%> <#$0.28%> 日利率 <&*0.05%> <#$0.29%> 日利率 <&*0.02%> <#$0.27%> 日利率 <&*0.03%> <#$0.28%> 日利率 <&*0.04%> <#$0.29%> 日利率 <&*0.05%> <#$0.30%> 日利率 <&*0.02%> <#$0.28%> 日利率 <&*0.03%> <#$0.29%> 日利率 <&*0.04%> <#$0.30%> 日利率 <&*0.05%> <#$0.31%> 日利率 <&*0.02%> <#$0.29%> 日利率 <&*0.03%> <#$0.30%> 日利率 <&*0.04%> <#$0.31%> 日利率 <&*0.05%> <#$0.32%> 日利率 <&*0.02%> <#$0.30%> 日利率 <&*0.03%> <#$0.31%> 日利率 <&*0.04%> <#$0.32%> 日利率 <&*0.05%> <#$0.33%> 日利率 <&*0.02%> <#$0.31%> 日利率 <&*0.03%> <#$0.32%> 日利率 <&*0.04%> <#$0.33%> 日利率 <&*0.05%> <#$0.34%> 日利率 <&*0.02%> <#$0.32%> 日利率 <&*0.03%> <#$0.33%> 日利率 <&*0.04%> <#$0.34%> 日利率 <&*0.05%> <#$0.35%>";
    
    id const attributes = @{
        NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:12],
        NSForegroundColorAttributeName: rgb(0x000),
        XZMLFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:12.0],
        XZMLForegroundColorAttributeName: rgb(0x999999)
    };
    
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:100];
    
    // MacBook Pro: 0.205
    // iPhone 12 Pro: 0.087
    [self measureBlock:^{
        for (NSInteger i = 0; i < 100; i++) {
            NSAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithXZMLString:xmml1 defaultAttributes:attributes];
            [arrayM addObject:attributedString1];
        }
    }];
}

@end
