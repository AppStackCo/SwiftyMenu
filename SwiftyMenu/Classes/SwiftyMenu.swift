//
//  SwiftyMenu.swift
//  SwiftyMenu
//
//  Created by Karim Ebrahem on 4/17/19.
//  Copyright © 2019 Karim Ebrahem. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

public class SwiftyMenu: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    // MARK: - Public Properties
    
    public var selectedIndex: Int? {
        didSet {
            setSingleSelectedOption()
        }
    }
    public var selectedIndecis: [Int: Int] = [:] {
        didSet {
            setMultiSelectedOptions()
        }
    }
    public var items = [SwiftyMenuDisplayable]() {
        didSet {
            self.optionsTableView.reloadData()
        }
    }
    public weak var delegate: SwiftyMenuDelegate?
    
    // MARK: - Public Callbacks
    
    /// `willExpand` is completion closure that will be executed when `SwiftyMenu` is going to expand.
    public var willExpand: (() -> Void) = { }
    
    /// `didExpand` is completion closure that will be executed once `SwiftyMenu` expanded.
    public var didExpand: (() -> Void) = { }
    
    /// `willCollapse` is completion closure that will be executed when `SwiftyMenu` is going to collapse.
    public var willCollapse: (() -> Void) = { }
    
    /// `didCollapse` is completion closure that will be executed once `SwiftyMenu` collapsed.
    public var didCollapse: (() -> Void) = { }
    
    /// `didSelectItem` is completion closure that will be executed when select an item from `SwiftyMenu`.
    /// - Parameters:
    ///   - swiftyMenu: The `SwiftyMenu` that was selected from it's items.
    ///   - item: The `Item` that had been selected from `SwiftyMenu`.
    ///   - index: The `Index` of the selected `Item`.
    public var didSelectItem: ((_ swiftyMenu: SwiftyMenu,_ item: SwiftyMenuDisplayable,_ index: Int) -> Void) = { _, _, _ in }
    
    private var selectButton: UIButton!
    private var optionsTableView: UITableView!
    private var state: MenuState = .hidden
    private enum MenuState {
        case shown
        case hidden
    }
    private var width: CGFloat!
    private var height: CGFloat!

    private var updateHeightConstraint: () -> () = { }
    private var didSelectCompletion: (SwiftyMenuDisplayable, Int) -> () = { selectedText, index in }
    private var TableWillAppearCompletion: () -> () = { }
    private var TableDidAppearCompletion: () -> () = { }
    private var TableWillDisappearCompletion: () -> () = { }
    private var TableDidDisappearCompletion: () -> () = { }

    // MARK: - IBInspectable
    
    /// Determine if Menu is multi selection or single selection
    @IBInspectable public var isMultiSelect: Bool = false
    
    /// Determine if Menu will hide after selection or not
    @IBInspectable public var hideOptionsWhenSelect: Bool = false
    
    /// Determine if Menu will scroll or not
    @IBInspectable public var scrollingEnabled: Bool = true {
        didSet {
            optionsTableView.isScrollEnabled = scrollingEnabled
        }
    }
    
    /// Determine Menu row height
    @IBInspectable public var rowHeight: Double = 35
    
    /// Determine Menu header background color
    @IBInspectable public var menuHeaderBackgroundColor: UIColor = .white {
        didSet {
            selectButton.backgroundColor = menuHeaderBackgroundColor
        }
    }
    
    /// Determine Menu row background color
    @IBInspectable public var rowBackgroundColor: UIColor = .white
    
    /// Determine Menu selected row background color
    @IBInspectable public var selectedRowColor: UIColor?
    
    /// Determine Menu option text color
    @IBInspectable public var optionColor: UIColor = UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)
    
    /// Determine Menu placeholder text color
    @IBInspectable public var placeHolderColor: UIColor = UIColor(red: 149.0/255.0, green: 149.0/255.0, blue: 149.0/255.0, alpha: 1.0) {
        didSet {
            selectButton.setTitleColor(placeHolderColor, for: .normal)
        }
    }
    
    /// Determine default Menu placeholder text
    @IBInspectable public var placeHolderText: String? {
        didSet {
            UIView.performWithoutAnimation {
                selectButton.setTitle(placeHolderText, for: .normal)
                selectButton.layoutIfNeeded()
            }
        }
    }
    
    /// Determine arrow image for Menu item
    @IBInspectable public var arrow: UIImage? {
        didSet {
            selectButton.setImage(arrow, for: .normal)
        }
    }
    
    /// Determine title left inset for Menu item
    @IBInspectable public var titleLeftInset: Int = 0 {
        didSet {
            selectButton.titleEdgeInsets.left = CGFloat(titleLeftInset)
        }
    }
    
    /// Determine border color for Menu item
    @IBInspectable public var borderColor: UIColor =  UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    /// Determine menu height
    @IBInspectable public var listHeight: Int = 0
    
    /// Determine border color for Menu
    @IBInspectable public var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    /// Determine corner radius for Menu
    @IBInspectable public var cornerRadius: CGFloat = 8.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    /// Determine expanding duration for Menu
    @IBInspectable public var expandingDuration: Double = 0.5
    
    /// Determine collapsing duration for Menu
    @IBInspectable public var collapsingDuration: Double = 0.5
    
    /// Determine expanding delay for Menu
    @IBInspectable public var expandingDelay: Double = 0.0
    
    /// Determine collapsing delay for Menu
    @IBInspectable public var collapsingDelay: Double = 0.0
    
    /// Determine expanding animation style for Menu
    public var expandingAnimationStyle: AnimationStyle = .linear
    
    /// Determine collapsing animation style for Menu
    public var collapsingAnimationStyle: AnimationStyle = .linear
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupUI()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        setupArrowImage()
    }
    
    private func setupUI () {
        setupView()
        getViewWidth()
        getViewHeight()
        setupSelectButton()
        setupDataTableView()
    }
    
    private func setupArrowImage() {
        let spacing = self.selectButton.frame.width - 20 // the amount of spacing to appear between image and title
        selectButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: CGFloat(spacing), bottom: 0, right: 0)
    }
    
    private func setupView() {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }
    
    private func getViewWidth() {
        width = self.frame.width
    }
    
    private func getViewHeight() {
        height = self.frame.height
    }
    
    private func setupSelectButton() {
        selectButton = UIButton(frame: self.frame)
        self.addSubview(selectButton)
        
        selectButton.snp.makeConstraints { maker in
            maker.leading.trailing.top.equalTo(self)
            maker.height.equalTo(height)
        }
        
        let color = placeHolderColor
        selectButton.setTitleColor(color, for: .normal)
        UIView.performWithoutAnimation {
            selectButton.setTitle(placeHolderText, for: .normal)
            selectButton.layoutIfNeeded()
        }
        selectButton.titleLabel?.lineBreakMode = .byTruncatingTail
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        selectButton.imageEdgeInsets.left = width - 16
        selectButton.titleEdgeInsets.right = 16
        selectButton.backgroundColor = menuHeaderBackgroundColor
        
        let frameworkBundle = Bundle(for: SwiftyMenu.self)
        let image = UIImage(named: "downArrow", in: frameworkBundle, compatibleWith: nil)
        arrow = image
        
        if arrow == nil {
            selectButton.titleEdgeInsets.left = 16
        }
        
        if #available(iOS 11.0, *) {
            selectButton.contentHorizontalAlignment = .leading
        } else {
            selectButton.contentHorizontalAlignment = .left
        }
        
        selectButton.addTarget(self, action: #selector(handleMenuState), for: .touchUpInside)
    }
    
    private func setupDataTableView() {
        optionsTableView = UITableView()
        self.addSubview(optionsTableView)
        
        optionsTableView.snp.makeConstraints { maker in
            maker.leading.trailing.bottom.equalTo(self)
            maker.top.equalTo(selectButton.snp_bottom)
        }
        
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        optionsTableView.rowHeight = CGFloat(rowHeight)
        optionsTableView.separatorInset.left = 8
        optionsTableView.separatorInset.right = 8
        optionsTableView.backgroundColor = rowBackgroundColor
        optionsTableView.isScrollEnabled = scrollingEnabled
        optionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "OptionCell")
    }
    
    @objc private func handleMenuState() {
        switch self.state {
        case .shown:
            collapseMenu()
        case .hidden:
            expandMenu()
        }
    }
    
}

// MARK: - UITableViewDataSource

extension SwiftyMenu: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if isMultiSelect {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
            cell.textLabel?.text = items[indexPath.row].displayableValue
            cell.textLabel?.textColor = optionColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            cell.tintColor = optionColor
            cell.backgroundColor = rowBackgroundColor
            cell.accessoryType = selectedIndecis[indexPath.row] != nil ? .checkmark : .none
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
            cell.textLabel?.text = items[indexPath.row].displayableValue
            cell.textLabel?.textColor = optionColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            cell.tintColor = optionColor
            cell.backgroundColor = rowBackgroundColor
            cell.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
            cell.selectionStyle = .none
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension SwiftyMenu: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(rowHeight)
    }
    
    fileprivate func setMultiSelectedOptions() {
        let titles = selectedIndecis.mapValues { (index) -> String in
            return items[index].displayableValue
        }
        var selectedTitle = ""
        selectedTitle = titles.values.joined(separator: ", ")
        UIView.performWithoutAnimation {
            selectButton.setTitle(selectedTitle, for: .normal)
            selectButton.layoutIfNeeded()
        }
        selectButton.setTitleColor(optionColor, for: .normal)
    }
    
    fileprivate func setSingleSelectedOption() {
        UIView.performWithoutAnimation {
            selectButton.setTitle(items[selectedIndex!].displayableValue, for: .normal)
            selectButton.layoutIfNeeded()
        }
        selectButton.setTitleColor(optionColor, for: .normal)
    }
    
    fileprivate func setPlaceholder() {
        UIView.performWithoutAnimation {
            selectButton.setTitle(placeHolderText, for: .normal)
            selectButton.layoutIfNeeded()
        }
        selectButton.setTitleColor(placeHolderColor, for: .normal)
    }
    
    private func setSelectedOptionsAsTitle() {
        if isMultiSelect {
            if selectedIndecis.isEmpty {
                setPlaceholder()
            } else {
                setMultiSelectedOptions()
            }
        } else {
            if selectedIndex == nil {
                setPlaceholder()
            } else {
                setSingleSelectedOption()
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if isMultiSelect {
            if selectedIndecis[indexPath.row] != nil {
                selectedIndecis[indexPath.row] = nil
                setSelectedOptionsAsTitle()
                tableView.reloadData()
                if hideOptionsWhenSelect {
                    collapseMenu()
                }
            } else {
                selectedIndecis[indexPath.row] = indexPath.row
                setSelectedOptionsAsTitle()
                let selectedText = self.items[selectedIndecis[indexPath.row]!]
                delegate?.swiftyMenu(self, didSelectItem: selectedText, atIndex: indexPath.row)
                self.didSelectItem(self, selectedText, indexPath.row)
                tableView.reloadData()
                if hideOptionsWhenSelect {
                    collapseMenu()
                }
            }
        } else {
            if selectedIndex == indexPath.row {
                if hideOptionsWhenSelect {
                    collapseMenu()
                }
            } else {
                selectedIndex = indexPath.row
                setSelectedOptionsAsTitle()
                let selectedText = self.items[self.selectedIndex!]
                delegate?.swiftyMenu(self, didSelectItem: selectedText, atIndex: indexPath.row)
                self.didSelectItem(self, selectedText, indexPath.row)
                tableView.reloadData()
                if hideOptionsWhenSelect {
                    collapseMenu()
                }
            }
        }
    }
}

// MARK: - Private Functions

extension SwiftyMenu {
    private func expandMenu() {
        delegate?.swiftyMenu(willExpand: self)
        self.willExpand()
        self.state = .shown
        heightConstraint.constant = listHeight == 0 || !scrollingEnabled || (CGFloat(rowHeight * Double(items.count + 1)) < CGFloat(listHeight)) ? CGFloat(rowHeight * Double(items.count + 1)) : CGFloat(listHeight)
        
        switch expandingAnimationStyle {
        case .linear:
            UIView.animate(withDuration: expandingDuration,
                           delay: expandingDelay,
                           animations: animationBlock,
                           completion: expandingAnimationCompletionBlock)
            
        case .spring(level: let powerLevel):
            let damping = CGFloat(0.5 / powerLevel.rawValue)
            let initialVelocity = CGFloat(0.5 * powerLevel.rawValue)
            
            UIView.animate(withDuration: expandingDuration,
                           delay: expandingDelay,
                           usingSpringWithDamping: damping,
                           initialSpringVelocity: initialVelocity,
                           options: [],
                           animations: animationBlock,
                           completion: expandingAnimationCompletionBlock)
        }
    }
    
    private func collapseMenu() {
        delegate?.swiftyMenu(willCollapse: self)
        self.willCollapse()
        self.state = .hidden
        heightConstraint.constant = CGFloat(rowHeight)
        
        switch collapsingAnimationStyle {
        case .linear:
            UIView.animate(withDuration: collapsingDuration,
                           delay: collapsingDelay,
                           animations: animationBlock,
                           completion: collapsingAnimationCompletionBlock)
            
        case .spring(level: let powerLevel):
            let damping = CGFloat(1.0 * powerLevel.rawValue)
            let initialVelocity = CGFloat(10.0 * powerLevel.rawValue)
            
            UIView.animate(withDuration: collapsingDuration,
                           delay: collapsingDelay,
                           usingSpringWithDamping: damping,
                           initialSpringVelocity: initialVelocity,
                           options: .curveEaseIn,
                           animations: animationBlock,
                           completion: collapsingAnimationCompletionBlock)
        }
        updateHeightConstraint()
    }
}

// MARK: - Delegates

extension SwiftyMenu {
    public func updateConstraints(completion: @escaping () -> ()) {
        updateHeightConstraint = completion
    }
    
    public func didSelectOption(completion: @escaping (_ selected: SwiftyMenuDisplayable, _ index: Int) -> ()) {
        didSelectCompletion = completion
    }
    
    public func menuWillAppear(completion: @escaping () -> ()) {
        TableWillAppearCompletion = completion
    }
    
    private func animationBlock() {
        self.parentViewController.view.layoutIfNeeded()
    }
    
    private func expandingAnimationCompletionBlock(didAppeared: Bool) {
        if didAppeared {
            self.delegate?.swiftyMenu(didExpand: self)
            self.didExpand()
        }
    }
    
    private func collapsingAnimationCompletionBlock(didAppeared: Bool) {
        if didAppeared {
            self.delegate?.swiftyMenu(didCollapse: self)
            self.didCollapse()
        }
    }
}
