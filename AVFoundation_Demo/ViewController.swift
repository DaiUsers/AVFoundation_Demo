//
//  ViewController.swift
//  AVFoundation_Demo
//
//  Created by wheng on 2019/4/8.
//  Copyright © 2019年 wheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	let dataSource: [String] = ["AVAudioRecorder 录音功能"]

	let Identify = "AVFoundationI"

	lazy var tableview: UITableView = {
		let t = UITableView.init(frame: self.view.bounds, style: .plain)
		return t
	}()


	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.navigationItem.title = "AVFoundation"

		view.addSubview(self.tableview)

		tableview.delegate = self
		tableview.dataSource = self

		tableview.tableFooterView = UIView.init()

		tableview.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: Identify)
	}


}

extension ViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		self.navigationController?.pushViewController(AudioRecorderController(), animated: true)
	}
}

extension ViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableview.dequeueReusableCell(withIdentifier: Identify, for: indexPath)
		cell.textLabel?.text = dataSource[indexPath.row]
		return cell
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource.count
	}
}
