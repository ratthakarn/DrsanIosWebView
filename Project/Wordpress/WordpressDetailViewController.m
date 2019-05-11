//
//  WordpressDetailViewController.m
//
//  Copyright (c) 2018 Sherdle. All rights reserved.
//

#import "WordpressDetailViewController.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TabNavigationController.h"
#import "UIViewController+PresentActions.h"
#import "Universal-Swift.h"
#import "NSString+HTML.h"

#define LABEL_WIDTH self.articleDetail.tableView.frame.size.width - 26
#define REMOVE_FIRST_IMAGE true

@implementation WordpressDetailViewController
{
    ShowPageCell *contentCell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    self.articleDetail.tableViewDataSource = self;
    self.articleDetail.tableViewDelegate = self;
    
    self.articleDetail.delegate = self;
    self.articleDetail.parallaxScrollFactor = 0.3; // little slower than normal.
    
    self.view.clipsToBounds = YES;
    
    NSString *authorAddition = @"";
    if ([_author length] > 0){
        authorAddition = [NSString stringWithFormat:NSLocalizedString(@"written_by", nil), _author];
    }
    
    _subTitleText = [NSString stringWithFormat:NSLocalizedString(@"published_on_wp", nil), _date, authorAddition];

    if (!_isJSONAPI) {
        
        [self removeFirstImageIfNeeded];
        
    } else {
        NSString *strURl=[NSString stringWithFormat:@"%@/api/get_post/?post_id=%@",_apiConfig[0],_detailID];
        
        _html = @"";
        
        NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                              delegate:nil
                                                         delegateQueue:[NSOperationQueue mainQueue]];
        [[session dataTaskWithURL:[NSURL URLWithString:strURl]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *connectionError) {
                    if (data == nil) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", nil)message:NO_CONNECTION_TEXT preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:nil];
                        [alertController addAction:ok];
                        
                        [self presentViewController:alertController animated:YES completion:nil];
                        
                        return ;
                    } else  {
                        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&connectionError];
                        NSArray *jsonArray = [jsonDict valueForKey:@"post"];
                        
                        self->_html =  [jsonArray valueForKey:@"content"]; // the post content
                        [self removeFirstImageIfNeeded];
                        
                        NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
                        // Add them in an index path array
                        NSArray* indexArray = [NSArray arrayWithObjects:indexPath1, nil];
                        // Launch reload for the two index path
                        [self.articleDetail.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
                    }

                    
         }] resume];
    }

    if (_imageUrl && [_imageUrl length] > 0) {
        [self.articleDetail.imageView sd_setImageWithURL:[NSURL URLWithString:[_imageUrl stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]] placeholderImage:[UIImage imageNamed:@"default_placeholder"]];
        self.articleDetail.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        //Make the header/navbar transparent
        TabNavigationController *nc = (TabNavigationController *)self.navigationController;
        [nc.gradientView turnTransparencyOn:YES animated:YES tabController: self.navigationController];
        
        // Indicate that we have an header image to show
        self.articleDetail.hasImage = YES;
    } else {
        // No header image? Hide the image top view.
        self.articleDetail.hasImage = NO;
    }

    // after setting the above properties
    [self.articleDetail initialLayout];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    TabNavigationController *nc = (TabNavigationController *)self.navigationController;
    [nc.gradientView turnTransparencyOn:NO animated:YES tabController: self.navigationController];
}

- (void) removeFirstImageIfNeeded{
    if (REMOVE_FIRST_IMAGE && [_html length] != 0){
        
        NSString *regexStr = @"<img ([^>]+)>";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:NULL];
        NSRange range = [regex rangeOfFirstMatchInString:_html options:kNilOptions range:NSMakeRange(0, [_html length])];
        
        if (range.location != NSNotFound){
            _html = [regex stringByReplacingMatchesInString:_html options:0 range:range withTemplate:@"$2"];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"articleDetail"]) {
        self.articleDetail = (DetailViewAssistant *)segue.destinationViewController.view;
        self.articleDetail.parentController = segue.destinationViewController;
    }
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1) {
        return contentCell ? [contentCell updateWebViewHeightForWidth:tableView.frame.size.width] : 50.0f;
    }

    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.row == 0) {
        TitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell" forIndexPath:indexPath];
        
        cell.lblTitle.text = [_titleText stringByDecodingHTMLEntities];
        cell.lblDescription.text = _subTitleText;

        return cell;
    }
    else if (indexPath.row == 1) {
        contentCell = (ShowPageCell *)[tableView dequeueReusableCellWithIdentifier:@"ShowPageCell" forIndexPath:indexPath];

        contentCell.parentTable = [self.articleDetail getTableView];
        contentCell.parentViewController = self;
        [contentCell loadContent:_html];
        
        return contentCell;
    }
    else if (indexPath.row == 2) {
        ActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"actionCell" forIndexPath:indexPath];
        cell.actionDelegate = self;
        
        //Change the default button into a comments button if disqus information is provided in the apiConfig (second parameter)
        if ([self.apiConfig count] == 3){
            [cell.btnSave setTitle: NSLocalizedString(@"comments", nil) forState:UIControlStateNormal];
            [cell.btnSave addTarget:self action:@selector(showDisqusComments) forControlEvents:UIControlEventTouchUpInside];
            cell.disableDefaultSaveAction = true;
        }

        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusable"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusable"];
        }
        
        cell.textLabel.text = @"Default cell";
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollOffset = scrollView.contentOffset.y;
    
    // let the view handle the paralax effect
    [self.articleDetail scrollViewDidScrollWithOffset:scrollOffset];

    if (self.articleDetail.hasImage) {
        // switch the nav bar opaque/transparent at the threshold
        TabNavigationController *nc = (TabNavigationController *)self.navigationController;
        [nc.gradientView turnTransparencyOn:(scrollOffset < self.articleDetail.headerFade) animated:YES tabController: self.navigationController];
    }
}

#pragma mark - UIContentContainer Protocol

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [contentCell updateWebViewHeightForWidth:size.width];
}

#pragma mark - Button actions

- (void)open
{
    [AppDelegate openUrl:_articleUrl withNavigationController:self.navigationController];
}

- (IBAction)share:(id)sender
{
    NSArray *activityItems = [NSArray arrayWithObjects:_articleUrl,  nil];
    [self presentActions:activityItems sender:(id)sender];
    
    //[self showDisqusComments];
}

- (void) showDisqusComments {
    
    NSString *rawIdentifier = [self.apiConfig[2] componentsSeparatedByString:@";"][2];
    NSString *identifier = [rawIdentifier stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%@",_detailID]];
    NSString *shortname = [self.apiConfig[2] componentsSeparatedByString:@";"][1];
    NSString *baseUrl = [self.apiConfig[2] componentsSeparatedByString:@";"][0];
    NSString *pageurl = _articleUrl;
    
    NSString *html = [NSString stringWithFormat:@"<html><head><meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0\"></head><body><div id=\"disqus_thread\"></div><script>var disqus_config = function () {this.page.url = \"%@\"; this.page.identifier = \"%@\"; }; (function() {   var d = document, s = d.createElement('script'); s.src = 'https://%@.disqus.com/embed.js'; s.setAttribute('data-timestamp', +new Date()); (d.head || d.body).appendChild(s);  })(); </script> <noscript>Please enable JavaScript to view the <a href=\"https://disqus.com/?ref_noscript\" rel=\"nofollow\">comments powered by Disqus.</a></noscript></html>", pageurl, identifier, shortname];
    
    if ([self.navigationController isKindOfClass:[TabNavigationController class]]){
        TabNavigationController *nc = (TabNavigationController *) self.navigationController;
        [nc.gradientView turnTransparencyOn:NO animated:YES tabController: nc];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewSwiftController *vc = (WebViewSwiftController *) [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    vc.htmlString = html;
    vc.params = @[baseUrl];
    vc.basicMode = true;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
