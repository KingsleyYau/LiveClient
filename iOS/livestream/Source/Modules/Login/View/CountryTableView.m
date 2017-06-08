//
//  CountryTableView.m
//  UIWidget
//
//  Created by test on 2017/5/24.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "CountryTableView.h"
#import "CountryTableViewCell.h"
#import "Country.h"

@implementation CountryTableView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
        
    }
    return self;
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;
    self.items = [NSArray array];
    self.indexTitles = [NSArray array];
    [self setupCountryPlist];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
   
}


- (void)setupCountryPlist {
    NSString *profilePlistPath = [[NSBundle mainBundle] pathForResource:@"Country" ofType:@"plist"];
    NSArray *profileArray = [[NSArray alloc] initWithContentsOfFile:profilePlistPath];
    Country  *countryItem = nil;
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSDictionary *dict in profileArray) {
        countryItem = [[Country alloc] initWithDict:dict];
        [tempArray addObject:countryItem];
    }
    
    self.items = tempArray;
    
    NSMutableArray *indexTemp = [NSMutableArray array];
    for (char ch='A'; ch<='Z'; ch++) {
        [indexTemp addObject:[NSString stringWithFormat:@"%c",ch]];
    }
    
    self.indexTitles = indexTemp;
    
}


- (void)reloadData {
    [super reloadData];

}
#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    switch(section) {
        case 0: {
            if(self.items.count > 0) {
                number = self.items.count;
                
            }
        }
        default:break;
    }
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0;
    height = [CountryTableViewCell cellHeight];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    CountryTableViewCell *cell = [CountryTableViewCell getUITableViewCell:tableView];
    result = cell;
    Country *country = [self.items objectAtIndex:indexPath.row];
    cell.countryName.text = country.fullName;
    cell.countryZipCode.text = [NSString stringWithFormat:@"+%@",country.zipCode];

    

    
    return result;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.indexTitles;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.items.count) {
        if([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectCountry:)]) {
            [self.tableViewDelegate tableView:self didSelectCountry:[self.items objectAtIndex:indexPath.row]];
        }
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {

    NSInteger sectionCount= 0;
    
    for (Country *country in self.items) {
        
        if ([country.firstLetter isEqualToString:title]) {
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:sectionCount inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            return sectionCount;
            
        }
        
        sectionCount++;
        
    }

    return sectionCount;
    
}
    

@end
