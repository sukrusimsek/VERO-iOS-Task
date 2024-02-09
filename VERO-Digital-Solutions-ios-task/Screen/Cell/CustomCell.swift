//
//  CustomCell.swift
//  VERO-Digital-Solutions-ios-task
//
//  Created by Şükrü Şimşek on 8.02.2024.
//

import UIKit

class CustomCell: UITableViewCell {

    private let taskLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    private let titleLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    private let descriptionLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .lightGray
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    private let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    private let colorViewVertical: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        contentView.addSubview(taskLbl)
        contentView.addSubview(titleLbl)
        contentView.addSubview(descriptionLbl)
        contentView.addSubview(colorView)
        contentView.addSubview(colorViewVertical)
    }
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            taskLbl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            taskLbl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            taskLbl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 16),
            titleLbl.leadingAnchor.constraint(equalTo: taskLbl.leadingAnchor),
            titleLbl.topAnchor.constraint(equalTo: taskLbl.bottomAnchor, constant: 10),
            descriptionLbl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            descriptionLbl.leadingAnchor.constraint(equalTo: titleLbl.leadingAnchor),
            descriptionLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 10),
            descriptionLbl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorView.heightAnchor.constraint(equalToConstant: contentView.frame.size.height/4),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: 2),
            colorView.widthAnchor.constraint(equalToConstant: contentView.frame.size.width),
            colorViewVertical.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorViewVertical.bottomAnchor.constraint(equalTo: descriptionLbl.bottomAnchor),
            colorViewVertical.widthAnchor.constraint(equalToConstant: contentView.frame.size.height/4),
            colorViewVertical.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
        ])
    }
    
    func cellSetup(_ task: Model ) {
        taskLbl.text = task.task
        titleLbl.text = task.title
        descriptionLbl.text = task.description
        if let colorCode = task.colorCode {
            colorView.backgroundColor = UIColor(hex: colorCode)
            colorViewVertical.backgroundColor = UIColor(hex: colorCode)
        }
        

        
    }

}
