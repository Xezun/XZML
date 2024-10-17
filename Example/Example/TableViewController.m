//
//  TableViewController.m
//  Example
//
//  Created by 徐臻 on 2024/10/16.
//

#import "TableViewController.h"
#import "ViewController.h"
@import XZML;
@import XZExtensions;

@interface TableViewController ()

@property (nonatomic, copy) NSArray<NSArray<NSDictionary *> *> *XZMLStrings;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.XZMLStrings = @[
        @[
            @{
                @"title": @"超链接",
                @"xzml": (^() {
                    NSString *urlString = @"https://www.baidu.com/s?wd=XZML&ua=app#home".xz_stringByAddingURIEncoding.stringByEscapingXZMLReservedCharacters;
                    return [NSString stringWithFormat:@"<%@~F00#S@20&百度一下> <T@20&333#你就知道>", urlString];
                })()
            }
        ],
        
        @[
            @{
                @"title": @"元素位置",
                @"xzml": @"在 <S&XZML> 中，<F00#XZML元素>可以插入到<B&任意>位置，<0F0#非常自由>。"
            }
        ],

        @[
            @{
                @"title": @"默认颜色",
                @"xzml": @"在通过 XZML 构造富文本时，可以传入<#默认前景色>与<@#默认背景色>，那么在 XZML 中就可以不用指定颜色值。"
            },
            @{
                @"title": @"样式继承",
                @"xzml": @"<3a3#父元素拥有绿色前景色，<@eee#子元素继承了绿色前景色，并拥有自己的灰色背景色>，且子元素不影响父元素的样式。>"
            }
        ],

        @[
            @{
                @"title": @"文本颜色",
                @"xzml": @"<F00#红色前景色> 就是文本颜色"
            },
            @{
                @"title": @"文本背景色",
                @"xzml": @"<@aaf#蓝色背景色><f11@aaa#红色前景色+灰色背景色>"
            }
        ],

        @[
            @{
                @"title": @"测试普通文本",
                @"xzml": @"日利率 0.02% 0.08%"
            }
        ],

        @[
            @{
                @"title": @"默认字体",
                @"xzml": @"日利率 <&0.02% 0.08%>"
            },
            @{
                @"title": @"数字字体",
                @"xzml": @"日利率 <D&0.02% 0.08%>"
            },
            @{
                @"title": @"指定字号",
                @"xzml": @"日利率 <@20&0.02% 0.08%>"
            },
            @{
                @"title": @"数字字体字号",
                @"xzml": @"日利率 <D@20&0.02%> 0.08%"
            },
            @{
                @"title": @"粗体字体字号",
                @"xzml": @"日利率 <B@20&0.02%> 0.08%"
            }
        ],

        @[
            @{
                @"title": @"删除线",
                @"xzml": @"日利率 <&0.02%> <AAA#$0.08%>"
            },
            @{
                @"title": @"指定删除线",
                @"xzml": @"日利率 <&0.02%> <AAA#0$0.08%>"
            },
            @{
                @"title": @"删除线样式",
                @"xzml": @"日利率 <&0.02%> <AAA#0@0$0.08%>"
            },
            @{
                @"title": @"双删除线",
                @"xzml": @"日利率 <&0.02%> <AAA#0@1$0.08%>"
            },
            @{
                @"title": @"粗删除线",
                @"xzml": @"日利率 <&0.02%> <AAA#0@2$0.08%>"
            },
            @{
                @"title": @"删除线颜色",
                @"xzml": @"日利率 <&0.02%> <AAA#0@2@F00$0.08%>"
            }
        ],

        @[
            @{
                @"title": @"默认下划线",
                @"xzml": @"日利率 <&0.02%> <AAA#1$0.08%>"
            },
            @{
                @"title": @"单下划线",
                @"xzml": @"日利率 <&0.02%> <AAA#1@0$0.08%>"
            },
            @{
                @"title": @"双下划线",
                @"xzml": @"日利率 <&0.02%> <AAA#1@1$0.08%>"
            },
            @{
                @"title": @"粗下划线",
                @"xzml": @"日利率 <&0.02%> <AAA#1@2$0.08%>"
            },
            @{
                @"title": @"下划线颜色",
                @"xzml": @"日利率 <&0.02%> <AAA#1@2@F00$0.08%>"
            }
        ],

        @[
            @{
                @"title": @"安全文本有样式",
                @"xzml": @"日利率 <&*0.02%> <AAA#$*0.08%>"
            },
            @{
                @"title": @"安全文本无样式",
                @"xzml": @"日利率 <*&0.02%> <*AAA#$0.08%>"
            },
            @{
                @"title": @"安全文本继承",
                @"xzml": @"日利率 <@4*<&0.02%> <AAA#$0.08%>"
            },
            @{
                @"title": @"单安全字符",
                @"xzml": @"日利率 <&🔒*0.02%> <AAA#$0.08%>"
            },
            @{
                @"title": @"多安全字符",
                @"xzml": @"日利率 <AAA#谢绝查看*000#&0.02%> <AAA#暂不公开*$0.08%>"
            },
            @{
                @"title": @"安全字符重复",
                @"xzml": @"日利率 <&@4*0.02%> <AAA#@2*$0.08%>"
            }
        ]
    ];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.XZMLStrings.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.XZMLStrings[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    cell.textLabel.text = self.XZMLStrings[indexPath.section][indexPath.row][@"title"];

    return cell;
}

/*
   // Override to support conditional editing of the table view.
   - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
   }
 */

/*
   // Override to support editing the table view.
   - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
   }
 */

/*
   // Override to support rearranging the table view.
   - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
   }
 */

/*
   // Override to support conditional rearranging of the table view.
   - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
   }
 */


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"xzml"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        ViewController *nextVC = segue.destinationViewController;
        nextVC.data = self.XZMLStrings[indexPath.section][indexPath.row];
    }
}

@end
