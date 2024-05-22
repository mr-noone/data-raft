import Foundation

extension DispatchQueue {
    /// Convenience initializer to create a DispatchQueue with a label based on the type name and additional parameters.
    ///
    /// This initializer creates a DispatchQueue with a label based on the type name and allows for customization
    /// of quality of service, attributes, autorelease frequency, and target queue.
    ///
    /// Example usage:
    /// ```swift
    /// let queue = DispatchQueue(for: MyClass.self, qos: .userInitiated)
    /// ```
    ///
    /// - Parameters:
    ///   - type:
    ///         The type to use for the label to uniquely identify it in debugging tools such as
    ///         Instruments, sample, stackshots, and crash reports.
    ///   - qos:
    ///         The quality-of-service level to associate with the queue.
    ///         This value determines the priority at which the system schedules tasks for execution.
    ///         Defaults to `.unspecified`.
    ///   - attributes:
    ///         The attributes to associate with the queue.
    ///         Include the concurrent attribute to create a dispatch queue that executes tasks concurrently.
    ///         If you omit that attribute, the dispatch queue executes tasks serially.
    ///         Defaults to an empty.
    ///   - autoreleaseFrequency:
    ///         The frequency with which to autorelease objects created by the blocks that the queue schedules.
    ///         Defaults to `.inherit`.
    ///   - target:
    ///         The target queue on which to execute blocks. Specify `DISPATCH_TARGET_QUEUE_DEFAULT`
    ///         if you want the system to provide a queue that is appropriate for the current object.
    ///         Defaults to `nil`.
    /// - Returns: A new DispatchQueue with a label based on the type name and specified parameters.
    convenience init<T>(
        for type: T.Type,
        qos: DispatchQoS = .unspecified,
        attributes: Attributes = [],
        autoreleaseFrequency: AutoreleaseFrequency = .inherit,
        target: DispatchQueue? = nil
    ) {
        self.init(
            label: String(describing: type),
            qos: qos,
            attributes: attributes,
            autoreleaseFrequency: autoreleaseFrequency,
            target: target
        )
    }
}
