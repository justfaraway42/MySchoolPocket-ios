//
//  TableCellView.m
//  News
//
//  Created by Justus Dög on 06.07.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import "NewsTableCellView.h"


@implementation NewsTableCellView
@synthesize title;
@synthesize date;
@synthesize unread;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

// UITableViewCell not response to View lifecycle **REMOVE_LATER

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

/*
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any stronged subviews of the main view.
    // e.g. self.myOutlet = nil;
}
*/

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

@end
