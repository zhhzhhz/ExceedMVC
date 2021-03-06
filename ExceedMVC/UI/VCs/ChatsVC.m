//
//  ChatsVC.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "ChatsVC.h"
#import "ChatsItem.h"
#import "CoreEngine.h"

@interface ChatsVC () <UITableViewDataSource, UITableViewDelegate> {
    
    UITableView *_tableView;
    
    NSMutableArray *_marrChat;
}

@end

@implementation ChatsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"会话";
        _marrChat = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    [self.view addSubview:_tableView];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
    [defaultCenter addObserver:self selector:@selector(notifUserInfoSuccess:)
                          name:NetUserInfoSuccess object:nil];
    
    // 读取本地会话纪录
    if ([self.dataSource respondsToSelector:@selector(chatsVC:loadChats:)]) {
        [_marrChat removeAllObjects];
        [self.dataSource chatsVC:self loadChats:_marrChat];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //
    [_tableView release];
    //
    [_marrChat release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _tableView.frame = self.view.bounds;
}


#pragma mark - Notification

- (void)notifUserInfoSuccess:(NSNotification *)notif
{
    UInt64 userID = [[notif.userInfo objectForKey:@"userid"] longLongValue];
    NSString *userName = [notif.userInfo objectForKey:@"username"];
    NSString *avatarUrl = [notif.userInfo objectForKey:@"avatar"];
    //
    for (ChatsItem *chatsItem in _marrChat) {
        if (chatsItem.userID == userID) {
            chatsItem.userName = userName;
            chatsItem.avatarUrl = avatarUrl;
            [_tableView reloadData];
            break;
        }
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _marrChat.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellId = @"ChatsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId] autorelease];
    }
    //
    ChatsItem *chatsItem = [_marrChat objectAtIndex:indexPath.row];
    cell.textLabel.text = chatsItem.userName;
    cell.detailTextLabel.text = chatsItem.latestMsg;
    // 显示头像
    [cell.imageView loadImageFromCachePath:nil orPicUrl:chatsItem.avatarUrl withDownloadResult:^(UIImageView *imageView, NSString *picUrl, float progress, BOOL finished, NSError *error) {
        // error为nil表示下载成功
        if (nil == error) {
            [_tableView reloadData];
        }
    }];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(chatsVC:chatWithFriend:)]) {
        ChatsItem *chatsItem = [_marrChat objectAtIndex:indexPath.row];
        [self.delegate chatsVC:self chatWithFriend:chatsItem.userID];
    }
}

@end
