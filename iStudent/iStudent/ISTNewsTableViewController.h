//
//  ISTNewsTableViewController.h
//  iStudent
//
//  Created by Ryan McCafferty on 11/24/13.
//  Copyright (c) 2013 University of Akron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISTNewsTableViewController : UITableViewController

// selected entry of the rssFeeds.plist file
@property (copy) NSDictionary *Feed;


@end
