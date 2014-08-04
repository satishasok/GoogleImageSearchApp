//
//  GImgSearchViewController.m
//  GoogleImageSearchApp
//
//  Created by Satish Asok on 8/2/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import "GImgSearchViewController.h"
#import "AsyncImageView.h"
#import "GImgSearchFetchingService.h"
#import "GImgSearchFullResults.h"
#import "GImgSearchResult.h"
#import "GImgSearchImageCachingService.h"

@interface GImgSearchViewController ()

//outlets
@property (weak, nonatomic) IBOutlet UICollectionView *googleImageResultsCollectionsView;
@property (weak, nonatomic) IBOutlet UISearchBar *googleImageSearchBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *firstSearchLoadActivityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scrollToBottomSearchLoadActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *searchResultsTitle;
@property (weak, nonatomic) IBOutlet UITableView *googleImageSearchHistoryTableView;


// model/service objects
@property (strong, nonatomic) NSString *currentGoogleImageSearchString;
@property (strong, nonatomic, readonly) GImgSearchFullResults *googleImageSearchResults;
@property (strong, nonatomic) GImgSearchFetchingService *localFetchingService;

@end

@implementation GImgSearchViewController

- (void)dealloc
{
    // reset the delegate on dealloc
    if (self.googleImageResultsCollectionsView) {
        self.googleImageResultsCollectionsView.dataSource = nil;
    }
    if (self.googleImageSearchBar) {
        self.googleImageSearchBar.delegate = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // setup main view
    self.view.backgroundColor = [UIColor grayColor];
    
    [self setupSubViews];
}

- (void)setupSubViews
{
    [self setupSearchbar];
    
    [self setupCollectionView];
    
    [self setupSearchHistoryTableView];

    self.searchResultsTitle.hidden = YES;

}

- (void) setupSearchbar
{
    self.googleImageSearchBar.placeholder = @"Search for images in Google";
    self.googleImageSearchBar.delegate = self;
}

- (void) setupCollectionView
{
    self.googleImageResultsCollectionsView.dataSource = self;
    self.googleImageResultsCollectionsView.delegate = self;
    self.googleImageResultsCollectionsView.backgroundColor = [UIColor grayColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    
    [self.googleImageResultsCollectionsView addGestureRecognizer:tap];
    
    [self.firstSearchLoadActivityIndicator setColor:[UIColor blueColor]];
    [self.scrollToBottomSearchLoadActivityIndicator setColor:[UIColor blueColor]];
    [self.firstSearchLoadActivityIndicator stopAnimating];
    [self.scrollToBottomSearchLoadActivityIndicator stopAnimating];
    
    
}

- (void)setupSearchHistoryTableView
{
    self.googleImageSearchHistoryTableView.hidden = YES;
    self.googleImageSearchHistoryTableView.dataSource = self;
    self.googleImageSearchHistoryTableView.delegate = self;
}

- (void)dismissKeyboard:(id)sender
{
    self.googleImageSearchHistoryTableView.hidden = YES;
    [self.googleImageSearchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // clear out all the image memory cache if we received memory warning
    [[GImgSearchImageCachingService sharedInstance] clearCache];
}

- (GImgSearchFullResults *)googleImageSearchResults
{
    if (![self.currentGoogleImageSearchString isEqualToString:@""]) {
        return [self.localFetchingService getSearchResultsForQuery:self.currentGoogleImageSearchString];
    }
    
    [self.googleImageResultsCollectionsView reloadData];
    return  nil;
}

- (GImgSearchFetchingService *)localFetchingService
{
    if (!_localFetchingService) {
        _localFetchingService = [GImgSearchFetchingService sharedInstance];
        _localFetchingService.imgSearchFetchDelegate = self;
    }
    
    return _localFetchingService;
}

#pragma UICollectionViewDataSource delegate methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.googleImageSearchResults.imageSearchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"GoogleImageSearchResultCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    AsyncImageView *imgSearchResultImgView = (AsyncImageView *)[cell viewWithTag:100];
    GImgSearchResult* imgSearchResult = (GImgSearchResult *)[self.googleImageSearchResults.imageSearchResults objectAtIndex:indexPath.row];
    NSString *urlString = imgSearchResult.thumbnailUrlString;
    NSURL *url = [NSURL URLWithString:urlString];
    imgSearchResultImgView.image = nil;
    imgSearchResultImgView.imageURL = url;
    imgSearchResultImgView.contentMode = UIViewContentModeScaleAspectFit;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.googleImageSearchBar.text = [[GImgSearchFetchingService sharedInstance] getGoogleImageSearchHistory][indexPath.row];
    self.googleImageSearchHistoryTableView.hidden = YES;
}

#pragma GImgSearchFetchDelegate methods
-(void)willBeginFetchForQuery:(NSString *)query isFirstFetch:(BOOL)isFirstFetch
{
    if ([query isEqualToString:self.currentGoogleImageSearchString]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isFirstFetch) {
                [self.firstSearchLoadActivityIndicator startAnimating];
            } else {
                [self.scrollToBottomSearchLoadActivityIndicator startAnimating];
            }
        });
    }
}

- (void)didFinishFetchingResultsForQuery:(NSString *)query
{
    if ([query isEqualToString:self.currentGoogleImageSearchString]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.firstSearchLoadActivityIndicator stopAnimating];
            [self.scrollToBottomSearchLoadActivityIndicator stopAnimating];
            self.searchResultsTitle.text = self.currentGoogleImageSearchString;
            self.searchResultsTitle.hidden = NO;
            [self.googleImageResultsCollectionsView reloadData];
        });
    }
}

- (void) fetchedDataAlreadyAvailableForQuery:(NSString *)query
{
    if ([query isEqualToString:self.currentGoogleImageSearchString]) {
        [self.firstSearchLoadActivityIndicator stopAnimating];
        [self.scrollToBottomSearchLoadActivityIndicator stopAnimating];
        self.searchResultsTitle.text = self.currentGoogleImageSearchString;
        self.searchResultsTitle.hidden = NO;
        [self.googleImageResultsCollectionsView reloadData];
    }
}


#pragma  SearchBarDelegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.currentGoogleImageSearchString = searchBar.text;
    [searchBar endEditing:YES];
    
    self.googleImageSearchHistoryTableView.hidden = YES;
    
    [self.googleImageResultsCollectionsView reloadData];
    [self.localFetchingService firstFetchForQuery:self.currentGoogleImageSearchString];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSArray * cachedSearchHistory = [[GImgSearchFetchingService sharedInstance] getGoogleImageSearchHistory];
    if (cachedSearchHistory.count) {
        self.googleImageSearchHistoryTableView.hidden = NO;
        [self.googleImageSearchHistoryTableView reloadData];
    }
    
}

#pragma scrollView delegate methods
static BOOL fetchWhenScrolledToBottom;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (fetchWhenScrolledToBottom && self.googleImageSearchResults) {
        if( [self.googleImageResultsCollectionsView numberOfItemsInSection:0] > 1) {
            BOOL lastCellVisible = [[self.googleImageResultsCollectionsView visibleCells] containsObject:[self.googleImageResultsCollectionsView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.googleImageSearchResults.imageSearchResults.count-1 inSection:0]]];
            if (lastCellVisible) {
                fetchWhenScrolledToBottom = NO;
                [self.scrollToBottomSearchLoadActivityIndicator startAnimating];
                [self.localFetchingService nextFetchForQuery:self.currentGoogleImageSearchString];
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    fetchWhenScrolledToBottom = YES;
}

#pragma UITableview datasource and delegate methods - for Search History 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[GImgSearchFetchingService sharedInstance] getGoogleImageSearchHistory].count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Previous Google Image Searches";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableViewCellidentifier = @"SearchHistoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellidentifier forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[cell viewWithTag:200];
    NSString *previouslySearchedQuery = (NSString *)[[[GImgSearchFetchingService sharedInstance] getGoogleImageSearchHistory] objectAtIndex:indexPath.row];
    label.text = previouslySearchedQuery;
    
    return cell;
}

@end
