//
//  TableCellView.h
//  News
//
//  Created by Justus Dög on 06.07.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewsTableCellView : UITableViewCell {
    UILabel *title;    
    UILabel *date;
    UIImageView *unread;
}
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *date;
@property (nonatomic, strong) IBOutlet UIImageView *unread;

@end

// 1. Neue View Controller Class (ohne XIB) von UITableViewCell erstellen (sonst wird XIB mit Window erstellt - anderer File's Owner)
// 2. XIB (empty) erstellen und "TableCellView" als Klasse angeben