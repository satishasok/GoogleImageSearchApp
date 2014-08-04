//
//  GImgSearchResults.m
//  GoogleImageSearchApp
//
//  Created by Satish Asok on 8/3/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import "GImgSearchFullResults.h"
#import "GImgSearchResult.h"
#import "GImgSearchResultPage.h"

@interface GImgSearchFullResults ()

@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSMutableArray *searchResultPages; // array of GImgSearchResultPage
@property (strong, nonatomic) GImgSearchResultPage *currentResultsPage;
@property (assign, nonatomic, readwrite) BOOL fullyFetched;

@end

@implementation GImgSearchFullResults

static NSString *gImgSearchApiURLFormat = @"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&rsz=%d&start=%d&imgsz=small";
static NSInteger numberOfImagesToFetchPerPage = 8;

- (id)init
{
    self = [super init];
    
    if (self) {
        self.searchResults = [[NSMutableArray alloc] init];
        self.searchResultPages = [[NSMutableArray alloc] init];
    }
    
    return  self;
}

- (NSArray *)imageSearchResults
{
    return self.searchResults;
}

- (NSMutableArray *)searchResults
{
    if (!_searchResults) {
        _searchResults = [[NSMutableArray alloc] init];
    }
    
    return _searchResults;
}

- (NSMutableArray *)searchResultPages
{
    if (!_searchResultPages) {
        _searchResultPages = [[NSMutableArray alloc] init];
    }
    
    return _searchResultPages;
}

- (GImgSearchResultPage *)currentResultsPage
{
    if (!_currentResultsPage) {
        _currentResultsPage = [[GImgSearchResultPage alloc] init];
        _currentResultsPage.pageStartIndex = 0;
        _currentResultsPage.pageLabel = 1;
    }
    
    return _currentResultsPage;
}

- (BOOL)fetchAndParseImageSearchResults
{
    BOOL fetchSuccess = NO;
    NSString *googleImgApiURLString = [NSString stringWithFormat:gImgSearchApiURLFormat,
                                       self.imageSearchString, numberOfImagesToFetchPerPage,
                                       self.currentResultsPage.pageStartIndex];
    NSURL *googleImgApiURL = [NSURL URLWithString:[googleImgApiURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *googleImgApiRequest = [NSURLRequest requestWithURL:googleImgApiURL];
    
    
    // Make the Google Image Api Request
    NSLog(@"Getting Google Images for query %@, StartPage %d, numItems %d",
                                self.imageSearchString, self.currentResultsPage.pageStartIndex,
                                numberOfImagesToFetchPerPage);
    NSError *error;
    NSHTTPURLResponse *googleImgApiResponse;
    NSData* googleImgResponseData = [NSURLConnection sendSynchronousRequest:googleImgApiRequest returningResponse:&googleImgApiResponse error:&error];
    if ([googleImgApiResponse statusCode] == 200 && error==nil && [googleImgResponseData length] > 0) {
        @synchronized(self.searchResults) {
            NSDictionary *googleImgApiResponseDictionary = [NSJSONSerialization JSONObjectWithData:googleImgResponseData
                                                                                           options:NSJSONReadingMutableContainers
                                                                                             error:&error];
            if (error == nil && googleImgApiResponseDictionary &&
                                    [googleImgApiResponseDictionary isKindOfClass:[NSDictionary class]]) {
                [self parseGoogleImageSearchResponseDictionary:googleImgApiResponseDictionary];
            } else {
                NSString* googleImgResponseDataAsString = [NSString stringWithUTF8String:[googleImgResponseData bytes]];
                NSLog(@"Error: googleImgResponseData not a valid JSON. %@", googleImgResponseDataAsString);
            }
        }
    } else {
        NSLog(@"Error: Response: %@, ResponseData: %@", googleImgApiResponse, googleImgResponseData);
    }
    
    return fetchSuccess;
}

- (void)parseGoogleImageSearchResponseDictionary:(NSDictionary *)responseDictionary
{
    NSDictionary *responseDataDictionary = [responseDictionary objectForKey:@"responseData"];
    if (responseDataDictionary &&
        [responseDataDictionary isKindOfClass:[NSDictionary class]]) {
        
        // Parse out the results
        NSArray *googleImgApiResultsArray = [responseDataDictionary objectForKey:@"results"];
        if (googleImgApiResultsArray && [googleImgApiResultsArray count] > 0) {
            NSLog(@"Got Google Images APi response with valid results of count %d for query %@, StartPage %d, numItems %d",
                  [googleImgApiResultsArray count], self.imageSearchString, self.currentResultsPage.pageStartIndex, numberOfImagesToFetchPerPage);
            self.currentResultsPage.pageStartIndex += [googleImgApiResultsArray count];
            for (NSDictionary *googleImgApiResultDic in googleImgApiResultsArray) {
                GImgSearchResult *imgSearchResult = [[GImgSearchResult alloc] init];
                imgSearchResult.imageId = googleImgApiResultDic[@"imageId"];
                imgSearchResult.urlString = googleImgApiResultDic[@"url"];
                imgSearchResult.title = googleImgApiResultDic[@"title"];
                imgSearchResult.thumbnailUrlString = googleImgApiResultDic[@"tbUrl"];
                [self.searchResults addObject:imgSearchResult];
            }
        }
        
        // Parse Out the cursor and pagination data, for nextPageFetch
        NSArray *googleImgApiResultPagesArray = [[responseDataDictionary objectForKey:@"cursor"] objectForKey:@"pages"];
        for (NSDictionary *pageDic in googleImgApiResultPagesArray) {
            GImgSearchResultPage *resultPage = [[GImgSearchResultPage alloc] init];
            resultPage.pageStartIndex = [pageDic[@"start"] integerValue];
            resultPage.pageLabel = [pageDic[@"label"] integerValue];
            [self.searchResultPages addObject:resultPage];
        }
        GImgSearchResultPage *lastPage = (GImgSearchResultPage *)[self.searchResultPages lastObject];
        if (lastPage.pageStartIndex >= self.currentResultsPage.pageStartIndex) {
            for (GImgSearchResultPage *page in self.searchResultPages) {
                
                if (self.currentResultsPage.pageStartIndex <= page.pageStartIndex) {
                    self.currentResultsPage.pageLabel = page.pageLabel;
                    self.currentResultsPage.pageStartIndex = page.pageStartIndex;
                    break;
                }
            }
        } else {
            self.currentResultsPage.pageStartIndex = -1;
            self.currentResultsPage.pageLabel = -1;
            self.fullyFetched = YES;
        }
    }
}

@end
