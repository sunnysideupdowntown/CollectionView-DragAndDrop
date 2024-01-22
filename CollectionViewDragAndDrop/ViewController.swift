//
//  ViewController.swift
//  CollectionViewDragAndDrop
//
//  Created by YOUNGSUN on 1/22/24.
//

import UIKit

class ViewController: UIViewController {
    
    private var colors: [UIColor] = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemIndigo, .systemPurple]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCollectionView()
    }
    
    private func addCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 200, height: 100)
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        
        collectionView.dropDelegate = self
        
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

// MARK: - CollectionView

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = self.colors[indexPath.item]
        return cell
    }
}

// MARK: - UICollectionViewDragDelegate

extension ViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider()
        let dragItem = UIDragItem(itemProvider: itemProvider)
        
        dragItem.previewProvider = {
            let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 100)))
            label.backgroundColor = self.colors[indexPath.item]
            label.text = "Drag~!"
            label.textAlignment = .center
            return UIDragPreview(view: label)
        }
        
        return [dragItem]
    }
}

// MARK: - UICollectionViewDropDelegate

extension ViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        if let item = coordinator.items.first,
           let srcIndexPath = item.sourceIndexPath,
           let destIndexPath = coordinator.destinationIndexPath {
            
            // Data update
            //
            if srcIndexPath.item < destIndexPath.item {
                self.colors.move(fromOffsets: [srcIndexPath.item], toOffset: destIndexPath.item + 1)
            } else {
                self.colors.move(fromOffsets: [srcIndexPath.item], toOffset: destIndexPath.item)
            }
            
            // UI update
            //
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: [srcIndexPath])
                collectionView.insertItems(at: [destIndexPath])
            }
        }
    }
}
