//
//  GImgSearchResult.h
//  GoogleImageSearchApp
//
//  Created by Satish Asok on 8/3/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GImgSearchResult : NSObject

@property (strong, nonatomic) NSString *imageId;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSString *thumbnailUrlString;
@property (strong, nonatomic) NSString *title;

@end
