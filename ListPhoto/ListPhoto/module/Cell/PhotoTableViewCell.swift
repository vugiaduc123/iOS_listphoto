import UIKit

class PhotoTableViewCell: UITableViewCell {
    private let heightText:CGFloat = 17
    private var heightPhoto:CGFloat = 0.0
    private let paddingLeft:CGFloat = 15
    private var heightConstraintPhoto: NSLayoutConstraint?
    private lazy var imagePhoto = UIImageView()
    private lazy var viewLoading = UIImageView()
    var namePhotolb = UILabel()
    var sizePhotolb = UILabel()
    
    private var isImageLoaded = false
    private var currentImageUrl: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addView()
        setUpView()
        
        loadingView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentImageUrl = nil
        imagePhoto.image = nil
        viewLoading.isHidden = false
        namePhotolb.isHidden = true
        sizePhotolb.isHidden = true
        heightConstraintPhoto?.constant = 100
        imagePhoto.setNeedsDisplay()
    }
    
}

// MARK: Setup View - Constraint
extension PhotoTableViewCell {
    private func addView() {
        self.contentView.addSubview(imagePhoto)
        self.contentView.addSubview(namePhotolb)
        self.contentView.addSubview(sizePhotolb)
        self.contentView.addSubview(viewLoading)
    }
    
    private func setUpView() {
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        self.selectionStyle = .none // remove hight light
        
        configImage()
        configNamelb()
        configSizelb()
    }
    
    private func configImage() {
        imagePhoto.contentMode = .scaleAspectFill
        imagePhoto.clipsToBounds = true
        imagePhoto.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imagePhoto.topAnchor.constraint(equalTo: contentView.topAnchor),
            imagePhoto.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imagePhoto.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        heightConstraintPhoto = imagePhoto.heightAnchor.constraint(equalToConstant: 100)
        heightConstraintPhoto?.priority = .defaultHigh
        heightConstraintPhoto?.isActive = true
    }
    
    private func configNamelb() {
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
    
    private func configSizelb() {
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
    
    private func configImageLoading() {
        viewLoading.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            viewLoading.topAnchor.constraint(equalTo: self.topAnchor),
            viewLoading.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            viewLoading.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            viewLoading.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    private func loadingView() {
        if self.contentView.viewWithTag(444) != nil {
            return
        }
        let x = (self.contentView.frame.width - 50) / 2
        let y = (self.contentView.frame.height - 50) / 2
        let loading = self.generateLoading(frame: CGRect(x: x,
                                                         y: y,
                                                         width: 50,
                                                         height: 50))
        viewLoading = loading
        self.imagePhoto.center = viewLoading.center
        viewLoading.tag = 444
        self.contentView.addSubview(viewLoading)
    }
    
    private func generateLoading(frame: CGRect) -> UIImageView {
        let imageLoading = CustomLoading(frame: frame)
        return imageLoading
    }
}
// MARK: Binding Data
extension PhotoTableViewCell {
    func bindingData(with photo: PhotoModel, height: Int, downloader: ImageDownloader, isScrollingFast: Bool = false) {
        currentImageUrl = photo.download_url
        isImageLoaded = false
        downloader.download(url: photo.download_url,
                            completionTask: { _ in },
                            placeholder: { isLoading in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if !self.isImageLoaded {
                    self.imagePhoto.image = nil
                    self.imagePhoto.setNeedsDisplay()
                    self.viewLoading.isHidden = false
                } else {
                    viewLoading.isHidden = true
                }
            }
        },
                            completion: { [weak self] result in
            guard let self = self, self.currentImageUrl == photo.download_url else {
                print("Cell reused or URL mismatch for \(photo.download_url)")
                return
            }
            DispatchQueue.main.async {
                self.isImageLoaded = true
                switch result {
                case .success(let image):
                    self.imagePhoto.image = image
                    self.updateLayout(height: CGFloat(height), isScrollingFast: isScrollingFast)
                case .failure(let error):
                    self.imagePhoto.image = UIImage(named: "error")
                    self.imagePhoto.setNeedsDisplay()
                }
            }
        })
        
        namePhotolb.text = photo.author
        sizePhotolb.text = "Size: \(photo.width)x\(photo.height)"
    }
    
    private func updateLayout(height: CGFloat, isScrollingFast: Bool) {
        self.viewLoading.isHidden = true
        self.imagePhoto.setNeedsDisplay()
        self.namePhotolb.isHidden = false
        self.sizePhotolb.isHidden = false
        self.heightConstraintPhoto?.constant = height
        
        UIView.animate(withDuration: isScrollingFast ? 0.1 : 0) {
            self.contentView.layoutIfNeeded()
        }
        
    }
}
