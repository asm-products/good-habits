fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios release
```
fastlane ios release
```
Push a new release build to the App Store
### ios reset
```
fastlane ios reset
```
reset any state
### ios screenshots
```
fastlane ios screenshots
```
Take screenshots
### ios just_frame
```
fastlane ios just_frame
```

### ios splash_screen
```
fastlane ios splash_screen
```
Show splash screen localisations
### ios put_metadata_and_screenshots
```
fastlane ios put_metadata_and_screenshots
```
Put metadata and screenshots
### ios upload_strings
```
fastlane ios upload_strings
```
Upload strings to OneSky
### ios download_strings
```
fastlane ios download_strings
```
Download OneSky translations

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
