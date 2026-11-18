//
//  AddMatterViewController.swift
//  TuPassou?
//
//  Created by Bianca Moura on 12/11/26.
//

import UIKit
import SwiftData

class AddMatterViewController: UIViewController {
    
    private let modelContext: ModelContext // Ligação com o banco de dados
    private let onAdd: () -> Void //Clousure, uma função armazenada em uma variável, usada para executar o loadMatter
    
    private let emojiButton = UIButton(type: .system)
    private var selectedEmoji: String = "📚"
    
    private let classeName = UITextField()
    private let courseName = UITextField()
    private var gradeField: [UITextField] = []
    private let calcPicker = UISegmentedControl(items: ["Padrão IF", "Pensonalizado..."])
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    
    // @escaping fala que a função onAdd vai ser guardada na memoria para ser executada mais tarde
    init(modelContext: ModelContext, onAdd: @escaping () -> Void) { // O construtor que preenche as veriáveis assim que a tela é criada
        self.modelContext = modelContext
        self.onAdd = onAdd
        super.init(nibName: nil, bundle: nil) //coonstrução padrao da apple
    }
    
    @available(*, unavailable) //Obrigatório, serve para proibir o uso dessa tela via Storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        navigationItem.title = "Nova Cadeira"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "checkmark"),
            style: .prominent,
            target: self,
            action: #selector(addCourse)
        )
        
        tableView.translatesAutoresizingMaskIntoConstraints = false // Tem que ser false quando eu for posicionar os elementos por código, usando contrains (restrições)
        
        NSLayoutConstraint.activate([ // Pega as 4 bordas da tabela e as "cola" (ancora) nas 4 bordas da tela principal (assim a tabela vai ocupar a tela inteira
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        setupHeaderEmojiView()
        
        classeName.placeholder = "Calculo II..."
        courseName.placeholder = "Engenharia de Computação..."
        
        calcPicker.selectedSegmentIndex = 0
        
        for _ in 0..<4{
            addGrade()
        }
    }
    
    private func setupHeaderEmojiView() {
        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 130))
        
        emojiButton.setTitle(selectedEmoji, for: .normal)
        emojiButton.titleLabel?.font = .systemFont(ofSize: 42)
        emojiButton.backgroundColor = .systemGray5
        
        emojiButton.layer.borderColor = UIColor.systemGray4.cgColor
        emojiButton.layer.borderWidth = 0
        
        emojiButton.layer.cornerRadius = 35 
        emojiButton.clipsToBounds = true
        emojiButton.translatesAutoresizingMaskIntoConstraints = false
        
        emojiButton.addAction(UIAction { [weak self] _ in
            self?.tocarParaTrocarEmoji()
        }, for: .touchUpInside)
        
        headerContainer.addSubview(emojiButton)
        
        NSLayoutConstraint.activate([
            emojiButton.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            emojiButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            emojiButton.widthAnchor.constraint(equalToConstant: 70),
            emojiButton.heightAnchor.constraint(equalToConstant: 70)
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
        let classeName = classeName.text
        let courseName = courseName.text
        
        let typeCalc = calcPicker.selectedSegmentIndex == 0 ? "Padrão IF" : "Personalizado..."
        
        var notesFloat: [Float] = []
        
        for camp in gradeField {
            if let words = camp.text {
                let wordWithDot = words.replacingOccurrences(of: ",", with: ".")
                if let note = Float(wordWithDot){
                    notesFloat.append(note)
                }
            }
        }
        
        let course = Matter(classe: classeName!, course: courseName!, grade: notesFloat, typeCalc: typeCalc, emoji: selectedEmoji)
        
        if courseName != ""{
            modelContext.insert(course)
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
