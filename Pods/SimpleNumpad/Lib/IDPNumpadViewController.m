//
//  IDPNumpadViewController.m
//  IDPSimpleNumpad
//
//  Created by 能登 要 on 2015/07/02.
//  Copyright (c) 2015年 Irimasu Densan Planning. All rights reserved.
//

#import "IDPNumpadViewController.h"


@interface IDPNumpadViewController () <UIGestureRecognizerDelegate>
{
    __weak IBOutlet IDPNumberDisplay *_numberDisplay;
    __weak IBOutlet IDPNumpadView *_numpadView;
    UIViewController *_searchViewController;
    UIViewController<IDPNumpadViewControllerUnitViewControllerProtocol> *_unitDisplayController;
    
    __weak /*IBOutlet*/ NSLayoutConstraint *_searchControlTopConstraint;
    __weak IBOutlet NSLayoutConstraint *_numpadBottomConstraint;
    __weak IBOutlet NSLayoutConstraint *_numberDisplayLabelTrailingConstraint;
    CGFloat _statupPresentingViewControllerViewFrameMinY;
    
    NSString *_serialNumber;
    
}
- (void) setSearchViewController:(UIViewController *)searchViewController;
@end

@implementation IDPNumpadViewController

- (NSString *)serialNumber
{
    return _serialNumber;
}

- (void) setSerialNumber:(NSString *)serialNumber
{
    _serialNumber = serialNumber;
        // シリアル番号を格納
    
    if( _numpadView.inputStyle == IDPNumpadViewInputStyleSerialNumber ){
        NSArray *components = [serialNumber componentsSeparatedByString:@"-"];
        _numpadView.text = [components componentsJoinedByString:@""];
        _numberDisplay.displayLabel.text = _numpadView.displayText;
    }
}

+ (IDPNumpadViewController *)numpadViewControllerWithStyle:(IDPNumpadViewControllerStyle )style inputStyle:(IDPNumpadViewControllerInputStyle)inputStyle
{
    id viewController = nil;
    @autoreleasepool {
        NSDictionary *styles = @{
              @(IDPNumpadViewControllerStyleDefault):@"darkNinja"
             ,@(IDPNumpadViewControllerStyleStandard):@"standardCB"
             ,@(IDPNumpadViewControllerStylePro):@"proCB"
             ,@(IDPNumpadViewControllerStyleRetro):@"retroCB"
             ,@(IDPNumpadViewControllerStyleMelancholy):@"melancholyCB"
             ,@(IDPNumpadViewControllerStyleMemories):@"memoriesCB"
             ,@(IDPNumpadViewControllerStyleFusion):@"fusion"
             ,@(IDPNumpadViewControllerStylePeach):@"freshPeachLL"
             ,@(IDPNumpadViewControllerStyleGreen):@"freshGreenLL"
             ,@(IDPNumpadViewControllerStylePurple):@"freshPurpleLL"
             ,@(IDPNumpadViewControllerStyleCalcApp):@"calcapp"
        };

        
        NSString *identifier = styles[@(style)];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IDPNumpadViewController" bundle:nil];
        viewController = [storyboard  instantiateViewControllerWithIdentifier:identifier != nil ? identifier : styles[@(IDPNumpadViewControllerStyleDefault)]];
   
        IDPNumpadViewController *numpadViewController = viewController;
        numpadViewController.inputStyle = inputStyle;
    }
    return viewController;
}

+ (IDPNumpadViewController *)numpadViewControllerWithStyle:(IDPNumpadViewControllerStyle )style inputStyle:(IDPNumpadViewControllerInputStyle)inputStyle  showNumberDisplay:(BOOL)showNumberDisplay
{
    IDPNumpadViewController *numpadViewController = [IDPNumpadViewController numpadViewControllerWithStyle:style inputStyle:inputStyle];
    if( showNumberDisplay != YES ){
        numpadViewController.hideNumberDisplay = YES;
    }
    return numpadViewController;
}

+ (IDPNumpadViewController *)numpadViewControllerWithStyle:(IDPNumpadViewControllerStyle )style searchViewController:(UIViewController *)searchViewController showNumberDisplay:(BOOL)showNumberDisplay
{
    return [IDPNumpadViewController numpadViewControllerWithStyle:style searchViewController:searchViewController unitDisplayController:nil inputStyle:IDPNumpadViewControllerInputStyleSerialNumber showNumberDisplay:showNumberDisplay];
}

+ (IDPNumpadViewController *)numpadViewControllerWithStyle:(IDPNumpadViewControllerStyle )style searchViewController:(UIViewController *)searchViewController unitDisplayController:(UIViewController<IDPNumpadViewControllerUnitViewControllerProtocol> *) unitDisplayController inputStyle:(IDPNumpadViewControllerInputStyle)inputStyle showNumberDisplay:(BOOL)showNumberDisplay
{
    IDPNumpadViewController *numpadViewController = [IDPNumpadViewController numpadViewControllerWithStyle:style inputStyle:IDPNumpadViewControllerInputStyleSerialNumber];
    if( showNumberDisplay != YES ){
        numpadViewController.hideNumberDisplay = YES;
    }
    
    [numpadViewController setSearchViewController:searchViewController];
        // 検索用ViewController を登録
    
    [numpadViewController setUnitDisplayCOntroller:unitDisplayController];
        // 単位表示用Controller を追加
    
    return numpadViewController;
}


- (void) setSearchViewController:(UIViewController *)searchViewController;
{
    _searchViewController = searchViewController;
}

- (void) setUnitDisplayCOntroller:(UIViewController<IDPNumpadViewControllerUnitViewControllerProtocol> *)unitDisplayController;
{
    _unitDisplayController = unitDisplayController;
}

- (UIViewController *)searchViewController
{
    return _searchViewController;
}

- (IDPNumberDisplay *)numberDisplay
{
    return _numberDisplay;
}

- (IDPNumpadView *)numpadView
{
    return _numpadView;
}

- (NSString *)displayText
{
    return _numpadView.displayText;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    if(_inputStyle == IDPNumpadViewControllerInputStyleNumber ) {
        _numpadView.text = [@(_value) description];
        _numberDisplay.displayLabel.text = _numpadView.displayText;
    }else if(_inputStyle == IDPNumpadViewControllerInputStyleSerialNumber ) {
        _numpadView.inputStyle = IDPNumpadViewInputStyleSerialNumber;
        _numpadView.separatorIntervals = self.separatorIntervals;
        _numpadView.text = [[_serialNumber componentsSeparatedByString:@"-"] componentsJoinedByString:@""];
        if( _numpadView.text == nil ){
            _numpadView.text = @"";
        }
        
        _numberDisplay.displayLabel.text = _numpadView.displayText;
        
        // displayの表示を制御
        [_numpadView hiddenNumberSupportButton:YES];
        
        if( _searchViewController ){
            _searchViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:_searchViewController.view];

            _statupPresentingViewControllerViewFrameMinY = CGRectGetMinY(self.presentingViewController.view.frame);
            
            NSLayoutConstraint *searchControlTopConstraint = [NSLayoutConstraint constraintWithItem:_searchViewController.view
                                                                                          attribute:NSLayoutAttributeTop
                                                                                          relatedBy:NSLayoutRelationEqual
                                                                                             toItem:self.view
                                                                                          attribute:NSLayoutAttributeTop
                                                                                         multiplier:1.0
                                                                                           constant:0
            ];
            
            _searchControlTopConstraint = searchControlTopConstraint;
            
            NSArray *layoutConstraint = @[
                  searchControlTopConstraint
                ,[NSLayoutConstraint constraintWithItem:_searchViewController.view
                                   attribute:NSLayoutAttributeWidth
                                   relatedBy:NSLayoutRelationEqual
                                   toItem: self.view
                                   attribute:NSLayoutAttributeWidth
                                   multiplier:1.0
                                   constant:0
                ]
                  
                ,[NSLayoutConstraint constraintWithItem:_searchViewController.view
                                             attribute:NSLayoutAttributeBottom
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:_hideNumberDisplay ? _numpadView : _numberDisplay
                                             attribute: NSLayoutAttributeTop
                                            multiplier: 1.0
                                              constant:0
                ]
            ];
            [self.view addConstraints:layoutConstraint];
        
            [self addChildViewController:_searchViewController];
            
            __block UITapGestureRecognizer *tapGestureRecognizer = nil;
            [self.view.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIGestureRecognizer *gestureRecognizer = obj;
                if( [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]){
                    tapGestureRecognizer = (UITapGestureRecognizer *)gestureRecognizer;
                    *stop = YES;
                }
            }];
            if( tapGestureRecognizer != nil ){
                [self.view removeGestureRecognizer:tapGestureRecognizer];
            }
            
            [self.view sendSubviewToBack:_searchViewController.view];
        }
    }
    
    if( _unitDisplayController ){
        CGFloat numberDisplayLabelTrailingConstraint = _numberDisplayLabelTrailingConstraint.constant;
        UIEdgeInsets insetsUnitDisplay = UIEdgeInsetsMake(0, numberDisplayLabelTrailingConstraint ,0,numberDisplayLabelTrailingConstraint );
        if( [_unitDisplayController respondsToSelector:@selector(unitViewController: contentInsets:)] ){
            insetsUnitDisplay = [_unitDisplayController unitViewController:self contentInsets:insetsUnitDisplay];
        }
        
        CGFloat unitDisplayWidth = 80.0;
        if( [_unitDisplayController respondsToSelector:@selector(unitViewControllerWidth:)] ){
            unitDisplayWidth = [_unitDisplayController unitViewControllerWidth:self];
        }
        _numberDisplayLabelTrailingConstraint.constant = insetsUnitDisplay.left + unitDisplayWidth + insetsUnitDisplay.right;
        
        _unitDisplayController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_unitDisplayController.view];
        
        NSArray *constraints = @[
                                 [NSLayoutConstraint constraintWithItem:_unitDisplayController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_numberDisplay.displayLabel attribute:NSLayoutAttributeRight multiplier:1 constant:insetsUnitDisplay.left]
                                 ,[NSLayoutConstraint constraintWithItem:_unitDisplayController.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_numberDisplay attribute:NSLayoutAttributeRight multiplier:1 constant:-insetsUnitDisplay.right]
                                 ,[NSLayoutConstraint constraintWithItem:_unitDisplayController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_numberDisplay attribute:NSLayoutAttributeTop multiplier:1 constant:0.0]
                                 ,[NSLayoutConstraint constraintWithItem:_unitDisplayController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_numberDisplay attribute:NSLayoutAttributeHeight multiplier:1 constant:0.0]
                                 ];
        [self.view addConstraints:constraints];
        
        [self addChildViewController:_unitDisplayController];
        
    }

    
    if( _hideNumberDisplay ){
        [_numberDisplay removeFromSuperview];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // presentingViewControllerを監視
    [self.presentingViewController.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.view setNeedsUpdateConstraints];

    UIView *presentingViewControllerView = object;
    if( CGRectGetHeight(self.view.frame) ==  CGRectGetHeight(presentingViewControllerView.frame) ){
        _searchControlTopConstraint.constant = 0;
        _numpadBottomConstraint.constant = 0;
    }else{
//        NSLog(@"CGRectGetMinY(presentingViewControllerView.frame)=%@",@(CGRectGetMinY(presentingViewControllerView.frame)) );
        
        if (_statupPresentingViewControllerViewFrameMinY == 0.0 ) {
            _searchControlTopConstraint.constant = CGRectGetMinY(presentingViewControllerView.frame);

            CGFloat delta = CGRectGetHeight(self.view.frame) - CGRectGetHeight(presentingViewControllerView.frame) - CGRectGetMinY(presentingViewControllerView.frame);
            _numpadBottomConstraint.constant = delta;
        }else{
            _searchControlTopConstraint.constant = - _statupPresentingViewControllerViewFrameMinY;
        }
    }
    
    CGFloat statusBarOrientationAnimationDuration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView animateWithDuration:statusBarOrientationAnimationDuration
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIView *presentingViewControllerView = self.presentingViewController.view;
    [presentingViewControllerView removeObserver:self forKeyPath:@"frame" context:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) numpadViewDidUpdate:(IDPNumpadView *)numpadView
{
    _numberDisplay.displayLabel.text = _numpadView.displayText;

    if( _inputStyle == IDPNumpadViewControllerInputStyleNumber ){
        _value = numpadView.value;
    }else{
        _serialNumber = _numpadView.serialnNumber;
    }
    
    if( [_delegate respondsToSelector:@selector(numpadViewControllerDidUpdate:)] ){
        [_delegate numpadViewControllerDidUpdate:self];
    }
    
}

- (void) numpadViewDidEnter:(IDPNumpadView *)numpadView
{
    if( [_delegate respondsToSelector:@selector(numpadViewControllerDidEnter:)] ){
        [_delegate numpadViewControllerDidEnter:self];
    }
}

- (UIModalPresentationStyle)modalPresentationStyle
{
    return UIModalPresentationOverCurrentContext;
}

- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL shouldBegin = YES;
    
    if( _numberDisplay != nil ){
        CGPoint location = [gestureRecognizer locationInView:_numberDisplay.superview];
        if( CGRectContainsPoint(_numberDisplay.frame, location)){
                shouldBegin = NO;
        }
    }
    if( _numpadView != nil ){
        CGPoint location = [gestureRecognizer locationInView:_numpadView.superview];
        if( CGRectContainsPoint(_numpadView.frame, location)){
            shouldBegin = NO;
        }
    }
    
    return shouldBegin;
}

- (IBAction)onCancel:(id)sender
{
    if( [_delegate respondsToSelector:@selector(numpadViewControllerDidCancel:)] ){
        [_delegate numpadViewControllerDidCancel:self];
    }
}

@end
