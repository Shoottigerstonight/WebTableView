//
//  WebTableViewController.m
//  WebTableView
//
//  Created by 侯云祥 on 2017/10/31.
//  Copyright © 2017年 今晚打老虎. All rights reserved.
//

#import "WebTableViewController.h"
#import <WebKit/WKWebView.h>
#import <WebKit/WKNavigationDelegate.h>
#import <WebKit/WKUIDelegate.h>



#define swidth self.view.bounds.size.width
#define sheight self.view.bounds.size.height

@interface WebTableViewController ()<WKUIDelegate,WKNavigationDelegate,UITableViewDelegate,UITableViewDataSource>
{
    BOOL WebViewLoadFinashi;
    BOOL TableViewLoadFinashi;
}
/** 显示新闻以及评论的tabview   */
@property (nonatomic ,strong) UITableView *newsTabelview;
/** webView的高度   */
@property (nonatomic , assign) NSInteger webHeight;
/** 显示新闻的网页   */
@property (nonatomic ,strong) WKWebView *newsWebview;
/** 网页进度条   */
@property (nonatomic ,strong) UIProgressView *webProgress;
/** 网页的父控件   */
@property (nonatomic ,strong) UIView *webContendView;
/** 数据数组   */
@property (nonatomic ,strong) NSMutableArray *dataArray;
@end

@implementation WebTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makedata];
    [self setUpWenProgress];
    [self setUpWebView];
    [self setUpTableView];
    [self setUpBackButton];
}
- (void)dealloc
{
    [self newsWebviewRelease];
}
#pragma mark     ------  -----------
- (void)makedata
{
    self.dataArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; i ++) {
        NSString *string = [NSString stringWithFormat:@"这是评论+++++%d",i];
        [self.dataArray addObject:string];
    }
    if (self.dataArray.count == 20) {
        TableViewLoadFinashi = YES;
        [self reloadView];
    }
}
- (void)setUpWenProgress
{
    //    网页进度
    self.webProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 50, swidth, 1)];
    self.webProgress.tintColor = [UIColor colorWithRed:255.0/255.0  green:215.0/255.0 blue:0 alpha:1.0];
    self.webProgress.trackTintColor = [UIColor whiteColor];
//    由于进度条是默认高度，通过以下方法改变高度
    self.webProgress.transform = CGAffineTransformMakeScale(1.0f, 2.0f);
    [self.view addSubview:self.webProgress];
}
- (void)setUpBackButton
{
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setTitle:@"返回" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    back.frame = CGRectMake(0, 20, 60, 30);
    [self.view addSubview:back];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setUpWebView
{
    self.newsWebview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, swidth, sheight)];
    self.newsWebview.scrollView.contentInset = UIEdgeInsetsMake(0, -1, 0, 2);
    self.newsWebview.navigationDelegate = self;
    self.newsWebview.UIDelegate = self;
    self.newsWebview.scrollView.scrollEnabled = NO;
    self.newsWebview.scrollView.showsVerticalScrollIndicator =NO;
    self.newsWebview.scrollView.showsHorizontalScrollIndicator=NO;
    self.newsWebview.backgroundColor=[UIColor clearColor];
    [self.newsWebview sizeToFit];
    self.newsWebview.opaque=NO;
    //    添加进度监控
    [self.newsWebview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];

    self.newsWebview.scrollView.bounces = NO;
    [self.newsWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
}
- (void)setUpTableView
{
    self.newsTabelview = [[UITableView alloc] init];
    self.newsTabelview.frame = CGRectMake(0, 0, swidth, sheight);
    self.newsTabelview.allowsSelection = NO;
    self.newsTabelview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.newsTabelview.dataSource = self;
    self.newsTabelview.delegate = self;
    [self.view addSubview:self.newsTabelview];
    [self.view insertSubview:self.newsTabelview belowSubview:self.webProgress];
}
- (void)reloadView
{
    if (WebViewLoadFinashi && TableViewLoadFinashi) {
        [self.newsTabelview reloadData];
    }
}
/**
 退出的时候网页的代理置空
 */
- (void)newsWebviewRelease
{
    self.newsWebview.scrollView.delegate = nil;
    self.newsWebview.navigationDelegate = nil;
    self.newsWebview.UIDelegate = nil;
    if (self.newsWebview.isLoading) {
        [self.newsWebview stopLoading];
    }
    [self.newsWebview removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.newsWebview removeFromSuperview];
    self.newsWebview = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
#pragma mark     ------  kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.webProgress.progress = self.newsWebview.estimatedProgress;
        if (self.webProgress.progress == 1) {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.webProgress.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.webProgress.hidden = YES;
                
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *cells = self.newsTabelview.visibleCells;
    for (UITableViewCell *cell in cells) {
        if ([cell.reuseIdentifier isEqualToString:@"webView"]) {
            [self.newsWebview setNeedsLayout];
        }
    }
}

#pragma mark     ------  webview代理方法
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [webView evaluateJavaScript:@"document.body.offsetHeight;" completionHandler:^(id string, NSError * _Nullable error) {
        self.webHeight = [string integerValue];
        self.newsWebview.frame = CGRectMake(0, 0, swidth, self.webHeight);
        WebViewLoadFinashi = YES;
        [self reloadView];
    }];
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark     ------  tabbleView代理方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"webView"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"webView"];
        }
        [cell.contentView addSubview:self.newsWebview];
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"comment"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"comment"];
        }
        cell.textLabel.text = self.dataArray[indexPath.row - 1];
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (self.webHeight) {
            return self.webHeight;
        }else{
            return 0;
        }
    }else{
        return 50;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count + 1;
}

@end
