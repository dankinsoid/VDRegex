//
//  File.swift
//  
//
//  Created by Данил Войдилов on 12.12.2021.
//

import Foundation

struct RegexString: RegexType {
	var pattern: String
	
	init(pattern: String, index: inout String) throws {
		self.init(pattern)
	}
	
	init(_ pattern: String, index: inout String.Index) {
		var result = ""
		var isShielded = false
		while index < pattern.endIndex, !CharacterSet.regexSpecial.contains(pattern[index]) || isShielded {
			if pattern[index] == "\\", !isShielded {
				result += pattern[index]
				isShielded = true
			} else {
				isShielded = false
				result += pattern[index]
			}
			index = pattern.index(after: index)
		}
		self.pattern = pattern.regexShielding
	}
	
	func scan(string: String, context: inout RegexScanContext) throws {
		var index = context.index
		var i = pattern.startIndex
		while i < pattern.endIndex, index < string.endIndex, compare(string[index], pattern[i], context: context) {
			i = pattern.index(after: i)
			index = string.index(after: index)
		}
		if i < pattern.endIndex, index < string.endIndex {
			throw RegexScanError.notMatch(index)
		} else if i < pattern.endIndex {
			throw RegexScanError.stringTooShort
		}
		context.index = index
	}
}

extension Regex {
	public static func string(_ string: String) -> Regex {
		Regex(regex: RegexString(string))
	}
	
	public func string(_ string: String) -> Regex {
		self + .string(string)
	}
}
