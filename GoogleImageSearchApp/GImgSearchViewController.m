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


// model/service objects
@property (strong, nonatomic) NSString *currentGoogleImageSearchString;
@property (strong, nonatomic, readonly) GImgSearchFullResults *googleImageSearchResults;
@property (strong, nonatomic, readonly) NSArray *googleImageSearchHistory;
@property (strong, nonatomic) NSMutableArray *filteredGoogleImageSearchHistory;
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

- (void)dismissKeyboard:(id)sender
{
    [self.googleImageSearchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // clear out all the image memory cache if we received memory warning
    [[GImgSearchImageCachingService sharedInstance] clearCache];
    
    // potentially in the future clear out the google image search results for queries.
}

- (GImgSearchFullResults *)googleImageSearchResults
{
    if (![self.currentGoogleImageSearchString isEqualToString:@""]) {
        return [self.localFetchingService getSearchResultsForQuery:self.currentGoogleImageSearchString];
    }
    
    [self.googleImageResultsCollectionsView reloadData];
    return  nil;
}

-(NSMutableArray *)filteredGoogleImageSearchHistory
{
    if (!_filteredGoogleImageSearchHistory) {
        _filteredGoogleImageSearchHistory = [[NSMutableArray alloc] init];
    }
    
    return _filteredGoogleImageSearchHistory;
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.firstSearchLoadActivityIndicator stopAnimating];
            [self.scrollToBottomSearchLoadActivityIndicator stopAnimating];
            self.searchResultsTitle.text = self.currentGoogleImageSearchString;
            self.searchResultsTitle.hidden = NO;
            [self.googleImageResultsCollectionsView reloadData];
        });
    }
}

- (void) didFailToFetchforQuery:(NSString *)query
{
    if ([query isEqualToString:self.currentGoogleImageSearchString]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.firstSearchLoadActivityIndicator stopAnimating];
            [self.scrollToBottomSearchLoadActivityIndicator stopAnimating];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Google Image Search failed!"
                                                            message:@"There was an error when searching google for images. Check your network connection and try again!"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
        });
    }
}


#pragma  SearchBarDelegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.currentGoogleImageSearchString = searchBar.text;
    [self.googleImageSearchBar endEditing:YES];
    [self.googleImageSearchBar resignFirstResponder];
    self.googleImageSearchBar.text = @"";
    self.googleImageSearchBar.showsCancelButton = NO;

    
    [self.googleImageResultsCollectionsView reloadData];
    [self.localFetchingService firstFetchForQuery:self.currentGoogleImageSearchString];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.googleImageSearchBar.showsCancelButton = YES;
}

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredGoogleImageSearchHistory removeAllObjects];
    NSArray * cachedSearchHistory = [[GImgSearchFetchingService sharedInstance] getGoogleImageSearchHistory];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginsWith[cd] %@", searchText];
    self.filteredGoogleImageSearchHistory= [NSMutableArray arrayWithArray:[cachedSearchHistory filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
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

#pragma UITableview datasource and delegate methods - for Search History as part of the UISearchDisplayResultsDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredGoogleImageSearchHistory.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Previous Google Image Searches";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableViewCellidentifier = @"SearchHistoryCell";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableViewCellidentifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellidentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewCellidentifier];
    }
    
    NSString *previouslySearchedQuery = (NSString *)[self.filteredGoogleImageSearchHistory objectAtIndex:indexPath.row];
    cell.textLabel.text = previouslySearchedQuery;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.googleImageSearchBar.text = self.filteredGoogleImageSearchHistory[indexPath.row];
}

@end
