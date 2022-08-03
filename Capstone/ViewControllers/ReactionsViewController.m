//
//  ReactionsViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/31/22.
//

#import "ReactionsViewController.h"
#import "ReactionCell.h"
#import "APIManager.h"
#import "DateTools.h"
#import "ColorManager.h"

@interface ReactionsViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UIButton *_pictureButton;
@property (nonatomic, strong, retain) UITableView *_tableView;
@property (strong,nonatomic) PhotoViewController* photoVC;
@end

@implementation ReactionsViewController {
    NSMutableArray *_reactions;
    UIColor *_colorTheme;
}

- (void)viewDidLoad {
    [self setupTableView];
    [self setupPicButton];
    _reactions = [[NSMutableArray alloc] init];
    [self setupReactions];
    [self setupColor];
    self.photoVC = [[PhotoViewController alloc] init];
    self.photoVC.delegate = self;
}

-(void)setupTableView {
    self._tableView = [[UITableView alloc] init];
    self._tableView.dataSource = self;
    self._tableView.delegate = self;
    self._tableView.backgroundColor = [UIColor whiteColor];
    [self._tableView registerClass:[ReactionCell class] forCellReuseIdentifier:@"ReactionCell"];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

-(void)updateViewConstraints {
    [super updateViewConstraints];
    [self._tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self._pictureButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:self._tableView];
    [self.view addSubview:self._pictureButton];

    [self setupTableViewConstraints];
    [self setupPictureButtonConstraints];
}

-(void)setupTableViewConstraints {
    [self._tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self._tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self._tableView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.7].active = YES;
    [self._tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:self.view.frame.size.height * 0.1].active = YES;
}

-(void)setupPictureButtonConstraints {
    [self._pictureButton.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.4].active = YES;
    [self._pictureButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self._pictureButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:self.view.frame.size.height * -0.1].active = YES;
    [self._pictureButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.1].active = YES;
}

-(void)setupPicButton {
    self._pictureButton = [[UIButton alloc] init];
    self._pictureButton.titleLabel.font = [UIFont fontWithName:@"VirtuousSlabBold" size:20];
    self._pictureButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self._pictureButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self._pictureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self._pictureButton setTitle:[NSString stringWithFormat:@"%@", @"React!"] forState:UIControlStateNormal];
    [self._pictureButton addTarget:self action:@selector(didTapPic) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setupColor {
    _colorTheme = [[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0] colorWithAlphaComponent:0.999];
    self._pictureButton.backgroundColor = [[ColorManager sharedManager] lighterColorForColor:_colorTheme];
    self._tableView.backgroundColor = [[ColorManager sharedManager] lighterColorForColor:self._pictureButton.backgroundColor];
    self.view.backgroundColor = self._tableView.backgroundColor;
}

-(void)didTapPic {
    self.photoVC.isPicture = YES;
    self.photoVC.postID = self.postDetails.objectId;
    [[self navigationController] pushViewController:self.photoVC animated:YES];
}

- (void)didSendPic:(Reactions *)pic {
    [_reactions addObject:pic];
    [self.postDetails.Reactions addObject:pic];
    if ([self.delegate respondsToSelector:@selector(didSendReactions:)]) {
        [self.delegate didSendReactions:self.postDetails];
    }
    [self._tableView reloadData];
}

-(void)setupReactions {
    [[APIManager sharedManager] fetchReactionWithCompletion:self.postDetails.objectId completion:^(NSArray * _Nullable reactions, NSError * _Nonnull error) {
            self->_reactions = (NSMutableArray *) reactions;
            [self._tableView reloadData];
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ReactionCell *cell = [self._tableView dequeueReusableCellWithIdentifier:@"ReactionCell" forIndexPath:indexPath];
    if (cell.usernameLabel == nil) {
        cell = [cell initWithFrame:CGRectZero];
    }
    Reactions *reaction = _reactions[indexPath.row];
    cell.usernameLabel.text = reaction.username;
    
    // setup post image
    PFFileObject *pffile = reaction.reaction;
    NSString *url = pffile.url;
    NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
    cell.reactionImage.image = [UIImage imageWithData: imageData];
    
    cell.dateLabel.text = [reaction.createdAt shortTimeAgoSinceNow];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self._tableView.frame.size.height / 5.0;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_reactions count];
}

@end
