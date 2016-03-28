//
//  STPInitialPaymentDetailsCoordinator.h
//  Stripe
//
//  Created by Jack Flintermann on 3/28/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPBaseCoordinator.h"

@class STPAPIClient;
@protocol STPSourceProvider;

@interface STPInitialPaymentDetailsCoordinator : STPBaseCoordinator

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
                                   apiClient:(STPAPIClient *)apiClient
                              sourceProvider:(id<STPSourceProvider>)sourceProvider
                                    delegate:(id<STPCoordinatorDelegate>)delegate;

@end
