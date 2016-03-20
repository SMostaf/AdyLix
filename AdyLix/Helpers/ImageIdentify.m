//
//  ImageIdentify.m
//  AdyLix
//
//  Created by Sahar Mostafa (Intel) on 2/20/16.
//  Copyright © 2016 Sahar Mostafa. All rights reserved.
//

// layer uses Google Cloud vision APIs to identify elements of style
// and saves into categories in DB
//#import "ImageIdentify.h"

#define API_DISCOVERY_FILE 'https://vision.googleapis.com/$discovery/rest?version=v1'
#define CLOUD_URI 'https://vision.googleapis.com' //https://www.googleapis.com/auth/cloud-platform'
#define ACTION '/v1/images:annotate'
#define LABEL_QUERY 'LABEL_DETECTION'

// https://cloud.google.com/vision/docs/label-tutorial#authenticating
// export GOOGLE_APPLICATION_CREDENTIALS= path to credential json file
// request format
/* {
 "requests":[{
    "image":{
    "content":"base64-encoded file data"
    },
    "features":[{
    "type":"LABEL_DETECTION",
    "maxResults":1
    }]
  }]
 }
 $ curl -v -k -s -H "Content-Type: application/json" https://vision.googleapis.com/v1/images:annotate?key=browser_key --data-binary @request_filename

*/
/*
@implementation ImageIdentify

// authentication happens first
// b64image request is sent for label detection and confidence score
-(Descriptor*) getLabel:(UIImage*) image {
    Descriptor* result = nil;
    int maxResCount = 1;
    
    
    
 /*   GDataServiceGoogleCalendar* service = [[GDataServiceGoogleCalendar alloc] init];
    
    [service setUserCredentialsWithUsername:username
                                   password:password];
    
    NSURL *feedURL = [GDataServiceGoogleCalendar calendarFeedURLForUsername:user];
    
    GDataServiceTicket *ticket = [service fetchFeedWithURL:feedURL
                                                  delegate:self
                                         didFinishSelector:@selector(ticket:finishedWithFeed:error:)];

    
    http = httplib2.Http()
    
    credentials = GoogleCredentials.get_application_default().create_scoped([CLOUD_URI]);
    
    credentials.authorize(http)
    
    service = build('vision', 'v1', http, discoveryServiceUrl = API_DISCOVERY_FILE)
    
    with open(photo_file, 'rb') as image:
    image_content = base64.b64encode(image.read())
    service_request = service.images().annotate(
                                                body={
                                                    'requests': [{
                                                        'image': {
                                                            'content': image_content
                                                        },
                                                        'features': [{
                                                            'type': LABEL_QUERY,
                                                            'maxResults': maxResCount,
                                                        }]
                                                    }]
                                                })
    response = service_request.execute()
    label = response['responses'][0]['labelAnnotations'][0]['description']
    print('Found label: %s for %s' % (label, photo_file))
*/    /*return result;
}

/*
- (void)ticket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedCalendar *)feed
         error:(NSError *)error {
    if (error == nil) {
        if ([[feed entries] count] > 0) {
            GDataEntryCalendar *firstCalendar = [[feed entries] objectAtIndex:0];
            GDataTextConstruct *titleTextConstruct = [firstCalendar title];
            NSString *title = [titleTextConstruct stringValue];
            NSLog(@"first calendar's title:%@", title);
        }
    }
}*/


//@end