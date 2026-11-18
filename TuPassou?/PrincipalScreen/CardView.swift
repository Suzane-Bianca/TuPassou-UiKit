//
//  CardView.swift
//  TuPassou?
//
//  Created by Bianca Moura on 18/11/26.
//

import UIKit

class CardView: UITableViewCell {
    
    // A nova linha lateral de status (Verde ou Vermelha)
    private let statusLineView = UIView()
    
    private let emojiLabel = UILabel()
    private let tituloLabel = UILabel()
    private let tagCurso = PaddingLabel()
    private let tagCalculo = PaddingLabel()
    
    private let nmLabel = UILabel()
    private let notaLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não implementado")
    }
    
    private func setupUI() {
        self.backgroundColor = .systemBackground
        
        statusLineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLineView)
        
        // 2. Estilizar o Emoji (Círculo)
        emojiLabel.font = .systemFont(ofSize: 40)
        emojiLabel.textAlignment = .center
        emojiLabel.backgroundColor = UIColor.systemGray6
        emojiLabel.layer.cornerRadius = 35
        emojiLabel.clipsToBounds = true
        
        // 3. Textos e Tags
        tituloLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        [tagCurso, tagCalculo].forEach { tag in
            tag.font = .systemFont(ofSize: 11, weight: .medium)
            tag.textColor = .darkGray
            tag.backgroundColor = UIColor.systemGray6
            tag.layer.cornerRadius = 6
            tag.clipsToBounds = true
        }
        
        let meioStack = UIStackView(arrangedSubviews: [tituloLabel, tagCurso, tagCalculo])
        meioStack.axis = .vertical
        meioStack.alignment = .leading
        meioStack.spacing = 6
        
        // 4. Notas na direita
        nmLabel.text = "N.M:"
        nmLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nmLabel.textColor = .darkGray
        
        notaLabel.font = .systemFont(ofSize: 34, weight: .bold)
        
        let direitaStack = UIStackView(arrangedSubviews: [nmLabel, notaLabel])
        direitaStack.axis = .vertical
        direitaStack.alignment = .trailing
        direitaStack.spacing = 2
        
        // 5. O Stack Principal
        let mainStack = UIStackView(arrangedSubviews: [emojiLabel, meioStack, direitaStack])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            statusLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statusLineView.topAnchor.constraint(equalTo: contentView.topAnchor),
            statusLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            statusLineView.widthAnchor.constraint(equalToConstant: 6),
            
            emojiLabel.widthAnchor.constraint(equalToConstant: 70),
            emojiLabel.heightAnchor.constraint(equalToConstant: 70),
            
            mainStack.leadingAnchor.constraint(equalTo: statusLineView.trailingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // 6. A lógica das cores baseada nas notas
    func configurar(com cadeira: Matter) {
        emojiLabel.text = cadeira.emoji
        tituloLabel.text = cadeira.classe
        tagCurso.text = cadeira.course
        tagCalculo.text = cadeira.typeCalc
        
        notaLabel.text = cadeira.calcNotesSemester()
        
        let notasFeitas = cadeira.grade
        let mediaAtual: Float
        
        if notasFeitas.isEmpty {
            mediaAtual = 7.0
        } else {
            let soma = notasFeitas.reduce(0, +)
            mediaAtual = soma / Float(notasFeitas.count)
        }
        
        let verdeStatus = UIColor(red: 60/255, green: 179/255, blue: 113/255, alpha: 1.0) // Verde mais vivo
        let vermelhoStatus = UIColor.systemRed
        
        if mediaAtual >= 7.0 {
            statusLineView.backgroundColor = verdeStatus
            notaLabel.textColor = verdeStatus
        } else {
            statusLineView.backgroundColor = vermelhoStatus
            notaLabel.textColor = vermelhoStatus
        }
    }
}

class PaddingLabel: UILabel {
    var insets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}
