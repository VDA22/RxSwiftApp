//: [Previous](@previous)

import PlaygroundSupport
import UIKit
import RxSwift
import RxCocoa

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)

class ViewController: UIViewController {
	private let textField = UITextField()
	private let button = UIButton()

	let disposeBag = DisposeBag()
	let textFieldText = BehaviorRelay(value: "")
	let buttonSubject = PublishSubject<String>()

	override func loadView() {
		let view = UIView()
		view.backgroundColor = .white

		view.addSubview(textField)
		view.addSubview(button)
		// Layout
		textField.translatesAutoresizingMaskIntoConstraints = false
		button.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([

			textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
			textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			textField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			textField.trailingAnchor.constraint(equalTo: view.trailingAnchor),

			button.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
			button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			button.trailingAnchor.constraint(equalTo: view.trailingAnchor),

		])

		self.view = view
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		textField.backgroundColor = .red
		button.setTitle("Button", for: .normal)
		button.backgroundColor = .blue

		textField.rx.text
			.orEmpty
			.bind(to: textFieldText)
			.disposed(by: disposeBag)

//		textField.rx.text.asDriver()
//			.map({ print($0) })
//			.drive()
//			.disposed(by: disposeBag)

		textFieldText
//			.asObservable()
			.subscribe(onNext: {
				print("Text: ", $0)
//				self.textField.text = $0
			})
			.disposed(by: disposeBag)



		button.rx.tap
			.map({ "Button tapped" })
			.bind(to: buttonSubject)
			.disposed(by: disposeBag)
		buttonSubject
//			.asObservable()
			.subscribe(onNext: {
				print("ButtonSubject: ", $0)
				self.textFieldText.accept($0)
			})
			.disposed(by: disposeBag)
	}
}

PlaygroundPage.current.liveView = ViewController()

