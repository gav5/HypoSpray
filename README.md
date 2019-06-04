#  HypoSpray Dependency Injection

### Example Usage
```swift
final class SomeLazyDependency: LazyDependency {}
final class SomeStrongDependency: StrongDependency {}

struct MyThing {
    @LazyInject var someLazyDependency: SomeLazyDependency
    @StrongInject var someStrongDependency: SomeStrongDependency
}
```
