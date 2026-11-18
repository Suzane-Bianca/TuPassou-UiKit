//
//  ViewController.swift
//  TuPassou?
//
//  Created by Bianca Moura on 10/11/26.
//

import UIKit
import SwiftUI
import SwiftData

class ContentViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped) //É o que instacia a lista, o .insertGrouped (tabelas agrupadas) é o que dar a aparecia mais "Apple" para a tabela
    
    //Container do SwiftData, o arquivo no disco
    private let container = try! ModelContainer(for: Matter.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false))
    private var classes: [Matter] = [] // A tabela lê o banco de dados a partir desse Array
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Suas Cadeiras"
        navigationController?.navigationBar.prefersLargeTitles = true //Para deixar o título grande
                
        //aqui ele ta vendo se o iphone do usario roda o iOS 15 ou superior
        if #available(iOS 15.0, *) { // é o que tira a margem que a apple da automaticamente no insetGrouped
            tableView.sectionHeaderTopPadding = 0.0
        }
        
        tableView.backgroundView = nil // garante que a tabela seja transparente e sem cor de fundo
        
        view.addSubview(tableView) // adicina a tabela fisicamente na tela
        
        tableView.translatesAutoresizingMaskIntoConstraints = false //False para desativar o posicionamento automatico
        
        NSLayoutConstraint.activate([ //basicamente ta esticando a tabela para ocupar a tela inteira
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self //Gerencia os dados da tabela
        tableView.delegate = self //Gerencia os toques e gestos da tabela
        
        //aqui ele ta falando que sempre que a cardview for acionada, coloque um carimbo chamado "CadeiraCell"
        tableView.register(CardView.self, forCellReuseIdentifier: "CadeiraCell")
        
        let addMatter = UIAction { _ in //Botão adicionar, a ação dele "UIAction" empacota a view que vai aparecer dentro de um NavigationController, assim ele tem um titulo no topo
            let sheet = UINavigationController (
                rootViewController: AddMatterViewController (
                    modelContext: self.container.mainContext, //aqui eu garando que quando a add for acionada e ela fizer algo no banco de dados, vai ser no mesmo lugar onde a tela principal ta lendo
                    onAdd: self.loadMatter //passa a função para a tela de cadastro saiba como avisar a tela principal atualizar a lista quando terminar
                )
            )
            self.present(sheet, animated: true) //.present para ele subir como uma sheet
        }
        
        let buttonAdd = UIBarButtonItem( // cria o item e açao dele é ativar o addMatter
            image: UIImage(systemName: "plus"),
            primaryAction: addMatter
        )
        
        buttonAdd.style = .prominent // para deixar padrão no azul
        
        navigationItem.rightBarButtonItem = buttonAdd //o slot que fica no canto superior direito

        loadMatter()
    }
        
    func loadMatter() {
        let descriptor = FetchDescriptor<Matter>() //Como se fosse o query
        let saveCourses = (try? container.mainContext.fetch(descriptor)) ?? [] //vai no disco, puxa as cadeiras
        classes = saveCourses.reversed() //e aqui inverte
        tableView.reloadData() // "A lista mudou, redesenha novamente"
    }
    
    func deleteMatter(at indexPath: IndexPath) { //O delete
        let course = classes[indexPath.section] // Usa o index para encontrar o item
        container.mainContext.delete(course) // Vai no banco de dados e apaga
        classes.remove(at: indexPath.section) // Apaga do Array
        tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic) //apaga visualmente com um animação
    }
}
    
extension ContentViewController: UITableViewDataSource, UITableViewDelegate { // Extensão só pra deixar o codigo mais organizado
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //defino que a quantidade de sessões é cada coisa do array
        return classes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Diz para a tabela quantas linhas ela terá por seção
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //Redenrização
        let course = classes[indexPath.section]
        
        //pega o cartao que saiu da tela, e o usa para reaproveitar
        let cell = tableView.dequeueReusableCell(withIdentifier: "CadeiraCell", for: indexPath) as! CardView
        
        cell.configurar(com: course)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // o que acontece quando eu clicar
        tableView.deselectRow(at: indexPath, animated: true) //pra da a sensaçao do toque, deixa cinza
        
        let course = classes[indexPath.section] //pega no array, a cadeira que foi tocada
        let detailSheet = MatterDetailViewController(cadeira: course) //ve a cadeira clicada e cria um MatterDetail
        
        if let sheet = detailSheet.sheetPresentationController {
            sheet.detents = [.medium(), .large()] //é o que controla fisicamente a sheet
            sheet.prefersGrabberVisible = true //é o que mostra a barrinha cinza em cima
        }
        
        present(detailSheet, animated: true) //apresenta a tela
    }
    
    // deslize para o lado, aqui cria função de arrastar da direita para a esquerda
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let course = classes[indexPath.section]
        
        //instancias do UIContextualAction (classe da Apple que reprenta um unico botao escondido dentro de um menu deslize
        
        //delete
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (_, _, completion) in //estilo destructive, assim fica vermelho automatico
            self.deleteMatter(at: indexPath) //chama o deleteMatter
            completion(true) //para dizer que deu certo e voltar a animaçao ao normal
        })
        deleteAction.image = UIImage(systemName: "trash")
        
        //editar
        let editAction = UIContextualAction(style: .normal, title: "Editar", handler: { (_, _, completion) in
            let sheet = UINavigationController (
                rootViewController: AddMatterViewController ( //levanta a mesma tela de cadastro
                    modelContext: self.container.mainContext,
                    matterToEdit: course, // mas coloca a variavel matterToEdit
                    onAdd: self.loadMatter //faz o load
                )
            )
            self.present(sheet, animated: true)
            completion(true)
        })
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction]) //empacota os dois botões
        configuration.performsFirstActionWithFullSwipe = false //desativa o atalho que faz com que se você puxa muito rapido executa a primeria ação
        
        return configuration
    }
    
    //distancia dos cards
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8.0 // Distância acima do cartão
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8.0 // Distância abaixo do cartão
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
    

#Preview {
    UINavigationController(rootViewController: ContentViewController())
}

