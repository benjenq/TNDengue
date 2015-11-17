//
//  networkStatus.m
//  ForiBookCity
//
//  Created by Administrator on 2011/5/18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "networkStatus.h"
#import "Reachability.h"


@implementation networkStatus

+(int)netWorStatus{
	Reachability *wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReach startNotifier];
	Reachability *internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifier];
	
	NetworkStatus wifiStatus = [wifiReach currentReachabilityStatus];
	NetworkStatus internetStatus = [internetReach currentReachabilityStatus];
	
	if(wifiStatus != NotReachable)
		return (int)2;
	else if((wifiStatus == NotReachable) && (internetStatus == NotReachable))
		return (int)0;
	else if((wifiStatus == NotReachable) && (internetStatus != NotReachable))
		return (int)1;
	else
		return (int)9;
}

@end
