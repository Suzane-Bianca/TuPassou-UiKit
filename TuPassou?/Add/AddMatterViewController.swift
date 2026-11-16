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
    
    private let classeName = UITextField()
    private let courseName = UITextField()
//    private let 
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
        
        classeName.placeholder = "Calculo II..."
        courseName.placeholder = "Engenharia de Computação..."
    }
    
    @objc private func addCourse() {
        let classeName = classeName.text
        let courseName = courseName.text
        
        let course = Matter(classe: classeName!, course: courseName!)
        
        if courseName != ""{
            modelContext.insert(course)
        }
        onAdd()
        dismiss(animated: true)
    }

}

extension AddMatterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "Cadeira"
            case 1:
                return "Curso"
            default:
                return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        
        let textField: UITextField
        switch indexPath.section {
            case 0:
                textField = classeName
            case 1:
                textField = courseName
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
    }
}
