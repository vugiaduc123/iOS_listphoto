///
///
import UIKit
import Combine

class PhotoTableViewCell: UITableViewCell {
    private var disposeBag: Set<AnyCancellable> = []
    
    private let heightText: CGFloat = 17
    private var heightPhoto: CGFloat = 0.0
    private let paddingLeft: CGFloat = 15
    private var heightConstraintPhoto: NSLayoutConstraint?
    private lazy var imagePhoto = UIImageView()
    
    var namePhotolb = UILabel()
    var sizePhotolb = UILabel()
    private var currentImageUrl: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
        addView()
        constraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentImageUrl = nil
        namePhotolb.text = ""
        sizePhotolb.text = ""
        imagePhoto.image = nil
        disposeBag.removeAll()
    }
}

// MARK: Setup View
extension PhotoTableViewCell {
    private func addView() {
        contentView.addSubview(imagePhoto)
        contentView.addSubview(namePhotolb)
        contentView.addSubview(sizePhotolb)
    }
    
    private func setUpView() {
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        self.selectionStyle = .none
        
        configImage()
        configNamelb()
        configSizelb()
    }
    
    private func configImage() {
        imagePhoto.contentMode = .scaleAspectFill
        imagePhoto.clipsToBounds = true
        imagePhoto.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configNamelb() {
        namePhotolb.textColor = .black.withAlphaComponent(0.8)
        namePhotolb.numberOfLines = 1
        namePhotolb.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        namePhotolb.textAlignment = .left
        namePhotolb.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configSizelb() {
        sizePhotolb.numberOfLines = 1
        sizePhotolb.textColor = .black.withAlphaComponent(0.8)
        sizePhotolb.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        sizePhotolb.textAlignment = .left
        sizePhotolb.translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: Constraint
extension PhotoTableViewCell {
    private func constraint() {
        NSLayoutConstraint.activate([
            imagePhoto.topAnchor.constraint(equalTo: contentView.topAnchor),
            imagePhoto.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imagePhoto.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        heightConstraintPhoto = imagePhoto.heightAnchor.constraint(equalToConstant: 100)
        heightConstraintPhoto?.priority = .defaultHigh
        heightConstraintPhoto?.isActive = true
        
        NSLayoutConstraint.activate([
            namePhotolb.topAnchor.constraint(equalTo: imagePhoto.bottomAnchor, constant: 15),
            namePhotolb.heightAnchor.constraint(equalToConstant: heightText),
            namePhotolb.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: paddingLeft),
            namePhotolb.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -paddingLeft),
            
            sizePhotolb.topAnchor.constraint(equalTo: namePhotolb.bottomAnchor, constant: 5),
            sizePhotolb.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: paddingLeft),
            sizePhotolb.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -paddingLeft),
            sizePhotolb.heightAnchor.constraint(equalToConstant: heightText),
        ])
    }
}

// MARK: Binding Data
extension PhotoTableViewCell {
    func bindingData(with photo: PhotoEntity, height: Int, isScrollingFast: Bool = false) {
        currentImageUrl = photo.downloadURL
        
        heightConstraintPhoto?.constant = CGFloat(height)

        let input = ImageDownloader.Input(url: photo.downloadURL)

        Just(input)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self = self else { return }
                self.imagePhoto.showSkeleton()
                self.namePhotolb.showSkeleton()
                self.sizePhotolb.showSkeleton()
            })
            .filter { _ in !isScrollingFast }
            .map { ImageDownloader.shared.download(input: $0) }
            .sink(receiveValue: { [weak self] output in
                guard let self = self else { return }
                // Loading
                output.loading
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] loading in
                        guard let self = self else { return }
                        if !loading {
                            UIView.animate(withDuration: 0.1) {
                                self.imagePhoto.hideSkeleton()
                                self.namePhotolb.hideSkeleton()
                                self.sizePhotolb.hideSkeleton()
                            }
                        }
                    }
                    .store(in: &self.disposeBag)
                
                // Image
                output.image
                    .sink { [weak self] image in
                        guard let self = self, self.isValid(for: photo.downloadURL) else { return }
//                        self.updateLayout(image: image)
                        self.imagePhoto.image = image
                        self.namePhotolb.text = photo.author
                        self.sizePhotolb.text = "Size: \(photo.width)x\(photo.height)"
                        self.imagePhoto.layoutIfNeeded()
                        self.imagePhoto.setNeedsLayout()
                    }
                    .store(in: &self.disposeBag)
                
                // Error
                output.error
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] error in
                        guard let self = self else { return }
                        self.imagePhoto.image = UIImage(named: "error")!
                    }
                    .store(in: &self.disposeBag)
            })
            .store(in: &disposeBag)
    }
}

extension PhotoTableViewCell {
    func isValid(for url: String?) -> Bool {
        return currentImageUrl == url
    }
}
