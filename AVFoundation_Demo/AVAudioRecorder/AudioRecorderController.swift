//
//  AudioRecorderController.swift
//  AVFoundation_Demo
//
//  Created by wheng on 2019/4/8.
//  Copyright © 2019年 wheng. All rights reserved.
//

import UIKit

class AudioRecorderController: UIViewController {

	var recorder: AudioRecorder?

	lazy var tableview: UITableView = {
		return UITableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300), style: .plain)
	}()

	var dataSource: [String] = [String]()

	let Identify = "IdentifyRcorder"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.view.backgroundColor = .white

		setupRecordBt()
		view.addSubview(self.tableview)

		tableview.dataSource = self
		tableview.delegate = self
		tableview.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: Identify)

		//
		getAllAudioFiles()
    }
    

	private var recordBt: UIButton = UIButton.init()

	private func setupRecordBt() {
		recordBt.frame = CGRect.init(x: UIScreen.main.bounds.size.width / 2 - 50, y: UIScreen.main.bounds.size.height - 300, width: 100, height: 100)
		recordBt.backgroundColor = UIColor.red
		recordBt.addTarget(self, action: #selector(recorderAction(sender:)), for: .touchUpInside)
		recordBt.setTitle("开始", for: .normal)
		recordBt.setTitleColor(.white, for: .normal)
		recordBt.tag = 100
		view.addSubview(recordBt)
	}

	@objc func recorderAction(sender: UIButton) {
		if sender.tag == 100 {
			/// 开始录音
			sender.tag = 101
			sender.backgroundColor = UIColor.cyan
			recorder = AudioRecorder.init()
			recordBt.setTitle("结束", for: .normal)
			recordBt.setTitleColor(.white, for: .normal)
			recorder?.start()
		} else {
			/// 结束录音
			recorder?.finished()
			let path = recorder?.audioPath?.split(separator: "/").last ?? ""
			recorder = nil
			recordBt.setTitle("开始", for: .normal)
			recordBt.setTitleColor(.white, for: .normal)
			recordBt.tag = 100
			sender.backgroundColor = .red

			if path.isEmpty {
				return
			}
			dataSource.append(String(path))
			self.tableview.reloadData()
		}
	}

	/// 获取所有缓存音频
	private func getAllAudioFiles() {
		guard let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
			return
		}

		guard let dirEnumerator = FileManager.default.enumerator(atPath: cacheDir) else {
			return
		}

		repeat {
			if let file = dirEnumerator.nextObject() as? String {
				if file.hasSuffix(".caf") {
					dataSource.append(file)
				}
			} else {
				break
			}
		} while true

		tableview.reloadData()
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AudioRecorderController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		if let path = YTSandboxPath.yt_cachesByAppendPath(component: dataSource[indexPath.row]) {
			print(path)
			let player = AudioPlayer.init(path: path)
			player.play()
		}
	}
}

extension AudioRecorderController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableview.dequeueReusableCell(withIdentifier: Identify, for: indexPath)
		cell.textLabel?.text = dataSource[indexPath.row]
		return cell
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource.count
	}
}
