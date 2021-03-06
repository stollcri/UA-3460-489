//
//  ISTNewsTableViewController.m
//  iStudent
//
//  Created by Ryan McCafferty on 11/24/13.
//  Copyright (c) 2013 University of Akron. All rights reserved.
//

#import "ISTNewsTableViewController.h"
#import "Helpers.h"
#import "FeedElement.h"
#import "ISTNewsDetailViewController.h"

@interface ISTNewsTableViewController () {
    NSXMLParser *feedData;
    NSURL *feedUrl;
    
    // keeps track of the current element while parsing the feed
    NSString *parserCurrentElement;
    // accumulates content of the feed
    NSString *contentAccumulator;
    
    NSMutableArray *entryArray;
    FeedElement *tempEntry;
}
@end

@implementation ISTNewsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = [self.Feed objectForKey:FEED_COURSE_NAME_KEY];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    parserCurrentElement = @"";
    entryArray = [NSMutableArray array];
    tempEntry = [[FeedElement alloc] init];
    contentAccumulator = @"";
    [self beginParsingFeed:[self.Feed objectForKey:FEED_URL_KEY]];
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"displayNewsItemDetail" sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return entryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    FeedElement *x = (FeedElement *)[entryArray objectAtIndex:indexPath.row];
    cell.textLabel.text = x.Title;
    
    return cell;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"displayNewsItemDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        id object = entryArray[indexPath.row];
        [[segue destinationViewController] setNewsItem:object];
        
    }
    
}


-(void)beginParsingFeed:(NSString *)url
{
    feedUrl = [[NSURL alloc] initWithString:url];
    feedData = [[NSXMLParser alloc] initWithContentsOfURL:feedUrl];
    [feedData setDelegate:self];
    [feedData parse];
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:ATOM_CONTENT]) {
        // new element that is currently being visited by the parser is the content element, set it to
        // be the value of the parserCurrentElement variable
        parserCurrentElement = elementName;
    }
    
    // if parserCurrentElement is content, instead of switching elements, add the text
    // of any elements to the contentAccumulator until the end of the content element is found
    if ([parserCurrentElement isEqualToString:ATOM_CONTENT]) {
        // since still in the content of the feed, add the current element tag to the contentAccumulator
        contentAccumulator = [contentAccumulator stringByAppendingString:elementName];
    } else {
        // not within in the content of the page, change currentElement
        parserCurrentElement = elementName;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([parserCurrentElement isEqualToString:ATOM_CONTENT]) {
        contentAccumulator = [contentAccumulator stringByAppendingString:string];
    } else if ([parserCurrentElement isEqualToString:ATOM_TITLE]) {
        tempEntry.Title = string;
    } else if ([parserCurrentElement isEqualToString:ATOM_DESCRIPTION]) {
        tempEntry.Description = string;
    } else if ([parserCurrentElement isEqualToString:ATOM_PUB_DATE]) {
        tempEntry.PublicationDate = string;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:ATOM_CONTENT]) {
        tempEntry.Content = contentAccumulator;
        contentAccumulator = @"";
        parserCurrentElement = @"";
    } else if ([elementName isEqualToString:ATOM_ENTRY_TAG]) {
        [entryArray addObject:tempEntry];
        tempEntry = [[FeedElement alloc] init];
    } else if ([elementName isEqualToString:ATOM_DESCRIPTION] ||
               [elementName isEqualToString:ATOM_PUB_DATE] ||
               [elementName isEqualToString:ATOM_TITLE]) {
        parserCurrentElement = @"";
    }
}

@end
