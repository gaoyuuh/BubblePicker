# BubblePicker
BubblePicker with SpriteKit

本项目高仿【牵手】app 选择理想型标签动画效果，仅供学习参考！！！

![demo](https://github.com/gaoyuuh/BubblePicker/blob/main/Images/demo.gif)

### 用法：

1. 安装

   ```
   pod 'SpriteBubblePicker'
   ```

2. 首次添加数据

   ```
     /// 首次添加
     public func addWithArray(_ array: [String]) {
   
         var nodes = [BubblePickerNode]()
         for (_, content) in array.enumerated() {
             let node = self.getNode(title: content)
             nodes.append(node)
         }
         self.bubbleScene.showToCenter(nodes: nodes)
     }
   ```

3. 插入数据

   ```
     /// 插入
     public func insertFromArray(_ array: [String], node: BubblePickerNode) {
   
         var nodes = [BubblePickerNode]()
         for (_, item) in array.enumerated() {
             let insertNode = self.getNode(title: item)
             nodes.append(insertNode)
         }
         // 添加 nodes 到 node 四周
         self.bubbleScene.insert(nodes: nodes, atNode: node)
     }
   ```

   可直接使用 `self.bubbleScene.insert(nodes: nodes, atNode: node)` 使用默认插入动画、也可参照`BubblePickerScene.insert()`方法自己实现动画效果

4. 删除数据

   ```
   self.bubbleScene.remove(nodes: removeNodes, atNode: node)
   ```

​		若传 atNode，删除后周围 node 则向 atNode 聚拢

5. BubblePickerDelegate

   ```
   @objc public protocol BubblePickerDelegate: AnyObject {
   
       func didSelect(_ scene: BubblePickerScene, node: BubblePickerNode)
       
       func didDeselect(_ scene: BubblePickerScene, node: BubblePickerNode)
       
   }
   ```

   

### 参考：

- https://github.com/efremidze/Magnetic

### 类似效果：

#### iOS：

- https://github.com/Ronnel/BubblePicker

#### Android：

- https://github.com/igalata/Bubble-Picker

### 已知 App 类似效果：

- 牵手
- 积目
- 流利说
