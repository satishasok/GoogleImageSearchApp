//
//  GImgSearchResultPage.h
//  GoogleImageSearchApp
//
//  Created by Satish Asok on 8/3/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//
// Model object to hold on to the Page information returned by the GoogleImageSearchApi response.

#import <Foundation/Foundation.h>

@interface GImgSearchResultPage : NSObject

@property (assign, nonatomic) NSInteger pageLabel;
@property (assign, nonatomic) NSInteger pageStartIndex;

@end
