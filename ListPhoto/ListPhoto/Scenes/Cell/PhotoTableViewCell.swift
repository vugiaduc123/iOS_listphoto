//
//  PhotoTableViewCell.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
    let heightText:CGFloat = 17
    var heightPhoto:CGFloat = 0.0
    let paddingLeft:CGFloat = 15
    var heightConstraintPhoto: NSLayoutConstraint?
    lazy var imagePhoto = UIImageView()
    var namePhotolb = UILabel()
    var sizePhotolb = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addView()
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imagePhoto.image = nil
    }
    
}

// MARK: Setup View - Constraint
extension PhotoTableViewCell {
    func addView() {
        self.contentView.addSubview(imagePhoto)
        self.contentView.addSubview(namePhotolb)
        self.contentView.addSubview(sizePhotolb)
    }
    
    func setUpView() {
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        self.selectionStyle = .none
        
        configImage()
        configNamelb()
        configSizelb()
    }
    
    func configImage() {
        imagePhoto.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imagePhoto.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            imagePhoto.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            imagePhoto.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
        ])
        heightConstraintPhoto = imagePhoto.heightAnchor.constraint(equalToConstant: 100)
        heightConstraintPhoto?.isActive = true
    }
    
    func configNamelb() {
        namePhotolb.text = "Alejandro Escamilla"
        namePhotolb.textColor = .black.withAlphaComponent(0.8)
        namePhotolb.numberOfLines = 1
        namePhotolb.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        namePhotolb.textAlignment = .left
        namePhotolb.translatesAutoresizingMaskIntoConstraints = false
        namePhotolb.isHidden = true
        
        NSLayoutConstraint.activate([
            namePhotolb.topAnchor.constraint(equalTo: self.imagePhoto.bottomAnchor, constant: 15),
            namePhotolb.heightAnchor.constraint(equalToConstant: heightText),
            namePhotolb.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: paddingLeft),
            namePhotolb.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -paddingLeft),
        ])
    }
    
    func configSizelb() {
        sizePhotolb.numberOfLines = 1
        sizePhotolb.textColor = .black.withAlphaComponent(0.8)
        sizePhotolb.text = "Size: 5000x33333"
        sizePhotolb.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        sizePhotolb.textAlignment = .left
        sizePhotolb.translatesAutoresizingMaskIntoConstraints = false
        sizePhotolb.isHidden = true
        NSLayoutConstraint.activate([
            sizePhotolb.topAnchor.constraint(equalTo: self.namePhotolb.bottomAnchor, constant: 5),
            sizePhotolb.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: paddingLeft),
            sizePhotolb.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -paddingLeft),
            sizePhotolb.heightAnchor.constraint(equalToConstant: heightText),
        ])
    }
}

// MARK: Binding data

extension PhotoTableViewCell {
    
    func bindingData(item: PhotoModel, viewModel: PhotoViewModel, indexPathScroll: IndexPath) {
        let height:CGFloat = CGFloat(viewModel.prefixNumber(number: item.height))
        let cache = viewModel.imageCache
        self.imagePhoto.contentMode = .scaleAspectFit
        self.imagePhoto.image = UIImage(named: "loading")
        if indexPathScroll.row > viewModel.limitItem {
            if let imageCache = cache.object(forKey: item.download_url as NSString) {
                self.changeObject(resizedImage: imageCache, height: height)
            }else{
                viewModel.getDownLoadURL(url: item.download_url, maxWidth: CGFloat(item.width), maxHeight: height) { task in
                } completion: { result in
                    switch result {
                    case .success(let image):
                        self.changeObject(resizedImage: image, height: height)
                    case .failure(let err):
                        print("Fail to load: \(err.localizedDescription)")
                        DispatchQueue.main.async {
                            self.imagePhoto.image = UIImage(named: "error")
                            self.imagePhoto.contentMode = .scaleAspectFit
                        }
                    }
                }
                
            }
            
        }else{
            viewModel.getDownLoadURL(url: item.download_url, maxWidth: CGFloat(item.width), maxHeight: height) { task in
            } completion: { result in
                switch result {
                case .success(let image):
                    self.changeObject(resizedImage: image, height: height)
                case .failure(let err):
                    print("Fail to load: \(err.localizedDescription)")
                    DispatchQueue.main.async {
                        self.imagePhoto.image = UIImage(named: "error")
                        self.imagePhoto.contentMode = .scaleAspectFit
                    }
                }
            }
        }
        self.namePhotolb.text = item.author
        self.sizePhotolb.text = "Size: \(item.width)x\(item.height)"
    }
    
    func changeObject(resizedImage: UIImage, height: CGFloat) {
        self.imagePhoto.image = resizedImage
        self.namePhotolb.isHidden = false
        self.sizePhotolb.isHidden = false
        heightConstraintPhoto?.constant = height
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.imagePhoto.contentMode = .scaleAspectFill
            strongSelf.imagePhoto.clipsToBounds = true
            strongSelf.heightConstraintPhoto?.isActive = true
            strongSelf.contentView.layoutIfNeeded()
        }
    }
}

