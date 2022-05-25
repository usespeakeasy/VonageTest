//
//  CallViewController.swift
//  VonageTest
//
//  Created by Crt Gregoric on 20/05/2022.
//

import UIKit
import NexmoClient
import AVFoundation

class CallViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var muteButton: UIButton?
    @IBOutlet private weak var speakerButton: UIButton?
    
    // MARK: - Private properties
    
    private let repository = Repository()
    private let lessonId = "ES_L2_D1_M"
    private let courseId = "ES_L2_M"
    
    private var client: NXMClient {
        return NXMClient.shared
    }
    
    private var call: NXMCall?

    private var callIsMuted = false
    private var soundThroughSpeakers = false

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        muteButton?.isHidden = true
        speakerButton?.isHidden = true
        setMutedButton(active: false)
        setSpeakerButton(active: false)
        
        loginUser()
    }

}

// MARK: - Helper methods

extension CallViewController {
    
    private func loginUser() {
        repository.fetchToken { token in
            DispatchQueue.main.async {
                if let token = token {
                    self.client.setDelegate(self)
                    self.client.login(withAuthToken: token)
                } else {
                    print("Unable to fetch token.")
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    private func requestPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { recordingAllowed in
            if recordingAllowed {
                self.activateSession()
            } else {
                print("❌ Recording permissions denied.")
                self.dismiss(animated: true)
            }
        }
    }
        
    private func activateSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
            startCall()
        } catch {
            print("❌ Audio session activation failed with error \(error).")
        }
    }
    
    private func startCall() {
        let customData: [String: Any] = ["lessonId": lessonId, "courseId": courseId]
        print("Starting call lessonId: \(lessonId), courseId: \(courseId) with custom data: \(customData).")
        client.serverCall(withCallee: "jeNuwovVqFM2jpLLy8pcpdWh1eP2", customData: customData) { error, call in
            if let error = error {
                print("❌ Start call error: \(error)")
            } else {
                print("Call should start \(String(describing: call?.debugDescription))")
                
                call?.setDelegate(self)
                self.call = call
            }
        }
    }
    
    private func setMutedButton(active: Bool) {
        let title = active ? "Unmute" : "Mute"
        muteButton?.setTitle(title, for: .normal)
    }

    private func setSpeakerButton(active: Bool) {
        let title = active ? "Speaker off" : "Speaker on"
        speakerButton?.setTitle(title, for: .normal)
    }
    
    private func endAndDismiss() {
        call?.hangup()
        call = nil
        client.logout()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("❌ Audio session deactivation failed with error \(error).")
        }
        dismiss(animated: true)
    }

}

// MARK: - Target action

extension CallViewController {
    
    @IBAction private func closeButtonTapped() {
        endAndDismiss()
    }
    
    @IBAction private func endButtonTapped() {
        endAndDismiss()
    }
    
    @IBAction private func muteButtonTapped() {
        callIsMuted = !callIsMuted
        setMutedButton(active: callIsMuted)
        if callIsMuted {
            print("Requesting mute.")
            call?.mute()
        } else {
            print("Requesting unmute.")
            call?.unmute()
        }
    }
        
    @IBAction private func speakerButtonTapped() {
        soundThroughSpeakers = !soundThroughSpeakers
        setSpeakerButton(active: soundThroughSpeakers)
        
        let override: AVAudioSession.PortOverride = soundThroughSpeakers ? .speaker : .none
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(override)
        } catch {
            print("❌ Unable to override output port - error: \(error)")
        }
    }
        
}

// MARK: - NXMClientDelegate

extension CallViewController: NXMClientDelegate {
    
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        print("Client did change status: \(status) with reason: \(reason)")

        if status == .connected {
            requestPermissions()
        }
    }
        
    func client(_ client: NXMClient, didReceiveError error: Error) {
        print("❌ Client did receive error: \(error)")
    }
    
}

// MARK: - NXMCallDelegate

extension CallViewController: NXMCallDelegate {
    
    func call(_ call: NXMCall, didUpdate member: NXMMember, with status: NXMCallMemberStatus) {
        print("Call did update member with status: \(status)")
        
        if status == .answered {
            muteButton?.isHidden = false
            speakerButton?.isHidden = false
        } else if status == .completed {
            endAndDismiss()
        }
    }
    
    func call(_ call: NXMCall, didUpdate member: NXMMember, isMuted muted: Bool) {
        print("Call did mute: \(muted)")
    }
    
    func call(_ call: NXMCall, didReceive error: Error) {
        print("❌ Call did receive error: \(error)")
    }
    
}

extension NXMConnectionStatus: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .disconnected: return "disconnected"
        case .connected: return "connected"
        case .connecting: return "connecting"
        @unknown default: return "unknown"
        }
    }
    
}

extension NXMConnectionStatusReason: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .unknown: return "unknown"
        case .login: return "login"
        case .logout: return "logout"
        case .tokenRefreshed: return "tokenRefreshed"
        case .tokenInvalid: return "tokenInvalid"
        case .tokenExpired: return "tokenExpired"
        case .userNotFound: return "userNotFound"
        case .terminated: return "terminated"
        case .sslPinningError: return "sslPinningError"
        @unknown default: return "unknown"
        }
    }

}

extension NXMCallMemberStatus: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .ringing: return "ringing"
        case .started: return "started"
        case .answered: return "answered"
        case .cancelled: return "cancelled"
        case .failed: return "failed"
        case .busy: return "busy"
        case .timeout: return "timeout"
        case .rejected: return "rejected"
        case .completed: return "completed"
        @unknown default: return "unknown"
        }
    }

}
