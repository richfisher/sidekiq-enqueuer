# Sidekiq Enqueuer Changes
2.0.0
-----------

- Version bump to stable after rollout to prod.


2.1.0.beta
-----------
- Drop support for Yaml-like params
- Added support for required and optional parameters based on the method definition
- Fixed issue with nil parameters being send to Jobs as `nil` strings
- Added New Exception to be raised when Required Param values are not present

2.0.0.beta
-----------

- Added configutation option: Provides a list of Jobs to display
- Dropped support for manual 'unlock'
- Sidekiq enqueing now uses `Sidekiq::Client.enqueue_to / enqueue_to_in` to a custom queue.
- Refactor on classes and modules to bring Atomicity


1.0.6
-----------

- Jobs are sorted by name by default


1.0.4
-----------

- Support for jobs without arguments


1.0.3
-----------

- Support unlock! for sidekiq-middleware
