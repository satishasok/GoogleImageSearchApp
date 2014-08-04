//
//  GImgSearchViewController.h
//  GoogleImageSearchApp
//
//  Created by Satish Asok on 8/2/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GImgSearchFetchingService.h"

@interface GImgSearchViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, GImgSearchFetchDelegate, UITableViewDataSource, UITableViewDelegate>

@end
