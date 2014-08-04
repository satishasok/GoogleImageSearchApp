//
//  GImgSearchResults.h
//  GoogleImageSearchApp
//
//  Created by Satish Asok on 8/3/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import <Foundation/Foundation.h>

// pre definition
@class GImgSearchResultPage;

@interface GImgSearchFullResults : NSObject

@property (strong, nonatomic) NSString *imageSearchString;

@property (strong, nonatomic) NSArray *imageSearchResults; // array of GImgSearchResult
@property (assign, nonatomic, readonly) BOOL fullyFetched;
@property (assign, nonatomic, readonly) BOOL fetchFailed;

- (void)fetchAndParseImageSearchResults;


@end
