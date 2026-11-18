//
//  MatterDetailViewController.swift
//  TuPassou?
//
//  Created by Bianca Moura on 18/11/26.
//

import UIKit

class MatterDetailViewController: UIViewController {
    
    private let cadeira: Matter
    
    // Elementos Visuais
    private let headerView = UIView()
    private let emojiContainer = UIView()
    private let emojiLabel = UILabel()
    
    private let tituloLabel = UILabel()
    private let stackDetalhes = UIStackView()
    
    // Inicializador que exige receber a cadeira clicada
    init(cadeira: Matter) {
        self.cadeira = cadeira
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não implementado")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground // Fundo branco padrão
        
        setupUI()
        preencherDados()
    }
    
    private func setupUI() {
        // 1. O Cabeçalho Hashurado (Colorido)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 120) // Altura do cabeçalho
        ])
        
        // 2. A Bolinha do Emoji (No centro, metade dentro, metade fora do cabeçalho)
        emojiContainer.backgroundColor = .systemBackground // Bordinha branca para separar do fundo
        emojiContainer.layer.cornerRadius = 45 // 90x90
        
        emojiLabel.backgroundColor = .systemGray6
        emojiLabel.layer.cornerRadius = 41 // 82x82 (um pouco menor que o container para criar a borda)
        emojiLabel.font = .systemFont(ofSize: 46)
        emojiLabel.textAlignment = .center
        emojiLabel.clipsToBounds = true
        
        emojiContainer.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emojiContainer)
        
        NSLayoutConstraint.activate([
            emojiContainer.widthAnchor.constraint(equalToConstant: 90),
            emojiContainer.heightAnchor.constraint(equalToConstant: 90),
            emojiContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emojiContainer.centerYAnchor.constraint(equalTo: headerView.bottomAnchor), // Fica exatamente na linha de corte
            
            emojiLabel.widthAnchor.constraint(equalToConstant: 82),
            emojiLabel.heightAnchor.constraint(equalToConstant: 82),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainer.centerYAnchor)
        ])
        
        // 3. Título da Cadeira
        tituloLabel.font = .systemFont(ofSize: 28, weight: .bold)
        tituloLabel.textAlignment = .center
        tituloLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tituloLabel)
        
        NSLayoutConstraint.activate([
            tituloLabel.topAnchor.constraint(equalTo: emojiContainer.bottomAnchor, constant: 16),
            tituloLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tituloLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // 4. Stack com as Informações (Curso, Cálculo, Nota)
        stackDetalhes.axis = .vertical
        stackDetalhes.spacing = 24 // Espaçamento grande entre os blocos
        stackDetalhes.alignment = .fill
        stackDetalhes.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackDetalhes)
        
        NSLayoutConstraint.activate([
            stackDetalhes.topAnchor.constraint(equalTo: tituloLabel.bottomAnchor, constant: 32),
            stackDetalhes.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackDetalhes.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    private func preencherDados() {
        emojiLabel.text = cadeira.emoji
        tituloLabel.text = cadeira.classe
        
        // Lógica da Cor (Verde/Vermelho)
        let notasFeitas = cadeira.grade
        let mediaAtual: Float
        if notasFeitas.isEmpty {
            mediaAtual = 7.0
        } else {
            let soma = notasFeitas.reduce(0, +)
            mediaAtual = soma / Float(notasFeitas.count)
        }
        
        let corStatus = mediaAtual >= 7.0
            ? UIColor(red: 60/255, green: 179/255, blue: 113/255, alpha: 1.0) // Verde vivo
            : UIColor.systemRed
        
        // Pinta o cabeçalho
        headerView.backgroundColor = corStatus.withAlphaComponent(0.15) // Fundo suave como pediu
        
        // Adiciona os blocos de texto
        adicionarBlocoInfo(titulo: "Curso", valor: cadeira.course)
        adicionarBlocoInfo(titulo: "Tipo de Cálculo", valor: cadeira.typeCalc)
        adicionarBlocoNotaGrande(titulo: "Nota Mínima (por prova)", valor: cadeira.calcNotesSemester(), cor: corStatus)
    }
    
    // Função auxiliar para criar aqueles pequenos blocos de texto
    private func adicionarBlocoInfo(titulo: String, valor: String) {
        let lblTitulo = UILabel()
        lblTitulo.text = titulo.uppercased()
        lblTitulo.font = .systemFont(ofSize: 12, weight: .bold)
        lblTitulo.textColor = .secondaryLabel
        
        let lblValor = UILabel()
        lblValor.text = valor
        lblValor.font = .systemFont(ofSize: 18, weight: .regular)
        lblValor.textColor = .label
        
        let stack = UIStackView(arrangedSubviews: [lblTitulo, lblValor])
        stack.axis = .vertical
        stack.spacing = 4
        stackDetalhes.addArrangedSubview(stack)
    }
    
    // Função auxiliar para criar a Nota Gigante em baixo
    private func adicionarBlocoNotaGrande(titulo: String, valor: String, cor: UIColor) {
        let lblTitulo = UILabel()
        lblTitulo.text = titulo.uppercased()
        lblTitulo.font = .systemFont(ofSize: 12, weight: .bold)
        lblTitulo.textColor = .secondaryLabel
        lblTitulo.textAlignment = .center
        
        let lblValor = UILabel()
        lblValor.text = valor
        lblValor.font = .systemFont(ofSize: 64, weight: .bold) // Nota GIGANTE
        lblValor.textColor = cor // Pinta a nota da cor de status
        lblValor.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [lblTitulo, lblValor])
        stack.axis = .vertical
        stack.spacing = 8
        
        // Adiciona um espaço extra antes da nota final para separar do resto
        stackDetalhes.setCustomSpacing(40, after: stackDetalhes.arrangedSubviews.last!)
        stackDetalhes.addArrangedSubview(stack)
    }
}
