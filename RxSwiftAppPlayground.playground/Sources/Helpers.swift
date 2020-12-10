import Foundation

public func example(_ rxOperator: String, action: () -> Void) {
	print("\n--- Example of: ", rxOperator, "---")
	action()
}
