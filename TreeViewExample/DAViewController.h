//
//  DAViewController.h
//  TreeViewExample
//
//  Created by kernel on 13/03/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "TreeTable.h"

@interface DAViewController : UIViewController <UITableViewDelegate>
@property (strong, nonatomic) IBOutlet TreeTable *treeModel;

@property (strong, nonatomic) IBOutlet UITableView *treeView;
@end
