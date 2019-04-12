//
//  SSAVPlayer.swift
//  AVFoundation_Demo
//
//  Created by wheng on 2019/4/8.
//  Copyright © 2019年 wheng. All rights reserved.
//

/// 视频播放状态
enum SSAVPlayerStatus {
	/// 准备好播放
	case readyToPlay
	/// 加载视频
	case loadingVideo
	/// 播放结束
	case playEnd
	/// 缓冲视频
	case cacheData
	/// 缓冲结束
	case cacheEnd
	/// 播放暂停
	case playStop
	/// 视频资源失败
	case itemFailed
	/// 进入后台
	case enterBackground
	/// 从后台返回
	case becomeActive
}

/// 视频播放代理
protocol SSAVPlayerDelegate {
	/// 播放数据刷新(总时长,当前播放时长,缓冲时长)
	func refreshData(totalTime: TimeInterval, currentTime: TimeInterval, cacheTime: TimeInterval) -> Void
	/// 播放状态
	func promptPlayerStatus(status: SSAVPlayerStatus) -> Void

	/// 是否在播放
	func playerIsPlaying(isplay: Bool) -> Void
}

import UIKit
import AVFoundation

class SSAVPlayer: UIView {

	open var delegate: SSAVPlayerDelegate?
	/// 视频总长
	open var totalTime: TimeInterval {
		get {
			return self.player?.currentItem?.duration.seconds ?? -1.0
		}
	}
	/// 缓冲进度
	open var cacheTime: TimeInterval = -1.0
	open var isPlaying: Int {
		get {
			if let player = self.player {
				if player.rate == 1.0 { return 1 }
				else if player.rate == 0.0 { return 0 }
			}
			return -1
		}
	}

	/// 准备播放地址
	open func readyPlayer(url: URL) {
		self.createPlayer(url: url)
		self.play()
		self.deletegateSend(status: .loadingVideo)
	}

	/// 切换视频地址
	open func replacePlayer(url: URL) {
		self.isCanPlay = false
		self.pause()
		self.removeObserver(playerItem: self.playerItem)
		self.playerItem = AVPlayerItem.init(url: url)
		self.addObserver(playerItem: self.playerItem)
		self.player?.replaceCurrentItem(with: self.playerItem)
		self.play()
	}

	/// 模式
	open func setLayerMode(mode: AVLayerVideoGravity) {
		self.playerLayer?.videoGravity = mode
	}

	/// 布局
	open func resizeLayerFrame() {
		self.playerLayer?.frame = self.bounds
	}

	/// 开始播放(avplayer.rate 1.0正在播放, 0.0暂停, -1.0播放失败)
	open func play() {
		guard let player = self.player else {
			return
		}
		if player.rate == 0.0 {
			player.play()
			self.delegate?.playerIsPlaying(isplay: true)
		}
	}

	/// 暂停
	open func pause() {
		guard let player = self.player else {
			return
		}
		if player.rate == 1.0 {
			player.pause()
			self.delegate?.playerIsPlaying(isplay: false)
		}
	}

	/// 视频跳转到指定时间点
	open func seekPlayerTime(to time: TimeInterval) {
		self.pause()
		self.startToSeek()
		self.player?.seek(to: CMTime.init(seconds: time, preferredTimescale: CMTimeScale(1.0)), completionHandler: { (finished) in
			self.endSeek()
			self.play()
		})
	}

	private func startToSeek() {
		self.isSeeking = true
	}

	private func endSeek() {
		self.isSeeking = false
	}


	private var playerLayer: AVPlayerLayer?
	/// 是否正在跳转(跳转中不监听)
	private var isSeeking: Bool = false
	/// 播放器
	private var player: AVPlayer?
	/// 播放资源
	private var playerItem: AVPlayerItem?
	/// 是否可以播放
	private var isCanPlay: Bool = false
	/// 是否需要缓冲
	private var needBuffer: Bool = false
	/// 播放器监听
	private var timeObser: Any!

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.black
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func createPlayer(url: URL) {
		if player == nil {
			playerItem = AVPlayerItem.init(url: url)
			player = AVPlayer.init(playerItem: playerItem)
			self.createPlayerLayer()
			self.addPlayerObserver()
			self.addObserver(playerItem: self.playerItem)
			self.addPlayerNotication()
		}
	}

	fileprivate func createPlayerLayer() {
		playerLayer = AVPlayerLayer.init(player: self.player)
		playerLayer?.frame = self.bounds
		playerLayer?.videoGravity = .resizeAspect
		self.layer.addSublayer(playerLayer!)
	}

	deinit {
		self.removePlayerNotication()
		self.removePlayerObserver()
		self.removeObserver(playerItem: self.player?.currentItem)
	}
}

extension SSAVPlayer {


	/// 代理发送播放状态
	fileprivate func deletegateSend(status: SSAVPlayerStatus) {
		if !self.isCanPlay {
			return
		}

		self.delegate?.promptPlayerStatus(status: status)
	}

	/// 处理playerItem播放状态
	fileprivate func handleStatus(playerItem: AVPlayerItem) {
		let status = playerItem.status
		switch status {
		case .readyToPlay:
			self.isCanPlay = true
			self.deletegateSend(status: .readyToPlay)
			break
		case .failed:
			self.deletegateSend(status: .itemFailed)
			break
		case .unknown:
			break
		default:
			break
		}
	}

	/// 处理缓冲进度
	fileprivate func handleLoadedTimeRanges(item: AVPlayerItem) {
		let loadArray = item.loadedTimeRanges
		let range = loadArray.first?.timeRangeValue
		guard let start = range?.start.seconds,
			let duration = range?.duration.seconds else {
				return
		}
		let totalTime = TimeInterval.init(exactly: start + duration)
		cacheTime = totalTime ?? -1.0
	}

	/// 添加player监听
	fileprivate func addPlayerObserver() {
		timeObser = self.player?.addPeriodicTimeObserver(forInterval: CMTime.init(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0)), queue: DispatchQueue.main, using: { (time) in
			let playerItem = self.player?.currentItem
			 let current = time.seconds
			guard let total = playerItem?.duration.seconds else { return }
			if self.isSeeking { return }

			self.delegate?.refreshData(totalTime: total, currentTime: current, cacheTime: self.cacheTime)
		})
	}

	/// 移除player监听
	fileprivate func removePlayerObserver() {
		self.player?.removeTimeObserver(timeObser)
	}

	/// 添加playeritem监听
	fileprivate func addObserver(playerItem: AVPlayerItem?) {
		playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
		playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
		playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
		playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
	}

	/// 移除playeritem监听
	fileprivate func removeObserver(playerItem: AVPlayerItem?) {
		playerItem?.removeObserver(self, forKeyPath: "status")
		playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
		playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
		playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard let item = object as? AVPlayerItem, let key = keyPath else { return }

		/// 播放资源状态
		if key == "status" {
			self.handleStatus(playerItem: item)
		} else if key == "loadedTimeRanges" {
			/// 缓冲进度
			self.handleLoadedTimeRanges(item: item)
		} else if key == "playbackBufferEmpty" {
			///  seekToTime后, 缓冲数据为空, 而且有效时间内数据无法补充,播放失败
			if self.isCanPlay {
				self.needBuffer = true
				self.deletegateSend(status: .cacheData)
			}
		} else if key == "playbackLikelyToKeepUp" {
			/// seekToTime后,可以正常播放, 相当于readyToPlay
			if self.isCanPlay && self.needBuffer {
				self.needBuffer = false
				self.deletegateSend(status: .cacheEnd)
			}
		}
	}
}

//MARK: - 添加通知
extension SSAVPlayer {
	fileprivate func addPlayerNotication() {
		/// 播放结束
		NotificationCenter.default.addObserver(self, selector: #selector(playEnd(notication:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
		/// 播放异常中断
		NotificationCenter.default.addObserver(self, selector: #selector(playError(notication:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
		/// 进入后台
		NotificationCenter.default.addObserver(self, selector: #selector(enterBackground(notication:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
		/// 进入前台
		NotificationCenter.default.addObserver(self, selector: #selector(becomeActive(notication:)), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	fileprivate func removePlayerNotication() {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	/// 播放结束
	@objc fileprivate func playEnd(notication: Notification) {
		self.deletegateSend(status: .playEnd)
		self.player?.seek(to: CMTime.zero)
	}

	/// 播放异常中断
	@objc fileprivate func playError(notication: Notification) {
		self.deletegateSend(status: .playStop)
	}

	/// 进入后台
	@objc fileprivate func enterBackground(notication: Notification) {
		self.deletegateSend(status: .enterBackground)
	}

	/// 进入前台
	@objc fileprivate func becomeActive(notication: Notification) {
		self.deletegateSend(status: .becomeActive)
	}
}


