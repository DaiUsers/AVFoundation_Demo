//
//  LameTool.swift
//  AVFoundation_Demo
//
//  Created by wheng on 2019/4/8.
//  Copyright © 2019年 wheng. All rights reserved.
//

import Foundation

class LameTool {
	func audioToMP3(path: String, isDeleteSourceFile: Bool = true) -> String {
		guard FileManager.default.fileExists(atPath: path) else {
			print("Lame transform format .源文件不存在")
			return ""
		}
	}
}
