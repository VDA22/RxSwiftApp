import PlaygroundSupport
import RxSwift
import RxCocoa
PlaygroundPage.current.needsIndefiniteExecution = true

// Observable
let intObservable = Observable.just(30)
let strObservable = Observable.just("Hello")
let arrayObservable = Observable.of(1, 2, 3)
let items = [3, 2, 1]


example("Test") {

}


example("just") {
	// Observer
	strObservable.subscribe({ (event: Event<String>) in
		print(event)
	})
}

example("of") {
	arrayObservable.subscribe {
		print($0)
	}
}

example("create") {
	Observable.from(items).subscribe {
		print($0)
	}
	Observable.from(items).subscribe(
		onNext: { event in
			print(event)
		},
		onError: { _ in
			print("error")
		},
		onCompleted: {
			print("OK")
		},
		onDisposed: {
			print("Disposed")
		})
}


example("Disposables") {
	Observable.from(items).subscribe({
		event in
		print(event)
	})
	Disposables.create()
}

example("Dispose") {
	let subscription = Observable.from(items)
	subscription.subscribe({
		event in
		print(event)
	}).dispose()

}


example("dispose bag") {
	let disposeBag = DisposeBag()
	let subscription = Observable.from(items)
	subscription.subscribe({
		event in
		print(event)
	}).disposed(by: disposeBag)
}

example("take until") {
	let stopSeq = Observable.just(0.01).delaySubscription(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance)
	let subscription = Observable.from(items).take(until: stopSeq)
	subscription.subscribe({
		print($0)
	})
}

example("filter") {
	let subscription = Observable.from(items).filter({ $0 % 2 == 0 })
	subscription.subscribe({
		event in
		print(event)
	}).dispose()
}

example("map") {
	let subscription = Observable.from(items).map({ $0 * 2})
	subscription.subscribe({
		event in
		print(event)
	}).dispose()
}

example("merge") {
	let firstSeq = Observable.of(5, 7, 8)
	let secondSeq = Observable.of(1, 2, 3)
	let bothSeq = Observable.of(firstSeq, secondSeq)

	let mergeSeq = bothSeq.merge()

	mergeSeq.subscribe({ print($0) })
}

example("Publish subject") {
	let disposeBag = DisposeBag()
	let subject = PublishSubject<String>()
	enum MyError: Error {
		case test
	}

	subject.subscribe {
		print("Sub 1 ", $0)
	}.disposed(by: disposeBag)

	subject.on(Event<String>.next("Hello"))
	subject.on(.next(" Rx"))
//	subject.onCompleted() // "останавливает" дальнейшие действия
//	subject.onError(MyError.test) // "останавливает" c error(test)
	subject.onNext(" Swift")

	subject.subscribe(onNext: {
		print("Sub 2: ", $0)
	}).disposed(by: disposeBag)
	subject.onNext(" :)")
}

example("Behavior subject") {
	let disposeBag = DisposeBag()
	let subject = BehaviorSubject(value: 1) // [1]

	let firstSubscr = subject.subscribe(onNext: {
		print("FirstSubscr", " ", #line, $0)
	}).disposed(by: disposeBag)

	subject.onNext(2) // [1, 2]
	subject.onNext(3) // [1, 2, 3]

	let secondSubscr = subject.subscribe(onNext: {
		print("SecondSubscr", " ", #line, $0) // [3]
	}).disposed(by: disposeBag)
}

example("Replay subject") {
	let disposeBag = DisposeBag()
	let subject = ReplaySubject<String>.create(bufferSize: 2)

	subject.subscribe({
		print("First: ", $0)
	}).disposed(by: disposeBag)

	subject.onNext("Hello")
	subject.onNext("Rx")
	subject.onNext("Swift")

	subject.subscribe({
		print("Second", $0)
	}).disposed(by: disposeBag)
	subject.onNext("!!!")

	let newSubject = ReplaySubject<Int>.create(bufferSize: 3)

	newSubject.onNext(1)
	newSubject.onNext(2)
	newSubject.onNext(3)
	newSubject.onNext(4)

	newSubject.subscribe({
		print("Third: ", $0)
	}).disposed(by: disposeBag)
}

example("Variables") {
	let disposeBag = DisposeBag()

//	let variable = variabl
}


example("Side effect") {
	let disposeBag = DisposeBag()

	let seq = [0, 32, 100, 300]
	let obsSeq = Observable.from(seq)

	obsSeq.do(onNext: { print("Do on \($0) F = ", terminator: "") })
		.map({ Double($0 - 32) })
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)
}


example("Variables") {
	let disposeBag = DisposeBag()

	let variable = BehaviorSubject(value: 1)
	let textFieldText = BehaviorRelay(value: "")

	variable.subscribe({ print("BehaviorSubject: ", $0) })
		.disposed(by: disposeBag)

	textFieldText.subscribe({ print("BehaviorRelay: ", $0) })
		.disposed(by: disposeBag)

	variable.onNext(2)
	textFieldText.accept("3")
}

import UIKit

example("Observe On") {
	let disposeBag = DisposeBag()
	let obs = Observable.of(items)
	/*
	obs.subscribe(
		onNext: { print("Thread: \(Thread.current)", $0) },
		onError: nil,
		onCompleted: { print("Complete") },
		onDisposed: nil)
		.disposed(by: disposeBag)

	obs.observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
		.subscribe(
			onNext: { print("Thread: \(Thread.current)", $0) },
			onError: nil,
			onCompleted: { print("Complete") },
			onDisposed: nil)
		.disposed(by: disposeBag)
	*/
	let queue1 = DispatchQueue.global(qos: .default)
	let queue2 = DispatchQueue.global(qos: .default)

	print("Init thread \(Thread.current)")
	_ = Observable<Int>.create({
		(observer) -> Disposable in
		print("Observable thread: \(Thread.current)")

		observer.on(.next(1))
		observer.onNext(2)
		observer.onNext(3)

		return Disposables.create()
	})
	.subscribe(on: SerialDispatchQueueScheduler.init(internalSerialQueueName: "queue1"))
	.observe(on: SerialDispatchQueueScheduler.init(internalSerialQueueName: "queue2"))
	.subscribe(onNext: {
		print("Observable thread: \(Thread.current)", " ", $0)
	})
}
