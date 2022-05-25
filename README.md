### VonageTest

Sample project demonstrating muting and audio session issues we are experiencing while using the NexmoClient library.

## Setup
Make sure to run `pod install` and then open `VonageTest.xcworkspace`.

# Issue 1 - muting and unmuting a call
After initializing a server call we store the NXMCall reference in a local variable. When toggling the mute/unmute functionality we use that NXMCall reference for calling the `mute()` or `unmute()` methods. Calling the method `mute()` mutes the call as expected. Calling the method `unmute()` seems to do nothing, the call is still muted and no sound goes to the other side of the line. This functionality can be observed in `CallViewController.muteButtonTapped`. The `NXMCallDelegate` method `func call(_ call: NXMCall, didUpdate member: NXMMember, isMuted muted: Bool)` only get's called after muting but doesn't get call when unmuting the call. We tried using alternatives like `call?.myMember?.enableMute()` and `call?.myMember?.disableMute()` or `call?.conversation.mute()` and `call?.conversation.unmute()` to no avail. Muting worked, unmuting didn't.

# Issue 2 - deactivating the audio session after finishing the call
When we're ready to finish the call we use the above mentioned NXMCall reference to call the `hangup()`, after that we clear the stored reference. At that point we're ready to logout the client, disable the audio session and close the call screen. When deactivating the audio session we get an error saying that there is still some audio work in progress. Delaying the audio session deactivation also didn't help. **Opening the call screen again will result in an audio call where no audio is audible**.
