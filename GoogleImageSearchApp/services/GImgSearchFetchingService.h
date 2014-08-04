//
//  GImgSearchFetchingService.h
//  GoogleImageSearchApp
//
//  Created by Satish Asok on 8/3/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GImgSearchFullResults;

// let the delegate know when the fetch is complete
@protocol GImgSearchFetchDelegate <NSObject>

// no fetch is needed, retrieved the fetch results directly from the cache
- (void)fetchedDataAlreadyAvailableForQuery:(NSString *)query;

// fetch is about to begin, delegate can display spinner if needed
- (void)willBeginFetchForQuery:(NSString *)query isFirstFetch:(BOOL)isFirstFetch;

// fetch complete, delegate can get the fetch results
- (void)didFinishFetchingResultsForQuery:(NSString *)query;

@optional
- (void)didFailToFetchforQuery:(NSString *)query;


@end


@interface GImgSearchFetchingService : NSObject

@property id<GImgSearchFetchDelegate> imgSearchFetchDelegate;

// returns singleton instance of the GImgSearchFetchingService
+ (GImgSearchFetchingService *)sharedInstance;

// use this method to retrieve the search history for this session.
- (NSArray *)getGoogleImageSearchHistory;

// use this method to access the fetched searchResults for a query, get results after fetch completes
- (GImgSearchFullResults *)getSearchResultsForQuery:(NSString *)query;

// first fetch
- (void)firstFetchForQuery:(NSString *)query;
// subsequent fetches
- (void)nextFetchForQuery:(NSString *)query;

@end
