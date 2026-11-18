//
//  AddMatterViewController.swift
//  TuPassou?
//
//  Created by Bianca Moura on 12/11/26.
//

import UIKit
import SwiftData

class AddMatterViewController: UIViewController {
    
    private let modelContext: ModelContext
    private let onAdd: () -> Void
    
    private var matterToEdit: Matter?
    
    private let emojiButton = UIButton(type: .system)
    private var selectedEmoji: String = "📚"
    
    private let classeName = UITextField()
    private let courseName = UITextField()
    private var gradeField: [UITextField] = []
    private let calcPicker = UISegmentedControl(items: ["Padrão IF", "Personalizado..."])
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    init(modelContext: ModelContext, matterToEdit: Matter? = nil, onAdd: @escaping () -> Void) {
        self.modelContext = modelContext
        self.matterToEdit = matterToEdit
        self.onAdd = onAdd
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        
        // O título muda dinamicamente!
        navigationItem.title = matterToEdit == nil ? "Nova Cadeira" : "Editar Cadeira"
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "checkmark"),
            style: .prominent,
            target: self,
            action: #selector(addCourse)
        )
//        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 160/255, green: 210/255, blue: 160/255, alpha: 1.0)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.keyboardDismissMode = .onDrag
        
        NotificationCenter.default.addObserver(self, selector: #selector(tecladoSurgiu), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tecladoSumiu), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        classeName.placeholder = "Cálculo II..."
        courseName.placeholder = "Engenharia de Computação..."
        
        if let cadeiraExistente = matterToEdit {
            classeName.text = cadeiraExistente.classe
            courseName.text = cadeiraExistente.course
            selectedEmoji = cadeiraExistente.emoji
            calcPicker.selectedSegmentIndex = cadeiraExistente.typeCalc == "Padrão IF" ? 0 : 1
            
            for (index, nota) in cadeiraExistente.grade.enumerated() {
                let gradeTF = UITextField()
                gradeTF.placeholder = "Nota \(index + 1)"
                gradeTF.keyboardType = .decimalPad
                
                let stringNota = String(nota)
                gradeTF.text = stringNota.hasSuffix(".0") ? String(Int(nota)) : stringNota.replacingOccurrences(of: ".", with: ",")
                
                gradeField.append(gradeTF)
            }
            
            while gradeField.count < 4 {
                addGrade()
            }
            
        } else {
            calcPicker.selectedSegmentIndex = 0
            for _ in 0..<4 {
                addGrade()
            }
        }
        
        setupHeaderEmojiView()
    }
    
        @objc private func tecladoSurgiu(notification: NSNotification) {
            if let infoTeclado = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let alturaTeclado = infoTeclado.cgRectValue.height
                
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: alturaTeclado + 20, right: 0)
                tableView.scrollIndicatorInsets = tableView.contentInset
            }
        }
        
        @objc private func tecladoSumiu(notification: NSNotification) {
            tableView.contentInset = .zero
            tableView.scrollIndicatorInsets = .zero
        }
    
    private func setupHeaderEmojiView() {
        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 130))
        
        emojiButton.setTitle(selectedEmoji, for: .normal)
        emojiButton.titleLabel?.font = .systemFont(ofSize: 48)
        emojiButton.backgroundColor = .systemGray5
        emojiButton.layer.borderWidth = 0
        emojiButton.layer.cornerRadius = 45
        emojiButton.clipsToBounds = true
        emojiButton.translatesAutoresizingMaskIntoConstraints = false
        
        emojiButton.addAction(UIAction { [weak self] _ in
            self?.tocarParaTrocarEmoji()
        }, for: .touchUpInside)
        
        headerContainer.addSubview(emojiButton)
        
        NSLayoutConstraint.activate([
            emojiButton.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            emojiButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            emojiButton.widthAnchor.constraint(equalToConstant: 90),
            emojiButton.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        tableView.tableHeaderView = headerContainer
    }
    
    private func tocarParaTrocarEmoji() {
        let emojis = ["📚", "📐", "💻", "⚡", "🧪", "⚙️", "📊", "🧠"]
        if let currentIndex = emojis.firstIndex(of: selectedEmoji) {
            let nextIndex = (currentIndex + 1) % emojis.count
            selectedEmoji = emojis[nextIndex]
        } else {
            selectedEmoji = "📚"
        }
        emojiButton.setTitle(selectedEmoji, for: .normal)
    }
    
    private func addGrade() {
        let gradeTF = UITextField()
        gradeTF.placeholder = "Nota \(gradeField.count + 1)"
        gradeTF.keyboardType = .decimalPad
        gradeField.append(gradeTF)
    }
    
    @objc private func addCourse() {
        let name = classeName.text ?? ""
        let course = courseName.text ?? ""
        
        let typeCalc = calcPicker.selectedSegmentIndex == 0 ? "Padrão IF" : "Personalizado..."
        
        var notesFloat: [Float] = []
        
        for camp in gradeField {
            if let words = camp.text, !words.isEmpty {
                let wordWithDot = words.replacingOccurrences(of: ",", with: ".")
                if let note = Float(wordWithDot) {
                    notesFloat.append(note)
                }
            }
        }
        
        if name.isEmpty {
            dismiss(animated: true)
            return
        }
        
        if let cadeiraExistente = matterToEdit {
            cadeiraExistente.classe = name
            cadeiraExistente.course = course
            cadeiraExistente.typeCalc = typeCalc
            cadeiraExistente.grade = notesFloat
            cadeiraExistente.emoji = selectedEmoji
        } else {
            let newMatter = Matter(classe: name, course: course, grade: notesFloat, typeCalc: typeCalc, emoji: selectedEmoji)
            modelContext.insert(newMatter)
        }
        
        onAdd()
        dismiss(animated: true)
    }
}

extension AddMatterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "Cadeira"
            case 1:
                return "Curso"
            case 2:
                return "Notas"
            case 3:
                return "Tipo de Cálculo"
            default:
                return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return gradeField.count + 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        
        if indexPath.section == 2 && indexPath.row == gradeField.count {
            var content = cell.defaultContentConfiguration()
            content.text = "+"
            content.textProperties.color = .systemBlue
            cell.contentConfiguration = content
            cell.selectionStyle = .default
            return cell
        }
        
        if indexPath.section == 3 {
            calcPicker.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(calcPicker)
            
            NSLayoutConstraint.activate([
                calcPicker.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide .leadingAnchor),
                calcPicker.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide .trailingAnchor),
                calcPicker.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                calcPicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
                
            ])
            
            return cell
        }
        
        let textField: UITextField
        switch indexPath.section {
            case 0:
                textField = classeName
            case 1:
                textField = courseName
            case 2:
                textField = gradeField[indexPath.row]
            default:
                textField = UITextField()
        }
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
            textField.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 12),
            textField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -12)
        ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 && indexPath.row == gradeField.count {
            addGrade()
            let newIndex = IndexPath(row: gradeField.count - 1, section: 2)
            tableView.insertRows(at: [newIndex], with: .automatic)
        }
    }
}
