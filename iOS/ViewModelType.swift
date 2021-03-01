/// The view model protocol that helps us unify the way
/// we organizing the input and the output for the view models.
/// Your newly created view models should conform to this protocol.
protocol ViewModelType {
  associatedtype Input
  associatedtype Output

  func transform(_ input: Input) -> Output
}
