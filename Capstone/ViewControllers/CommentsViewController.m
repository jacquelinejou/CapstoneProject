//
//  CommentsViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/31/22.
//

#import "CommentsViewController.h"
#import "CommentCell.h"
#import "APIManager.h"
#import "DateTools.h"
#import "ColorManager.h"

@interface CommentsViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UITextField *_commentText;
@property (nonatomic, strong) UIButton *_postButton;
@property (nonatomic, strong, retain) UITableView *_tableView;
@end

@implementation CommentsViewController {
    NSMutableArray *_comments;
    UIColor *_colorTheme;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self becomeFirstResponder];
    [self setupTableView];
    [self setupCommentsText];
    [self setupPostButton];
    _comments = [[NSMutableArray alloc] init];
    [self setupComments];
    [self setupColor];
    [self setupKeyboard];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)setupTableView {
    self._tableView = [[UITableView alloc] init];
    self._tableView.dataSource = self;
    self._tableView.delegate = self;
    [self._tableView registerClass:[CommentCell class] forCellReuseIdentifier:@"CommentCell"];
}

-(void)setupCommentsText {
    self._commentText = [[UITextField alloc] init];
    self._commentText.placeholder = @"Comment here.";
    self._commentText.font = [UIFont fontWithName:@"VirtuousSlabBold" size:17];
    self._commentText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self._commentText.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
}

-(void)setupColor {
    _colorTheme = [[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.999];
    self._postButton.backgroundColor = [[ColorManager sharedManager] lighterColorForColor:_colorTheme];
    self._tableView.backgroundColor = [[ColorManager sharedManager] lighterColorForColor:self._postButton.backgroundColor];
    self.view.backgroundColor = self._tableView.backgroundColor;
    self._commentText.backgroundColor = [[ColorManager sharedManager] darkerColorForColor:self._tableView.backgroundColor];
}

-(void)setupPostButton {
    self._postButton = [[UIButton alloc] init];
    self._postButton.titleLabel.font = [UIFont fontWithName:@"VirtuousSlabBold" size:20];
    self._postButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self._postButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self._postButton.backgroundColor = [[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.99];;
    [self._postButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self._postButton setTitle:[NSString stringWithFormat:@"%@", @"Send"] forState:UIControlStateNormal];
    [self._postButton addTarget:self action:@selector(didTapPost) forControlEvents:UIControlEventTouchUpInside];
}

-(void)didTapPost {
    [[APIManager sharedManager] postCommentWithCompletion:self._commentText.text withPostID:self.postDetails.objectId completion:^(Comments * _Nonnull comment, NSError * _Nonnull error) {
        if (!error) {
            [self.postDetails.Comments addObject:comment];
            if ([self.delegate respondsToSelector:@selector(didSendPost:)]) {
                [self.delegate didSendPost:self.postDetails];
            }
            [self->_comments addObject:comment];
            [self._tableView reloadData];
        }
    }];
    self._commentText.text = @"";
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

-(void)updateViewConstraints {
    [super updateViewConstraints];
    [self._tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self._commentText setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self._postButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:self._tableView];
    [self.view addSubview:self._commentText];
    [self.view addSubview:self._postButton];
    
    [self tableViewConstraints];
    [self commentTextConstraints];
    [self postButtonConstraints];
}

-(void)tableViewConstraints {
    [self._tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self._tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self._tableView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.7].active = YES;
    [self._tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:self.view.frame.size.height * 0.1].active = YES;
}

-(void)commentTextConstraints {
    [self._commentText.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:self.view.frame.size.height * -0.05].active = YES;
    [self._commentText.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.15].active = YES;
    [self._commentText.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.8].active = YES;
    [self._commentText.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
}

-(void)postButtonConstraints {
    [self._postButton.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.2].active = YES;
    [self._postButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self._postButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:self.view.frame.size.height * -0.05].active = YES;
    [self._postButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.15].active = YES;
}

-(void)setupComments {
    [[APIManager sharedManager] fetchCommentsWithCompletion:self.postDetails.objectId completion:^(NSArray * _Nonnull comments, NSError * _Nonnull error) {
        self->_comments = (NSMutableArray *) comments;
        [self._tableView reloadData];
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CommentCell *cell = [self._tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    if (cell.usernameLabel == nil) {
        cell = [cell initWithFrame:CGRectZero];
    }
    Comments *comment = _comments[indexPath.row];
    cell.usernameLabel.text = comment.username;
    cell.commentLabel.text = comment.comment;
    cell.dateLabel.text = [comment.createdAt shortTimeAgoSinceNow];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self._tableView.frame.size.height / 5.0;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_comments count];
}

-(void)setupKeyboard {
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height;
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

@end
