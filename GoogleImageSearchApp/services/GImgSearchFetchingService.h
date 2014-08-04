//
//  GImgSearchFetchingService.h
//  GoogleImageSearchApp
//
//  Created by Satish Asok on 8/3/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GImgSearchFullResults;

@protocol GImgSearchFetchDelegate <NSObject>

- (void)fetchedDataAlreadyAvailableForQuery:(NSString *)query;
- (void)willBeginFetchForQuery:(NSString *)query isFirstFetch:(BOOL)isFirstFetch;
- (void)didFinishFetchingResultsForQuery:(NSString *)query;

@end


@interface GImgSearchFetchingService : NSObject

@property id<GImgSearchFetchDelegate> imgSearchFetchDelegate;

// returns singleton instance of the GImgSearchFetchingService
+ (GImgSearchFetchingService *)sharedInstance;

- (NSArray *)getGoogleImageSearchHistory;

// use this method to access the fetched searchResults for a query, get results after fetch completes
- (GImgSearchFullResults *)getSearchResultsForQuery:(NSString *)query;


// first fetch
- (void)firstFetchForQuery:(NSString *)query;
// subsequent fetches
- (void)nextFetchForQuery:(NSString *)query;

@end
