import UIKit
import SnapKit

class DetailView: UIView {
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.dohyeon(size: 16)
        label.textAlignment = .center
        label.text = "To Do"
        label.textColor = UIColor(named: "TextColor")
        return label
    }()
    
    lazy var createdTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.dohyeon(size: 14)
        label.textAlignment = .right
        label.textColor = UIColor(named: "TextColor")
        return label
    }()
    
    lazy var updatedTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.dohyeon(size: 14)
        label.textAlignment = .right
        label.textColor = UIColor(named: "TextColor")
        return label
    }()
    
    let maxWidth: CGFloat = 400
    let maxHeight: CGFloat = 600
    lazy var titleImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 15
        image.image = UIImage(named: "DefaultImage")
        return image
    }()
    
    lazy var getCatButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.dohyeon(size: 10)
        button.setTitle("고양이 만나기", for: .normal)
        button.setTitleColor(UIColor(named: "CalendarSelectColor"), for: .normal)
        button.backgroundColor = UIColor(named: "CalendarColor")
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
        return button
    }()
    
    lazy var getDefaultImageButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.dohyeon(size: 10)
        button.setTitle("기본 이미지 불러오기", for: .normal)
        button.setTitleColor(UIColor(named: "CalendarSelectColor"), for: .normal)
        button.backgroundColor = UIColor(named: "CalendarColor")
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
        return button
    }()
    
    lazy var getCustomImageButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.dohyeon(size: 10)
        button.setTitle("내 사진 추가", for: .normal)
        button.setTitleColor(UIColor(named: "CalendarSelectColor"), for: .normal)
        button.backgroundColor = UIColor(named: "CalendarColor")
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
        return button
    }()
    
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [getCatButton, getCustomImageButton, getDefaultImageButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    lazy var contentText: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.dohyeon(size: 12)
        textView.backgroundColor = UIColor(named: "BackgroundColor")
        textView.text = "할 일을 입력해보세요 !!"
        textView.textColor = .lightGray
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 1
        textView.isEditable = true
        textView.isScrollEnabled = true
        return textView
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.dohyeon(size: 14)
        button.setTitle("할 일 추가", for: .normal)
        button.setTitleColor(UIColor(named: "CalendarSelectColor"), for: .normal)
        button.backgroundColor = UIColor(named: "CalendarColor")
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
        return button
    }()
    
    // UIStackView는 사용하지만 이미지뷰는 스택뷰 밖에서 별도로 관리
    lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, createdTimeLabel, updatedTimeLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.alignment = .fill
        return stackView
    }()
    
    lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [buttonStackView, contentText, addButton])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.alignment = .fill
        return stackView
    }()
    
    // setupUI() 함수와 생성자만 유지
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImage(image: UIImage?) {
        guard let image = image else { return }
        let resizedImage = image.resizedToMaxSize(maxWidth: maxWidth, maxHeight: maxHeight)
        titleImage.image = resizedImage
        
        // 이미지 크기에 맞게 이미지뷰 제약 조건 재설정
        titleImage.snp.remakeConstraints { make in
            make.top.equalTo(topStackView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            
            // 이미지 실제 크기를 유지하되 최대 크기 제한
            let imageSize = resizedImage.size
            make.width.equalTo(imageSize.width).priority(.high)
            make.height.equalTo(imageSize.height).priority(.high)
            
            // 너무 커지지 않도록 최대 제한
            make.width.lessThanOrEqualTo(maxWidth).priority(.required)
            make.height.lessThanOrEqualTo(maxHeight).priority(.required)
            
            // 화면 밖으로 튀어나가지 않도록 (안전하게 양수 값으로 설정)
            make.width.lessThanOrEqualTo(max(20, self.frame.width - 40)).priority(.required)
        }
        
        // 이미지 크기가 변경되면 레이아웃을 업데이트
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupUI() {
        backgroundColor = UIColor(named: "BackgroundColor")
        
        // 뷰 크기가 0이면 기본값 설정 (레이아웃 경고 방지)
        if frame.width <= 0 {
            frame.size.width = UIScreen.main.bounds.width
        }
        
        // 스크롤 뷰 설정
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        // 컨텐츠 뷰 설정
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide) // 중요: 스크롤 뷰와 동일한 너비
        }
        
        // 상단 스택 뷰 (타이틀, 생성 시간, 업데이트 시간)
        contentView.addSubview(topStackView)
        topStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 이미지 뷰 (스택 뷰의 일부가 아닌 독립적으로 배치)
        contentView.addSubview(titleImage)
        titleImage.snp.makeConstraints { make in
            make.top.equalTo(topStackView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            
            // 기본 이미지 크기 설정 (이미지가 없을 때)
            make.width.equalTo(300).priority(.high)
            make.height.equalTo(300).priority(.high)
            
            // 최대 크기 제한
            make.width.lessThanOrEqualTo(maxWidth).priority(.required)
            make.height.lessThanOrEqualTo(maxHeight).priority(.required)
            
            // 화면 밖으로 튀어나가지 않도록 (안전하게 양수 값으로 설정)
            make.width.lessThanOrEqualTo(max(20, self.frame.width - 40)).priority(.required)
        }
        
        // 하단 스택 뷰 (버튼 스택, 컨텐트 텍스트, 추가 버튼)
        contentView.addSubview(bottomStackView)
        bottomStackView.snp.makeConstraints { make in
            make.top.equalTo(titleImage.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 개별 요소 설정
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        
        createdTimeLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        updatedTimeLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        contentText.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
        addButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
}
