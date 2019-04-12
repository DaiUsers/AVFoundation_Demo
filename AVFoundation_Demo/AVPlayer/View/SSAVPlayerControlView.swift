//
//  SSAVPlayerView.swift
//  AVFoundation_Demo
//
//  Created by wheng on 2019/4/8.
//  Copyright © 2019年 wheng. All rights reserved.
//

import UIKit

protocol SSAVPlayerControlViewDelegate: NSObjectProtocol {
	func playAction() -> Void
	func pauseAction() -> Void
	func sliderValueChanged(value: Float) -> Void
	func fullSreenAction(isFullScreen: Bool)-> Void
}

class SSAVPlayerControlView: UIView {

	var botControlView: UIView!
	/// 播放的进度
	var slider: UISlider!
	/// 缓冲的进度
	var progress: UIProgressView!
	/// 播放暂停按钮
	var playBt: UIButton!
	/// 全屏按钮
	var fullScreenBt: UIButton!
	/// 是否全屏状态
	var isFullScreen: Bool = false

	weak var delegate: SSAVPlayerControlViewDelegate?

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.clear
		botControlView = UIView.init()
		fullScreenBt = UIButton.init()
		playBt = UIButton.init()
		slider = UISlider.init()
		progress = UIProgressView.init()

		self.addSubview(botControlView)
		botControlView.addSubview(playBt)
		botControlView.addSubview(progress)
		botControlView.addSubview(slider)
		botControlView.addSubview(fullScreenBt)

		botControlView.translatesAutoresizingMaskIntoConstraints = false
		playBt.translatesAutoresizingMaskIntoConstraints = false
		progress.translatesAutoresizingMaskIntoConstraints = false
		slider.translatesAutoresizingMaskIntoConstraints = false
		fullScreenBt.translatesAutoresizingMaskIntoConstraints = false

		let vleft = NSLayoutConstraint.init(item: botControlView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
		let vright = NSLayoutConstraint.init(item: botControlView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
		let vbot = NSLayoutConstraint.init(item: botControlView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
		let vheight = NSLayoutConstraint.init(item: botControlView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 44)
		self.addConstraints([vleft, vright, vbot])
		botControlView.addConstraint(vheight)

		let btleft = NSLayoutConstraint.init(item: playBt, attribute: .left, relatedBy: .equal, toItem: botControlView, attribute: .left, multiplier: 1, constant: 0)
		let bttop = NSLayoutConstraint.init(item: playBt, attribute: .top, relatedBy: .equal, toItem: botControlView, attribute: .top, multiplier: 1, constant: 0)
		let btbot = NSLayoutConstraint.init(item: playBt, attribute: .bottom, relatedBy: .equal, toItem: botControlView, attribute: .bottom, multiplier: 1, constant: 0)
		let btw = NSLayoutConstraint.init(item: playBt, attribute: .width, relatedBy: .equal, toItem: botControlView, attribute: .height, multiplier: 1, constant: 0)
		botControlView.addConstraints([btleft, bttop, btbot, btw])

		let fleft = NSLayoutConstraint.init(item: fullScreenBt, attribute: .right, relatedBy: .equal, toItem: botControlView, attribute: .right, multiplier: 1, constant: 0)
		let ftop = NSLayoutConstraint.init(item: fullScreenBt, attribute: .top, relatedBy: .equal, toItem: botControlView, attribute: .top, multiplier: 1, constant: 0)
		let fbot = NSLayoutConstraint.init(item: fullScreenBt, attribute: .bottom, relatedBy: .equal, toItem: botControlView, attribute: .bottom, multiplier: 1, constant: 0)
		let fwidth = NSLayoutConstraint.init(item: fullScreenBt, attribute: .width, relatedBy: .equal, toItem: botControlView, attribute: .height, multiplier: 1, constant: 0)
		botControlView.addConstraints([fleft, ftop, fbot, fwidth])

		let sleft = NSLayoutConstraint.init(item: slider, attribute: .left, relatedBy: .equal, toItem: playBt, attribute: .right, multiplier: 1, constant: 10)
		let sright = NSLayoutConstraint.init(item: slider, attribute: .right, relatedBy: .equal, toItem: fullScreenBt, attribute: .left, multiplier: 1, constant: -10)
		let scenter = NSLayoutConstraint.init(item: slider, attribute: .centerY, relatedBy: .equal, toItem: botControlView, attribute: .centerY, multiplier: 1, constant: 0)
		botControlView.addConstraints([sleft, sright, scenter])

		let pleft = NSLayoutConstraint.init(item: progress, attribute: .left, relatedBy: .equal, toItem: playBt, attribute: .right, multiplier: 1, constant: 10)
		let pright = NSLayoutConstraint.init(item: progress, attribute: .right, relatedBy: .equal, toItem: fullScreenBt, attribute: .left, multiplier: 1, constant: -10)
		let pcenter = NSLayoutConstraint.init(item: progress, attribute: .centerY, relatedBy: .equal, toItem: botControlView, attribute: .centerY, multiplier: 1, constant: 0)
		botControlView.addConstraints([pleft, pright, pcenter])

		addAttribute()
		addTap()
		fullScreenBt.setTitle("全屏", for: .normal)
		playBt.setTitleColor(UIColor.blue, for: .normal)
		playBt.setTitle("Play", for: .normal)
		playBt.titleLabel?.font = UIFont.systemFont(ofSize: 15)
//		playBt.backgroundColor = UIColor.red
//		progress.backgroundColor = UIColor.green
//		progress.backgroundColor = UIColor.red
	}

	private func addAttribute() {
		botControlView.backgroundColor = UIColor.black

		progress.progressViewStyle = .default
		progress.progress = 0.01
		progress.progressTintColor = UIColor.orange
		progress.trackTintColor = UIColor.lightText

		slider.minimumValue = 0.0
		slider.maximumValue = 100.0
		slider.minimumTrackTintColor = UIColor.clear
		slider.maximumTrackTintColor = UIColor.clear
		slider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)

		playBt.addTarget(self, action: #selector(playBtAction(sender:)), for: .touchUpInside)

		fullScreenBt.addTarget(self, action: #selector(fullScreenAction(sender:)), for: .touchUpInside)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	open func updateProgress(value: Float) {
		progress.setProgress(value, animated: true)
	}

	open func updateSlider(value: Float) {
		slider.setValue(value, animated: true)
	}

	open func updatePlayStatus(isPlay: Bool) {
		if isPlay {
			playBt.tag = 3300
//			playBt.backgroundColor = UIColor.black
			playBt.setTitle("Pause", for: .normal)
		} else {
			playBt.tag = 3301
			playBt.setTitle("Play", for: .normal)
//			playBt.backgroundColor = UIColor.red
		}
	}

	@objc func sliderValueChanged(sender: UISlider) {
//		print("slider value changed \(sender.value)")
		self.delegate?.sliderValueChanged(value: sender.value)
	}

	@objc func playBtAction(sender: UIButton) {
		if sender.tag == 3301 {
			self.delegate?.playAction()
			sender.tag = 3300
//			playBt.backgroundColor = UIColor.black
			playBt.setTitle("Pause", for: .normal)
		} else {
			self.delegate?.pauseAction()
			sender.tag = 3301
			playBt.setTitle("Play", for: .normal)
//			playBt.backgroundColor = UIColor.red
		}
	}

	@objc func fullScreenAction(sender: UIButton) {
		self.delegate?.fullSreenAction(isFullScreen: self.isFullScreen)
	}

	func hideControlViewAuto() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0) {
			self.botControlView.isHidden = true
		}
		print("等待隐藏控制器")
	}

	func addTap() {
		let tap = UITapGestureRecognizer.init(target: self, action: #selector(controlViewTapAction(gesture:)))
		self.addGestureRecognizer(tap)
	}

	@objc func controlViewTapAction(gesture: UITapGestureRecognizer) {

		UIView.animate(withDuration: 0.5) {
			self.botControlView.isHidden = !self.botControlView.isHidden
		}
		hideControlViewAuto()

	}


}
