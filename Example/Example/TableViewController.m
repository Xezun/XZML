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

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *XZMLStrings;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlString = @"https://www.baidu.com/s?wd=XZML&ua=app#home".xz_stringByAddingURIEncoding.stringByEscapingXZMLCharacters;
    NSString *xmmlString = [NSString stringWithFormat:@"<%@~F00#S@20&百度一下> <T@20&333#你就知道>", urlString];
    
    self.XZMLStrings = @[
        @[
            xmmlString
        ],
        
        @[
            @"在 <S&XZML> 中，<F00#元素的位置>是任意的。"
        ],
        
        @[
            @"<#默认前景色> <@#默认背景色>",
            @"<0F0#绿色前景色<@AAA#继承绿色前景色>>"
        ],
        
        @[
            @"<F00#红色前景色> <@F00#红色背景色>",
            @"<FFF@000#白色前景+黑色背景色>"
        ],
        
        @[
            @"日利率 0.02% 0.08%",
            @"日利率 <&0.02% 0.08%>"
        ],
        
        @[
            @"日利率 <D&0.02% 0.08%>",
            @"日利率 <@20&0.02% 0.08%>",
            @"日利率 <D@20&0.02%> 0.08%",
            @"日利率 <B@20&0.02%> 0.08%"
        ],
        
        @[
            @"日利率 <&0.02%> <AAA#$0.08%>",
            @"日利率 <&0.02%> <AAA#0$0.08%>",
            @"日利率 <&0.02%> <AAA#0@0$0.08%>",
            @"日利率 <&0.02%> <AAA#0@1$0.08%>",
            @"日利率 <&0.02%> <AAA#0@2$0.08%>",
            @"日利率 <&0.02%> <AAA#0@2@F00$0.08%>"
        ],
        
        @[
            @"日利率 <&0.02%> <AAA#1$0.08%>",
            @"日利率 <&0.02%> <AAA#1@0$0.08%>",
            @"日利率 <&0.02%> <AAA#1@1$0.08%>",
            @"日利率 <&0.02%> <AAA#1@2$0.08%>",
            @"日利率 <&0.02%> <AAA#1@2@F00$0.08%>"
        ],
        
        @[
            @"日利率 <&*0.02%> <AAA#$*0.08%>",
            @"日利率 <*&0.02%> <*AAA#$0.08%>",
            @"日利率 <@8*<&0.02%> <AAA#$0.08%>",
            @"日利率 <&谢绝查看*0.02%> <AAA#$0.08%>",
            @"日利率 <AAA#谢绝查看@1*000#&0.02%> <AAA#暂不公开@1*$0.08%>",
            @"日利率 <&@0*0.02%> <AAA#@0*$0.08%>"
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
    
    cell.textLabel.text = self.XZMLStrings[indexPath.section][indexPath.row];
    
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
        nextVC.XZMLString = self.XZMLStrings[indexPath.section][indexPath.row];
    }
}

@end
