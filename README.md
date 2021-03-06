[![Build Status](https://travis-ci.org/pivotal-cf-experimental/canibump.png)](https://travis-ci.org/pivotal-cf-experimental/canibump)
#canibump

The helper app that tells developers if it's all clear to push to CAPI's pipeline.

## API

### Yes

Path: /yes  
Method: PUT  
Parameters:

  * token: The shared secret token of the target server
  * buildnumber: The build number that is responsible for the update. A build number of zero implies a manual update of the status.

Example:  
```
curl -X PUT "HOST/yes" -d "token=SECRET_TOKEN" -d "buildnumber=BUILD_NUMBER"
```

### No

Path: /no  
Method: PUT  
Parameters:

  * token: The shared secret token of the target server
  * buildnumber: The build number that is responsible for the update. A build number of zero implies a manual update of the status.
  * reason: A string explaining why the build is red

Example:  
```
curl -X PUT "HOST/no" -d "token=SECRET_TOKEN" -d "buildnumber=BUILD_NUMBER" -d "reason=REASON"
```
