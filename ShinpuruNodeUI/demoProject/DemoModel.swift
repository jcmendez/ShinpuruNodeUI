//
//  DemoModel.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 07/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>

import UIKit

struct DemoModel
{
  var nodes: [DemoNode]
  
  init() 
  {
    let one = DemoNode(name: "One", position: CGPoint(x: 210, y: 10), value: DemoNodeValue.number(1))
    let two = DemoNode(name: "Two", position: CGPoint(x: 220, y: 350), value: DemoNodeValue.number(2))
    let add = DemoNode(name: "Add", position: CGPoint(x: 570, y: 170), type: DemoNodeType.Add, inputs: [one, nil, two])
    
    nodes = [one, two, add]
    
    updateDescendantNodes(one)
    updateDescendantNodes(two)
  }
  
  mutating func toggleRelationship(_ sourceNode: DemoNode, targetNode: DemoNode, targetIndex: Int) -> [DemoNode]
  {
    var ins = targetNode.inputs ?? [DemoNode]()
    
    if targetIndex >= ins.count
    {
      for _ in 0 ... targetIndex - ins.count
      {
        ins.append(nil)
      }
    }
    
    if ins[targetIndex] == sourceNode
    {
      ins[targetIndex] = nil
      
      return updateDescendantNodes(sourceNode.demoNode!, forceNode: targetNode.demoNode!)
    }
    else
    {
      ins[targetIndex] = sourceNode
      
      return updateDescendantNodes(sourceNode.demoNode!)
    }
  }
  
  mutating func deleteNode(_ deletedNode: DemoNode) -> [DemoNode]
  {
    var updatedNodes = [DemoNode]()
    
    for node in nodes where node.inputs != nil && node.inputs!.contains(where: {$0 == deletedNode})
    {
      for (idx, inputNode) in node.inputs!.enumerated() where inputNode == deletedNode
      {
        node.inputs?[idx] = nil
        
        node.recalculate()
        
        updatedNodes.append(contentsOf: updateDescendantNodes(node))
      }
    }
    
    if let deletedNodeIndex = nodes.index(of: deletedNode)
    {
      nodes.remove(at: deletedNodeIndex)
    }
    
    return updatedNodes
  }
  
  mutating func addNodeAt(_ position: CGPoint) -> DemoNode
  {
    let newNode = DemoNode(name: "New!", position: position, value: DemoNodeValue.number(1))
    
    nodes.append(newNode)
    
    return newNode
  }
  
  @discardableResult
  func updateDescendantNodes(_ sourceNode: DemoNode, forceNode: DemoNode? = nil) -> [DemoNode]
  {
    var updatedDatedNodes = [[sourceNode]]
    
    for targetNode in nodes where targetNode != sourceNode
    {
      if let inputs = targetNode.inputs,
        let targetNode = targetNode.demoNode , inputs.contains(where: {$0 == sourceNode}) || targetNode == forceNode
      {
        targetNode.recalculate()
        
        updatedDatedNodes.append(updateDescendantNodes(targetNode))
      }
    }
    
    return Array(Set<DemoNode>(updatedDatedNodes.flatMap{ $0 })) 
  }
  
  static func nodesAreRelationshipCandidates(_ sourceNode: DemoNode, targetNode: DemoNode, targetIndex: Int) -> Bool
  {
    // TODO - prevent circular! recursive function 
    
    if sourceNode.isAscendant(targetNode) || sourceNode == targetNode
    {
      return false
    }
    
    return sourceNode.value?.typeName == targetNode.type.inputSlots[targetIndex].type.typeName
  }
}
