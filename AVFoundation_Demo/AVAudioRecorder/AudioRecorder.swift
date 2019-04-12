//
//  AudioRecorder.swift
//  AVFoundation_Demo
//
//  Created by wheng on 2019/4/8.
//  Copyright © 2019年 wheng. All rights reserved.
//

import AVFoundation

class AudioRecorder {

	private var recorder: AVAudioRecorder!

	open var audioPath: String?

	init() {

		setAudioSession()

		///  存储路径
		audioPath = YTSandboxPath.yt_cachesByAppendPath(component:  String(Int(Date.init().timeIntervalSince1970 * 1000)) + ".caf")

		let url = URL.init(fileURLWithPath: audioPath!)


		let recorderConfig = [AVFormatIDKey: NSNumber.init(value: kAudioFormatLinearPCM),	// 录音格式
							  AVSampleRateKey: NSNumber.init(value: 11025.0),		//采样率
							  AVNumberOfChannelsKey: NSNumber.init(value: 1),		//设置通道(2双声道)
							  AVLinearPCMBitDepthKey: NSNumber.init(value: 8),	//每个采样点位数
							  AVLinearPCMIsFloatKey: NSNumber.init(value: true),	//使用浮点数采样
							  AVEncoderAudioQualityKey: NSNumber.init(value: AVAudioQuality.min.rawValue)] as [String : Any]

		do {
			recorder = try AVAudioRecorder.init(url: url, settings: recorderConfig)
		} catch (let err) {
			print(err.localizedDescription)
		}

		/// 监控声波
		recorder.isMeteringEnabled = true

		recorder.prepareToRecord()
	}

	/// 开始录音
	open func start() {
		recorder.record()
	}

	/// 结束录音
	open func finished() {
		recorder.stop()
	}


}

extension AudioRecorder {
	/// 设置音频会话
	fileprivate func setAudioSession() {
		do {
			try 	AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .allowAirPlay)
			try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
		} catch (let err) {
			print(err.localizedDescription)
		}

	}
}
