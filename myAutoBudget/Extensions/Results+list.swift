//
//  Results+list.swift
//  myAutoBudget
//
//  Created by MacBook on 02.01.2022.
//

import RealmSwift

extension Results {
  var list: List<Element> {
    reduce(.init()) { list, element in
      list.append(element)
      return list
    }
  }
}
