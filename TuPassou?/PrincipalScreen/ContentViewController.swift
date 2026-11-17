//
//  ViewController.swift
//  TuPassou?
//
//  Created by Bianca Moura on 10/11/26.
//

import UIKit
import SwiftUI
import SwiftData

class ContentViewController: UIViewController{ //UITableViewDataSource protocolo que diz que a class é capaz de fornercer dados para preencher uma tabela
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped) //Criando a tabela (lista)
    private let container = try! ModelContainer(for: Matter.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))//Banco de dados que vai guardar as informaçÕes
    private var classes: [Matter] = []
    
    override func viewDidLoad() { //Metodo chamado quando a tela é carregada
        super.viewDidLoad()
        
        navigationItem.title = "Suas Cadeiras"// Define o título que aparece na parte superior, caso a tela esteja dentro de um UINavigationController
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(tableView) // Pega a tabela criada e coloca fisicamente na tela principal
        tableView.translatesAutoresizingMaskIntoConstraints = false // Tem que ser false quando eu for posicionar os elementos por código, usando contrains (restrições)
        
        NSLayoutConstraint.activate([ // Pega as 4 bordas da tabela e as "cola" (ancora) nas 4 bordas da tela principal (assim a tabela vai ocupar a tela inteira
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self // Fala que quem vai fornecer os dados é a própria classe
        tableView.delegate = self // Gerenciador de comportamento
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell") // sempre que precisar de uma celula nova, usa o modelo padrão UITableViewCell e carimba como "cell"
        
        let addMatter = UIAction { _ in
            let sheet = UINavigationController (
                rootViewController: AddMatterViewController ( // Instancia uma nova tela e a envolve dentro do contre de navegação
                    modelContext: self.container.mainContext, // A chave do banco de dados, qnd a nova tela for salvar algo ela salva no mesmo lugar que a tela principal lê
                    onAdd: self.loadMatter // Isso é para ao salvar a lista seja atualizada
                )
            )
            self.present(sheet, animated: true) //Pra tela subir igual sheet
        }
        
        let buttonAdd = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            primaryAction: addMatter
        )
            
        buttonAdd.style = .prominent //pra deixar azul
        
        navigationItem.rightBarButtonItem = buttonAdd

        
        loadMatter()
    }
    
    func loadMatter() {
        let descriptor = FetchDescriptor<Matter>() //Cria uma "Ordem de Busca": FetchDescriptor
        let saveCourses = (try? container.mainContext.fetch(descriptor)) ?? [] // Procura e trata para a aplicação não falhar
        classes = saveCourses.reversed()
        tableView.reloadData() //"A lista mudou, redesenha novamente"
    }
    
    func deleteMatter(at indexPath: IndexPath) {
        let course = classes[indexPath.row] //Usa o index para encontrar o item
        container.mainContext.delete(course) //Vai no banco de dados e apaga
        classes.remove(at: indexPath.row) //Apaga do Array
        tableView.deleteRows(at: [indexPath], with: .automatic) //Animação para apagar de forma suave
    }
    
}
    
extension ContentViewController: UITableViewDataSource, UITableViewDelegate{ // So para organizar
    
    
    // Como a classe assinou o protocolo UITableViewDataSource, ela é obrigada a implementar estes dois métodos:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count //Diz para a tabela quantas linhas ela terá
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt /*Desenha cada linha na tela*/ indexPath: IndexPath) -> UITableViewCell {
        let course = classes[indexPath.row] //Cria uma celula generica em branco
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) //puxa la do register para economizar memoria
        
        var contentConfiguration = cell.defaultContentConfiguration() //Estiliza as celulas, cria um modelo padrão de texto e imagem
        contentConfiguration.text = "\(course.classe)" // Pega o número da linha (index) e tranforma em texto
        contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: .headline)
        
        let status = course.calcNotesSemester()
        
        contentConfiguration.secondaryText = """
                 \(course.course)
                Cálculo: \(course.typeCalc)
                Nota mínima (por prova): \(status)
            """
        
        contentConfiguration.secondaryTextProperties.numberOfLines = 0
        contentConfiguration.secondaryTextProperties.color = .secondaryLabel
        
        cell.contentConfiguration = contentConfiguration
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let course = courses[indexPath.row]
//        print(course.course)
//    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { //É o que acontece quando desliza a linha da direita para a esquerda
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { (_, _, completion) in
            self.deleteMatter(at: indexPath)
            completion(true)
        })
        action.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [action])
    }
}
    

#Preview {
    UINavigationController(rootViewController: ContentViewController())
}

