//
//  ViewController.swift
//  TuPassou?
//
//  Created by Bianca Moura on 10/11/26.
//

import UIKit
import SwiftUI
import SwiftData

class ContentViewController: UIViewController, UITableViewDataSource{ //UITableViewDataSource protocolo que diz que a class é capaz de fornercer dados para preencher uma tabela
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped) //Criando a tabela (lista)
    private let container = try! ModelContainer(for: Matter.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    private var couses: [Matter] = []
    
    override func viewDidLoad() { //Metodo chamado quando a tela é carregada
        super.viewDidLoad()
        
        navigationItem.title = "Suas Cadeiras"// Define o título que aparece na parte superior, caso a tela esteja dentro de um UINavigationController
        
        
        view.addSubview(tableView) // Pega a tabela criada e coloca fisicamente na tela principal
        tableView.translatesAutoresizingMaskIntoConstraints = false // Tem que ser false quando eu for posicionar os elementos por código, usando contrains (restrições)
        
        NSLayoutConstraint.activate([ // Pega as 4 bordas da tabela e as "cola" (ancora) nas 4 bordas da tela principal (assim a tabela vai ocupar a tela inteira
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self // Fala que quem vai fornecer os dados é a própria classe
        
        navigationItem.rightBarButtonItem = UIBarButtonItem( //cria um botão do lado direito da barra de Navegação superior
            primaryAction: UIAction ( // Da ação ao botão
                title: "Add User",
                image: .init(systemName: "plus") ) { _ in //executado quando o botão é clicado
                    let sheet = UINavigationController (
                        rootViewController: AddMatterViewController ( // Instancia uma nova tela e a envolve dentro do contre de navegação
                            modelContext: self.container.mainContext, // A chave do banco de dados, qnd a nova tela for salvar algo ela salva no mesmo lugar que a tela principal lê
                            onAdd: self.loadMatter // Isso é para ao salvar a lista seja atualizada
                        )
                    )
                    self.present(sheet, animated: true) //Pra tela subir igual sheet
                }
        )
    }
    
    func loadMatter() {
        
    }
    
    // Como a classe assinou o protocolo UITableViewDataSource, ela é obrigada a implementar estes dois métodos:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100 //Diz para a tabela quantas linhas ela terá
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt /*Desenha cada linha na tela*/ indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell() //Cria uma celula generica em branco
        var contentConfiguration = cell.defaultContentConfiguration() //Estiliza as celulas, cria um modelo padrão de texto e imagem
        contentConfiguration.text = "\(indexPath.row)" // Pega o número da linha (index) e tranforma em texto
        cell.contentConfiguration = contentConfiguration
        cell.backgroundColor = .clear //Cada fundo precisa ser transparente
        return cell
    }
}

#Preview {
    UINavigationController(rootViewController: ContentViewController())
}

