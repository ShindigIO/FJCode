
#import "Functions.h"
#import "LambdaAlert.h"




BOOL rangesAreContiguous(NSRange first, NSRange second){
    
    NSIndexSet* firstIndexes = [NSIndexSet indexSetWithIndexesInRange:first];
    NSIndexSet* secondIndexes = [NSIndexSet indexSetWithIndexesInRange:second];
    
    NSUInteger endOfFirstRange = [firstIndexes lastIndex];
    NSUInteger beginingOfSecondRange = [secondIndexes firstIndex];
    
    if(beginingOfSecondRange - endOfFirstRange == 1)
        return YES;
    
    return NO;
    
}

NSRange rangeWithFirstAndLastIndexes(NSUInteger first, NSUInteger last){
    
    if(last < first)
        return NSMakeRange(0, 0);
    
    if(first == NSNotFound || last == NSNotFound)
        return NSMakeRange(0, 0);
    
    NSUInteger length = last-first + 1;
    
    NSRange r = NSMakeRange(first, length);
    return r;
    
}


float nanosecondsWithSeconds(float seconds){
    
    return (seconds * 1000000000);
    
}

dispatch_time_t dispatchTimeFromNow(float seconds){
    
    return  dispatch_time(DISPATCH_TIME_NOW, nanosecondsWithSeconds(seconds));
    
}

NSUInteger sizeOfFolderContentsInBytes(NSString* folderPath){
    
    NSError* error = nil;
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error];
    
    if (error != nil){
        return NSNotFound;
    }
    
    double bytes = 0.0;
    for(NSString* eachFile in contents){
        
        NSDictionary* meta = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:eachFile] error:&error];
        
        if(error != nil){
            
            break;
        }
        
        NSNumber* fileSize = [meta objectForKey:NSFileSize];
        bytes += [fileSize unsignedIntegerValue];
    } 
    
    if(error != nil){
        
        return NSNotFound;
    }
    
    return bytes;
    
}


double megaBytesWithBytes(long long bytes){
    
    NSNumber* b = [NSNumber numberWithLongLong:bytes];
    
    double bytesAsDouble = [b doubleValue];
    
    double mb = bytesAsDouble/1048576.0;
    
    return mb;
    
}



void dispatchOnMainQueue(dispatch_block_t block){
    
    dispatch_async(dispatch_get_main_queue(), block);
}

void dispatchOnMainQueueAfterDelayInSeconds(float delay, dispatch_block_t block){
    
    dispatchAfterDelayInSeconds(delay, dispatch_get_main_queue(), block);    
}

void dispatchAfterDelayInSeconds(float delay, dispatch_queue_t queue, dispatch_block_t block){
    
    dispatch_after(dispatchTimeFromNow(delay), queue, block);
    
}

void openGoogleMapsForDirectionsWithLocations(CLLocation* startLocation, CLLocation* endLocation){
    
    CLLocationCoordinate2D start = startLocation.coordinate;
	CLLocationCoordinate2D destination = endLocation.coordinate;        
	
	NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",
									 start.latitude, start.longitude, destination.latitude, destination.longitude];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
    
}

void showPromptAndOpenGoogleMapsForDirectionsWithLocations(CLLocation* startLocation, CLLocation* endLocation, void(^block)(BOOL didOpenMap)){
    
    LambdaAlert* a = [[LambdaAlert alloc] initWithTitle:@"Get Directions?" message:@"Close the app and get directions using Google maps?"];
    
    [a addButtonWithTitle:@"Directions" block:^{
        
        //CLLocation* storeLocation = [[CLLocation alloc] initWithLatitude: [annotation coordinate].latitude longitude: [annotation coordinate].longitude];
        
        openGoogleMapsForDirectionsWithLocations(startLocation, endLocation);
        
        block(YES);
        
    }];
    
    [a addButtonWithTitle:@"Cancel" block:^{
        
        block(NO);

    }];
    
    [a show];
}

NSComparisonResult compareAnnotationsByDistanceToLocation(id<MKAnnotation> obj1, id<MKAnnotation> obj2, CLLocation* center){
        
    if(!center)
        return NSOrderedAscending;
    
    CLLocation* l1 = [[CLLocation alloc] initWithLatitude:[obj1 coordinate].latitude longitude:[obj1 coordinate].longitude];
    
    CLLocationDistance d1 = [center distanceFromLocation:l1];
    
    CLLocation* l2 = [[CLLocation alloc] initWithLatitude:[obj2 coordinate].latitude longitude:[obj2 coordinate].longitude];
    
    CLLocationDistance d2 = [center distanceFromLocation:l2];
    
    if(d1 < d2)
        return NSOrderedAscending;
    if(d1 == d2)
        return NSOrderedSame;
    
    return NSOrderedDescending;
    
}

NSComparisonResult compareLocationsByDistanceToLocation(CLLocation* obj1, CLLocation* obj2, CLLocation* center){
        
    if(!center)
        return NSOrderedAscending;
        
    CLLocationDistance d1 = [center distanceFromLocation:obj1];
        
    CLLocationDistance d2 = [center distanceFromLocation:obj2];
    
    if(d1 < d2)
        return NSOrderedAscending;
    if(d1 == d2)
        return NSOrderedSame;
    
    return NSOrderedDescending;
    
}


Progress progressMake(unsigned long long complete, unsigned long long total){
    
    if(total == 0)
        return kProgressZero;
    
    Progress p;
    
    p.total = total;
    p.complete = complete;
    
    NSNumber* t = [NSNumber numberWithLongLong:total];
    NSNumber* c = [NSNumber numberWithLongLong:complete];
    
    double r = [c doubleValue]/[t doubleValue];
    
    p.ratio = r;
    
    return p;
}


Progress const kProgressZero = {
    0,
    0,
    0.0
};
