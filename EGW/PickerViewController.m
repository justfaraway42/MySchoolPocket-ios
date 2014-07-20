//
//  PickerViewController.m
//  EGW
//
//  Created by Justus Dög on 25.09.13.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import "PickerViewController.h"

@implementation PickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    if ([self.key isEqual: @"maxArticles"]) {
        self.title = NSLocalizedString(@"news", NULL);
    } else if ([self.key isEqual: @"classLevel"]) {
        self.title = NSLocalizedString(@"news", NULL);
    }
    
    NSLog(@"5");
    if ([self.key isEqual: @"maxArticles"]) {
        [self.pickerPickerView selectRow:[self.array indexOfObject:[NSString stringWithFormat:@"%i", [defaults integerForKey:self.key]]] inComponent:0 animated:YES];
    } else if ([self.key isEqual: @"classLevel"]) {
        NSInteger selectedRow;
        
        if ([defaults integerForKey:self.key] == 42) {
            selectedRow = [self.array count]-1;
        } else {
            selectedRow = [defaults integerForKey:self.key]-5;
        }
        
        [self.pickerPickerView selectRow:selectedRow inComponent:0 animated:YES];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
}

#pragma mark -
#pragma mark Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.key isEqual: @"maxArticles"]) {
        return [NSString stringWithFormat:@"%@:", NSLocalizedString(@"settingsMaximumArticles", NULL)];
    } else if ([self.key isEqual: @"classLevel"]) {
        return [NSString stringWithFormat:@"%@:", NSLocalizedString(@"settingsClassLevel", NULL)];
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if ([self.key isEqual: @"maxArticles"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%i", [defaults integerForKey:@"maxArticles"]];
    } else if ([self.key isEqual: @"classLevel"]) {
        
        NSInteger detailTextLabelIndex = 0;
        
        if ([defaults integerForKey:@"classLevel"] == 42) {
            detailTextLabelIndex = 8;
        } else {
            detailTextLabelIndex = [defaults integerForKey:@"classLevel"]-5;
        }
        
        cell.textLabel.text = [[[[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"lproj", NULL), @"/Timetables"] ofType:@"plist"]] valueForKey:@"name"] objectAtIndex:detailTextLabelIndex];
    }
                               
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.userInteractionEnabled = NO;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark -
#pragma mark Picker View Delegate Methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    // Handle the selection
    if ([self.key isEqual: @"maxArticles"]) {
        selectedValue = [[self.array objectAtIndex:row] integerValue];
    } else if ([self.key isEqual: @"classLevel"]) {
        selectedValue = [[[self.array valueForKey:@"value"] objectAtIndex:row] integerValue];
    }
    
    [defaults setInteger:selectedValue forKey:self.key];
    [defaults synchronize];
    [self.pickerTableView reloadData];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.array count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([self.key isEqual: @"maxArticles"]) {
        return [self.array objectAtIndex:row];
    } else if ([self.key isEqual: @"classLevel"]) {
        return [[self.array valueForKey:@"name"] objectAtIndex:row];
    }
    return nil;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)viewDidUnload {
    [super viewDidUnload];
}


@end
