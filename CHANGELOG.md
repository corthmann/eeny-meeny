### 2.3.0 (2021-08-10)

Changes:

    - Support Rails 6 (PR: #11).
    - Remove cookies for previous experiment versions (PR: #12).
    - Update Travis configuration to include Ruby version 2.6 to 2.7.

### 2.2.2 (2019-04-08)

Bugfixes:

    - Handle scenario where EenyMeeny is configured with an empty experiments file (https://github.com/corthmann/eeny-meeny/issues/9)

Other Changes:

    - Update development dependency "yard" in .gemspec file

### 2.2.1 (2018-09-09)

Changes:

    - Fix `OpenSSL::Cipher::Cipher` deprecation warning in `EenyMeeny::Encryptor`.
    - Update Travis configuration to include Ruby version 2.2 to 2.5.

### 2.2.0 (2018-07-24)

Features:

    - Let `Eeny::Meeny::Middleware` remove deprecated experiment cookies (for undefined and inactive experiements)

Changes:

    - Renamed `EenyMeeny::Cookie::COOKIE_PREFIX` to `EenyMeeny::Cookie::EXPERIMENT_PREFIX`

### 2.1.4 (2017-10-04)

Changes:

    - Update gem dependencies for Rails 5 support.

### 2.1.3 (2017-08-15)

Bugfixes:

    - Fix issue where the global cookie configuration is not applied to smoke test cookies.

### 2.1.2 (2017-04-14)

Bugfixes:

    - Fix validation regex for the 'smoke_test_id' query parameter.

Other Changes:

    - Clean up the way cookies are written to the HTTP_COOKIE header.
    - Added Travis CI and build status badge.

### 2.1.1 (2016-10-06)

Bugfixes:

    - Fix bug in `participates_in?` helper that prevented it from working when the `variation_id` was sent as a symbol.
    - Fix bug in `EenyMeeny::ExperimentConstraint` that prevented it from working when the `variation_id` was sent as a symbol.

### 2.1.0 (2016-10-02)

Features:

    - Trigger experiment variations with query parameters
    - Trigger smoke tests with query parameters

Bugfixes:

    - Fixed error that caused 'participates_in?' to throw error when the given experiment_id did not exist.

Other Changes:

    - Reduced size of experiment cookies. Now only the picked variation_id is stored in the cookie itself.

### 2.0.0 (2016-09-11)

Features:

    - Added helper and route constraint for smoke tests.
    - Added rake tasks for creating eeny-meeny cookies from the commandline.

Bugfixes:

    - Fixed experiment start_at and end_at logic.

Breaking Changes:

    - Changed the way the gem is configured.
    - Replaced EenyMeeny::RouteConstraint with EenyMeeny::ExperimentConstraint and EenyMeeny::SmokeTestConstraint.

Other Changes:

    - Changed default cookie expires header from '1.year.from_now' to '1.month.from_now'.
    - Improve docuemtation.

### 1.0.0 (2016-07-03)

Features:

    - Initial version of split testing tool. Includes:
        - Experiment helpers for Rails
        - Run any number of experiments at the same time.
        - Have any number of variations in each experiment.
        - Set the weight (likelyhood of participants excountering) each experiment variation customly.
        - Encrypt experiment cookies.
        - Route constraint for full page split tests.
