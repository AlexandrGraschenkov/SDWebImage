//
//  MasterViewController.m
//  SDWebImage Demo
//
//  Created by Olivier Poitrey on 09/05/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import "MasterViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DetailViewController.h"
#import <FLAnimatedImage/FLAnimatedImage.h>

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"SDWebImage";
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"Clear Cache"
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(flushCache)];
        
        // HTTP NTLM auth example
        // Add your NTLM image url to the array below and replace the credentials
        [SDWebImageManager sharedManager].imageDownloader.username = @"httpwatch";
        [SDWebImageManager sharedManager].imageDownloader.password = @"httpwatch01";
        
        _objects = [NSMutableArray arrayWithObjects:
                    @"http://www.httpwatch.com/httpgallery/authentication/authenticatedimage/default.aspx?0.35786508303135633",     // requires HTTP auth, used to demo the NTLM auth
                    @"http://assets.sbnation.com/assets/2512203/dogflops.gif",
                    @"http://www.ioncannon.net/wp-content/uploads/2011/06/test2.webp",
                    @"http://www.ioncannon.net/wp-content/uploads/2011/06/test9.webp",
                    nil];

        for (int i=0; i<100; i++) {
            [_objects addObject:[NSString stringWithFormat:@"https://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage%03d.jpg", i]];
        }

    }
    [SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"Cell" bundle:nil] forCellReuseIdentifier:@"Cell"];
}

- (void)flushCache
{
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearDisk];
}
							
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIImageView *imgView = [cell viewWithTag:1];

    [imgView setShowActivityIndicatorView:YES];
    [imgView setIndicatorStyle:UIActivityIndicatorViewStyleGray];

    UILabel *label = (id)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"Image #%ld", (long)indexPath.row];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    SDWebImageOptions options = indexPath.row == 0 ? SDWebImageRefreshCached : 0;
    BOOL isGif = [[_objects objectAtIndex:indexPath.row] hasSuffix:@"gif"];
    if (isGif) {
        options |= SDWebImageNSDataResult;
    }
    
    __weak FLAnimatedImageView *wImgView = (id)imgView;
    [imgView sd_setImageWithURL:[NSURL URLWithString:[_objects objectAtIndex:indexPath.row]]
                      placeholderImage:[UIImage imageNamed:@"placeholder"] options:options completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if (isGif) {
             FLAnimatedImage *img = [FLAnimatedImage animatedImageWithGIFData:(id)image];
             wImgView.animatedImage = img;
         }
     }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController)
    {
        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    }
    NSString *largeImageURL = [[_objects objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"small" withString:@"source"];
    self.detailViewController.imageURL = [NSURL URLWithString:largeImageURL];
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
