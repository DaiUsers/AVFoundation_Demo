//
//  SSAVPlayerControl.swift
//  AVFoundation_Demo
//
//  Created by wheng on 2019/4/8.
//  Copyright © 2019年 wheng. All rights reserved.
//

import UIKit
import AVFoundation

class SSAVPlayerControl: NSObject {

	var url: URL!

	var superView: UIView?
	var customFrame: CGRect?
	var playerView: SSAVPlayer?

	var controlView: SSAVPlayerControlView!

	func setVideoGravity(mode: AVLayerVideoGravity) {
		playerView?.setLayerMode(mode: mode)
	}

	func addPlayerView(frame: CGRect) {
		let playView = SSAVPlayer()
		controlView = SSAVPlayerControlView.init()

		playView.frame = frame
		playView.delegate = self
		playView.readyPlayer(url: url)
		playerView = playView

		playView.addSubview(controlView)
		controlView.delegate = self
		controlView.translatesAutoresizingMaskIntoConstraints = false
		let left = NSLayoutConstraint.init(item: controlView, attribute: .left, relatedBy: .equal, toItem: playerView, attribute: .left, multiplier: 1, constant: 0)
		let right = NSLayoutConstraint.init(item: controlView, attribute: .right, relatedBy: .equal, toItem: playerView, attribute: .right, multiplier: 1, constant: 0)
		let bot = NSLayoutConstraint.init(item: controlView, attribute: .bottom, relatedBy: .equal, toItem: playerView, attribute: .bottom, multiplier: 1, constant: 0)
		let top = NSLayoutConstraint.init(item: controlView, attribute: .top, relatedBy: .equal, toItem: playView, attribute: .top, multiplier: 1, constant: 0)
		NSLayoutConstraint.activate([left, right, bot, top])
	}

	func replacePlayer(url: URL) {
		playerView?.replacePlayer(url: url)
	}

	func resizePlayer(frame: CGRect) {
		playerView?.frame = frame
		self.playerView?.updateConstraintsIfNeeded()
		playerView?.resizeLayerFrame()
	}

}

extension SSAVPlayerControl: SSAVPlayerControlViewDelegate {
	func playAction() {
		playerView?.play()
	}

	func pauseAction() {
		playerView?.pause()
	}

	func sliderValueChanged(value: Float) {
		if let time = playerView?.totalTime {
			playerView?.seekPlayerTime(to: time * Double(value / 100))
		}
	}

	func fullSreenAction(isFullScreen: Bool) {
		if isFullScreen {
			self.controlView.isFullScreen = false
			superView?.addSubview(playerView!)
			UIView.animate(withDuration: 0.25) {
				self.playerView?.transform = CGAffineTransform.identity
			}
			self.resizePlayer(frame: customFrame!)
		} else {
			superView = playerView?.superview
			customFrame = playerView?.frame
			UIApplication.shared.keyWindow?.addSubview(playerView!)
			UIView.animate(withDuration: 0.25) {
				self.playerView?.transform = CGAffineTransform.init(rotationAngle: .pi / 2)
			}
			self.resizePlayer(frame: UIScreen.main.bounds)
			self.controlView.isFullScreen = true
		}
	}
}

extension SSAVPlayerControl: SSAVPlayerDelegate {
	func refreshData(totalTime: TimeInterval, currentTime: TimeInterval, cacheTime: TimeInterval) {
		let playValue: Float = Float(currentTime / totalTime * 100)
		let cacheValue: Float = Float(cacheTime / totalTime * 100)
		controlView.updateSlider(value: playValue)
		controlView.updateProgress(value: cacheValue)
	}

	func playerIsPlaying(isplay: Bool) {
		controlView.updatePlayStatus(isPlay: isplay)
	}

	func promptPlayerStatus(status: SSAVPlayerStatus) {
		switch status {
		case .readyToPlay:
			print("准备播放")
			break
		case .loadingVideo:
			print("加载视频")
			break
		case .playEnd:
			print("播放结束")
			break
		case .cacheData:
			print("缓冲视频")
			break
		case .cacheEnd:
			print("缓冲结束")
			break
		case .playStop:
			print("播放停止")
			break
		case .itemFailed:
			print("视频资源失败")
			break
		case .enterBackground:
			print("进入后台")
			break
		case .becomeActive:
			print("进入前台")
			break
		}
	}


}
