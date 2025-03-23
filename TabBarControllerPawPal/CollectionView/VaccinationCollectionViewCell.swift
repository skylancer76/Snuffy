//
//  VaccinationCollectionViewCell.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 23/03/25.
//

import UIKit

class VaccinationCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "VaccinationCollectionViewCell"

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.96, alpha: 1)
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    private let petImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let vaccineNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .black
        return label
    }()

    private let contentStack = UIStackView()
    private let vaccineTypeRow = UIStackView()
    private let dateOfVaccinationRow = UIStackView()
    private let expiryDateRow = UIStackView()
    private let nextDueDateFooter = UIView()

    private let nextDueTitleLabel = UILabel()
    private let nextDueDateLabel = UILabel()
    private let remindButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with vaccination: VaccinationDetails, petImageURL: String?) {
        vaccineNameLabel.text = vaccination.vaccineName
        setupVaccineTypeRow(type: vaccination.vaccineType)
        setupDateRow(stack: dateOfVaccinationRow, title: "Date of Vaccination", date: vaccination.dateOfVaccination, color: .systemGreen)
        setupDateRow(stack: expiryDateRow, title: "Expiry Date", date: vaccination.expiryDate, color: .systemRed)
        nextDueDateLabel.text = vaccination.nextDueDate

        if let urlStr = petImageURL, let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self.petImageView.image = image
                }
            }.resume()
        }
    }

    private func setupLayout() {
        contentView.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // Header
        let headerStack = UIStackView(arrangedSubviews: [petImageView, vaccineNameLabel])
        headerStack.axis = .horizontal
        headerStack.spacing = 16
        headerStack.alignment = .center

        petImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        petImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        vaccineTypeRow.axis = .horizontal
        vaccineTypeRow.spacing = 12
        vaccineTypeRow.alignment = .center

        dateOfVaccinationRow.axis = .horizontal
        dateOfVaccinationRow.spacing = 12
        dateOfVaccinationRow.alignment = .center

        expiryDateRow.axis = .horizontal
        expiryDateRow.spacing = 12
        expiryDateRow.alignment = .center

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(headerStack)
        contentStack.addArrangedSubview(vaccineTypeRow)
        contentStack.addArrangedSubview(dateOfVaccinationRow)
        contentStack.addArrangedSubview(expiryDateRow)

        cardView.addSubview(contentStack)
        cardView.addSubview(nextDueDateFooter)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            nextDueDateFooter.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            nextDueDateFooter.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            nextDueDateFooter.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            nextDueDateFooter.heightAnchor.constraint(equalToConstant: 80)
        ])

        setupNextDueDateFooter()
    }

    private func setupVaccineTypeRow(type: String) {
        vaccineTypeRow.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let iconBG = makeIconBackground()
        let icon = UIImageView(image: UIImage(systemName: "syringe.fill"))
        icon.tintColor = .systemPurple
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        iconBG.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: iconBG.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBG.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20)
        ])

        let title = UILabel()
        title.text = "Vaccine Type:"
        title.font = .systemFont(ofSize: 18)

        let value = UILabel()
        value.text = type
        value.textColor = .systemPurple
        value.font = .systemFont(ofSize: 18)

        let vertical = UIStackView(arrangedSubviews: [title, value])
        vertical.axis = .vertical
        vertical.spacing = 4

        vaccineTypeRow.addArrangedSubview(iconBG)
        vaccineTypeRow.addArrangedSubview(vertical)
    }

    private func setupDateRow(stack: UIStackView, title: String, date: String, color: UIColor) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let iconBG = makeIconBackground()
        let icon = UIImageView(image: UIImage(systemName: "calendar"))
        icon.tintColor = color
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        iconBG.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: iconBG.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBG.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20)
        ])

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18)

        let valueLabel = UILabel()
        valueLabel.text = date
        valueLabel.textColor = color
        valueLabel.font = .boldSystemFont(ofSize: 18)

        let vertical = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        vertical.axis = .vertical
        vertical.spacing = 4

        stack.addArrangedSubview(iconBG)
        stack.addArrangedSubview(vertical)
    }

    private func setupNextDueDateFooter() {
        nextDueDateFooter.backgroundColor = UIColor(red: 1.0, green: 0.89, blue: 0.93, alpha: 1)
        nextDueDateFooter.layer.cornerRadius = 24
        nextDueDateFooter.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        nextDueDateFooter.clipsToBounds = true
        nextDueDateFooter.translatesAutoresizingMaskIntoConstraints = false

        let iconBG = makeIconBackground()
        let icon = UIImageView(image: UIImage(systemName: "calendar"))
        icon.tintColor = .systemYellow
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        iconBG.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: iconBG.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBG.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20)
        ])

        let title = UILabel()
        title.text = "Next Due Date"
        title.font = .systemFont(ofSize: 18)

        nextDueDateLabel.font = .boldSystemFont(ofSize: 18)
        nextDueDateLabel.textColor = .systemYellow

        let labelStack = UIStackView(arrangedSubviews: [title, nextDueDateLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4

        remindButton.setTitle("Remind", for: .normal)
        remindButton.setTitleColor(.systemRed, for: .normal)
        remindButton.backgroundColor = .white
        remindButton.layer.cornerRadius = 16
        remindButton.titleLabel?.font = .systemFont(ofSize: 14)
        remindButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        remindButton.translatesAutoresizingMaskIntoConstraints = false

        let rowStack = UIStackView(arrangedSubviews: [iconBG, labelStack])
        rowStack.axis = .horizontal
        rowStack.spacing = 12
        rowStack.alignment = .center
        rowStack.translatesAutoresizingMaskIntoConstraints = false

        nextDueDateFooter.addSubview(rowStack)
        nextDueDateFooter.addSubview(remindButton)

        NSLayoutConstraint.activate([
            rowStack.leadingAnchor.constraint(equalTo: nextDueDateFooter.leadingAnchor, constant: 20),
            rowStack.centerYAnchor.constraint(equalTo: nextDueDateFooter.centerYAnchor),

            remindButton.trailingAnchor.constraint(equalTo: nextDueDateFooter.trailingAnchor, constant: -20),
            remindButton.centerYAnchor.constraint(equalTo: nextDueDateFooter.centerYAnchor)
        ])
    }

    private func makeIconBackground() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 40).isActive = true
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return view
    }
}
