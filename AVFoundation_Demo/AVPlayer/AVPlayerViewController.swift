//
//  AVPlayerViewController.swift
//  AVFoundation_Demo
//
//  Created by wheng on 2019/4/10.
//  Copyright © 2019年 wheng. All rights reserved.
//

import UIKit

class AVPlayerViewController: UIViewController {

	var tableview: UITableView!

	let Identity = "AVPlayerCell"

	var player: SSAVPlayerControl!
//	var path =

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.view.backgroundColor = UIColor.white

		self.setTableView()

		let path =  "/Users/ddys/iOSProj/AVFoundation_Demo/AVFoundation_Demo/AVPlayer/101.mp4"//
		var urlPath = "http://183.47.253.148/vcloud1049.tc.qq.com/1049_M0115400003xf2Ly1IPxm41001575852.f20.mp4?vkey=B0411D1F3A278F86C2699B1A66F1839245D1EEBE796D6DD435E45FEFE478237C94400F94412933D16506F037DF53D741232CEAF90ECF24E419B12D6E70499B6EF8D9DCECC5714F0519ECC5851DA13B82627A6631DA348221"
    }

	func updateCell(cell: UITableViewCell, url: URL) {
		if player == nil {
			player = SSAVPlayerControl.init()
			player.url = url
			player.addPlayerView(frame: cell.bounds)
			player.setVideoGravity(mode: .resizeAspect)
			cell.contentView.addSubview(player.playerView!)
//			player.resizePlayer(frame: cell.bounds)
		} else {
			player.playerView?.removeFromSuperview()
			player.replacePlayer(url: url)
			cell.contentView.addSubview(player.playerView!)
			player.resizePlayer(frame: cell.bounds)
		}
	}


	func setTableView() {
		tableview = UITableView.init(frame: self.view.bounds, style: .plain)
		self.view.addSubview(tableview)

		tableview.delegate = self
		tableview.dataSource = self
		tableview.rowHeight = UIScreen.main.bounds.size.width * 9 / 16
		tableview.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: Identity)
		tableview.tableFooterView = UIView.init()
	}

}

extension AVPlayerViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		let cell = tableView.cellForRow(at: indexPath)
		var urlPath = "/Users/ddys/iOSProj/AVFoundation_Demo/AVFoundation_Demo/AVPlayer/101.mp4"
		let url = URL.init(fileURLWithPath: urlPath)
		updateCell(cell: cell!, url: url)
	}
}

extension AVPlayerViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 20
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableview.dequeueReusableCell(withIdentifier: Identity, for: indexPath)
		return cell
	}
}
