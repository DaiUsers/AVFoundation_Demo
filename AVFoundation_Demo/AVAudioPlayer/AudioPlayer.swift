//
//  AudioPlayer.swift
//  AVFoundation_Demo
//
//  Created by wheng on 2019/4/8.
//  Copyright © 2019年 wheng. All rights reserved.
//

import AVFoundation

class AudioPlayer: NSObject {

	private var audioPlayer: AVAudioPlayer!

	convenience init(path: String) {
		self.init()
		let url = URL.init(fileURLWithPath: path)
		do {
			audioPlayer = try AVAudioPlayer.init(contentsOf: url)
		} catch (let err) {
			print(err.localizedDescription)
		}

		audioPlayer.delegate = self
		audioPlayer.prepareToPlay()
	}

	open func play() {
		print(audioPlayer.duration)
		
		if !audioPlayer.isPlaying {
			audioPlayer.play()
		}
	}

	open func pause() {
		if audioPlayer.isPlaying {
			audioPlayer.pause()
		}
	}

}

extension AudioPlayer: AVAudioPlayerDelegate {
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		print("播放结束..")
	}

	func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
		print(error?.localizedDescription)
	}
}
