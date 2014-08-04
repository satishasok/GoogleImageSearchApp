//
//  GImgSearchFetchingService.m
//  GoogleImageSearchApp
//
//  Created by Satish Asok on 8/3/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import "GImgSearchFetchingService.h"
#import "GImgSearchFullResults.h"

@interface GImgSearchFetchingService ()

@property (strong, nonatomic) NSMutableDictionary *cachedGoogleImageSearchResults; // dictionary of query -> GImgSearchFullResults
@property (strong, nonatomic) NSMutableArray *cachedGoogleImageSearchHistory;

@end

@implementation GImgSearchFetchingService

static NSInteger numberOfPagesToFetchOnFirstFetch = 2;

// singleton instance of the GImgSearchFetchingService & thread safe.
+ (GImgSearchFetchingService *)sharedInstance
{
	static GImgSearchFetchingService *_sharedInstance = nil;
	
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		_sharedInstance = [[GImgSearchFetchingService alloc] init];
	});
	
	return _sharedInstance;
}

- (NSArray *)getGoogleImageSearchHistory
{
    return self.cachedGoogleImageSearchHistory;
}

- (GImgSearchFullResults *)getSearchResultsForQuery:(NSString *)query
{
    return self.cachedGoogleImageSearchResults[query];
}

- (NSMutableDictionary *)cachedGoogleImageSearchResults
{
    if (!_cachedGoogleImageSearchResults) {
        _cachedGoogleImageSearchResults = [[NSMutableDictionary alloc] init];
    }
    
    return  _cachedGoogleImageSearchResults;
}

- (NSMutableArray *)cachedGoogleImageSearchHistory
{
    if (!_cachedGoogleImageSearchHistory) {
        _cachedGoogleImageSearchHistory = [[NSMutableArray alloc] init];
    }
    
    return  _cachedGoogleImageSearchHistory;
}

- (void)firstFetchForQuery:(NSString *)query;
{
    GImgSearchFullResults *searchResults = self.cachedGoogleImageSearchResults[query];
    
    if (searchResults) {
        // even though we already have the data, let the delegate know that they need reloadData
        [self.imgSearchFetchDelegate didFinishFetchingResultsForQuery:query];
    } else {
        [self fetchGoogleImagesForQuery:query numPage:numberOfPagesToFetchOnFirstFetch]; // first fetch retrieve 2 pages by default
    }
}

- (void)nextFetchForQuery:(NSString *)query
{
    GImgSearchFullResults *searchResults = self.cachedGoogleImageSearchResults[query];
    
    if (searchResults && searchResults.fullyFetched) {
        // all data alrady fetched, so just let the delegate know
        [self.imgSearchFetchDelegate fetchedDataAlreadyAvailableForQuery:query];
    } else {
        [self fetchGoogleImagesForQuery:query numPage:1]; // retrieve only one page.
    }
}


- (void)fetchGoogleImagesForQuery:(NSString *)query numPage:(NSInteger)numPages
{
    GImgSearchFullResults *searchResults = self.cachedGoogleImageSearchResults[query];
    if (!searchResults) {
        searchResults = [[GImgSearchFullResults alloc] init];
        searchResults.imageSearchString = query;
    }

    if (searchResults.fullyFetched) {
        NSLog(@"We have reached the end of the search results nothing more to retrieve.");
        return;
    }
    
    // Use NSOperationQueue to fetch search results
    NSOperationQueue *googleImagesQueryQueue = [[NSOperationQueue alloc] init];
    NSMutableArray *pageQueryOperations = [[NSMutableArray alloc] init];
    NSInvocationOperation *previousQueryOperation = nil;
    NSInvocationOperation *pageQueryOperation = nil;
    for (int i=0; i<numPages; i++) {
        pageQueryOperation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                  selector:@selector(getGImgSearchResultsForQuery:)
                                                                    object:searchResults.imageSearchString];
        if (previousQueryOperation) {
            [pageQueryOperation addDependency:previousQueryOperation];
        }
        [pageQueryOperations addObject:pageQueryOperation];
        previousQueryOperation = pageQueryOperation;
    }
    if ([pageQueryOperations count] > 0) {
        NSInvocationOperation *retriveGImgQueryQueueCompleteOperation =
                    [[NSInvocationOperation alloc] initWithTarget:self
                                                         selector:@selector(googleImageQueryRetriveCompleteForQuery:)
                                                           object:searchResults.imageSearchString];
        [retriveGImgQueryQueueCompleteOperation addDependency:pageQueryOperation];
        [pageQueryOperations addObject:retriveGImgQueryQueueCompleteOperation];
        // let the delegate know that we are fetching.
        if (numPages == numberOfPagesToFetchOnFirstFetch) {
            [self.imgSearchFetchDelegate willBeginFetchForQuery:searchResults.imageSearchString
                                                   isFirstFetch:(numPages == numberOfPagesToFetchOnFirstFetch) ? YES : NO];
        }
        
        [googleImagesQueryQueue addOperations:pageQueryOperations waitUntilFinished:NO];
    }
    
}

- (void)googleImageQueryRetriveCompleteForQuery:(NSString *)query
{
    [self.imgSearchFetchDelegate didFinishFetchingResultsForQuery:query];
    
}

// API to fetch images from Google
// does it synchronously, so do not call this directly.
- (void)getGImgSearchResultsForQuery:(NSString *)query
{
    GImgSearchFullResults *searchResults = self.cachedGoogleImageSearchResults[query];
    
    if (!searchResults) {
        searchResults = [[GImgSearchFullResults alloc] init];
        searchResults.imageSearchString = query;
        self.cachedGoogleImageSearchResults[query] = searchResults;
        [self.cachedGoogleImageSearchHistory addObject:query];
    }
    
    [searchResults fetchAndParseImageSearchResults];
}

@end
