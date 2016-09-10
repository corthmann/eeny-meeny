### 2.0.0 (2016-09-10)

Features:

    - Add helper for smoke tests.
    - Add rake tasks for creating eeny-meeny cookies from the commandline.

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
