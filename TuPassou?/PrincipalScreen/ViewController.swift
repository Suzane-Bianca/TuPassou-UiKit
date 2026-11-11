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
        
        navigationItem.title = "Suas Cadeiras" // Define o título que aparece na parte superior, caso a tela esteja dentro de um UINavigationController
        view.addSubview(tableView) // Pega a tabela criada e coloca fisicamente na tela principal
        tableView.translatesAutoresizingMaskIntoConstraints = false // Tem que ser false quando eu for posicionar os elementos por código, usando contrains (restrições)
        
        NSLayoutConstraint.activate([ // Pega as 4 bordas da tabela e as "cola" (ancora) nas 4 bordas da tela principal (assim a tabela vai ocupar a tela inteira
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                                    ])
        //
        tableView.backgroundColor = .clear // Deixa o fundo da tabela totalmente transparente (para que o degradê apareça
        tableView.dataSource = self // Fala que quem vai fornecer os dados é a própria classe
        
        // tableView.backgroundView = UIHostingConfiguration /*Permite colocar componentes do swiftUI*/{ //desenhando o fundo da tela
        // LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .top, endPoint: .bottom) // Cria o degradê
        // .ignoresSafeArea()
        // }
        // .margins(.all, 0)
        // .makeContentView() // Converte o codigo swift em uma UIView tradicional
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

