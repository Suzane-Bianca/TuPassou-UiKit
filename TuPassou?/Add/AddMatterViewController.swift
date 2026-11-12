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
}
