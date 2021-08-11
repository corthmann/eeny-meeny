eeny-meeny
==========================
[![Gem Version](https://badge.fury.io/rb/eeny-meeny.svg)](https://badge.fury.io/rb/eeny-meeny)
[![Code Climate](https://codeclimate.com/github/corthmann/eeny-meeny/badges/gpa.svg)](https://codeclimate.com/github/corthmann/eeny-meeny)
[![Test Coverage](https://codeclimate.com/github/corthmann/eeny-meeny/badges/coverage.svg)](https://codeclimate.com/github/corthmann/eeny-meeny/coverage)
[![Build Status](https://travis-ci.com/corthmann/eeny-meeny.svg?branch=master)](https://travis-ci.com/corthmann/eeny-meeny)

Installation
-------------
You can install this gem by using the following command:
```
gem install eeny-meeny
```
or by adding the the following line to your Gemfile.
```
gem 'eeny-meeny'
```

Configuration
-------------
`eeny-meeny` should be configured in your Rails environment file. Preferably loaded through `secrets.yml`

The following configurations are available:

* `cookies` Defaults to `{ http_only: true, path: '/', same_site: :strict }`. Sets the eeny-meeny cookie attributes. The valid attributes are listed in the section below.
* `secure`  Defaults to `true`. Determines if eeny-meeny cookies should be encrypted or not.
* `secret`  Sets the secret used for encrypting experiment cookies.
* `query_parameters` Defaults to `{ experiment: true, smoke_test: true }`. Controls whether experiments variations and smoke tests can be triggered through query parameters.
* `experiments` Defaults to `{}`. It is easiest to load this from a `.yml` file with `YAML.load_file(File.join('config','experiments.yml'))`. The YAML file should have a structure matching the following example:

```
:experiment_1:
  :name: Awesome Experiment
  :version: 1
  :start_at: '2026-08-11T11:55:40Z'
  :end_at: '2026-08-11T11:55:40Z'
  :variations:
    :a:
      :name: Variation A
      :weight: 0.8
      :custom_attribute: A rocks, B sucks
    :b:
      :name: Variation B
      :weight: 0.2
      :custom_attribute: B is an all-star!
```

Valid cookie attributes:

* `domain` Sets the domain scope for the eeny-meeny cookies.
* `expires` Sets the date/time where the cookie gets deleted from the browser. If `end_at` have been specified for the experiment, then the `end_at` time will be used. Otherwise this value will default to `1.month.from_now`.
* `httponly` Directs browsers not to expose cookies through channels other than HTTP (and HTTPS) requests.
* `max_age` Can be used to set the cookie's expiration as an interval of seconds in the future, relative to the time the browser received the cookie.
* `path` Sets the `path` cookie attribute. If this configuration is set to `nil` it means that each page will get its own cookie.
* `same_site` Accepts: `:strict`, `:lax` and `nil`. Sets the `SameSite` cookie attribute. Selecting `nil` will disable the header on the cookie.
* `secure` Is meant to keep cookie communication limited to encrypted transmission, directing browsers to use cookies only via secure/encrypted connections.

You can find more information about cookie attributes at: https://en.wikipedia.org/wiki/HTTP_cookie#Cookie_attributes

Example configuration in Rails environment file:
```
# load experiments and set secret. Use default cookies configuration.
config.eeny_meeny = {
      experiments: YAML.load_file(File.join('config','experiments.yml')),
      secret: 'my secret'
  }
# disable encryption, httponly and set same_site to :lax.
config.eeny_meeny = {
      cookies:  { httponly: false, path: '/', same_site: :lax },
      experiments: YAML.load_file(File.join('config','experiments.yml')),
      secure: false
  }
```
Example configuration from initializer:
```
# load experiments and set secret. Use default cookies configuration.
EenyMeeny.configure do |config|
    config.experiments = YAML.load_file(File.join('config','experiments.yml'))
    config.secret      = 'my secret'
end
```

Helpers
-------------
`eeny-meeny` adds the following helpers to your controllers and views:

* `participates_in?(experiement_id, variation_id: nil)` Returns the chosen variation for the current user if he participates in the experiment. Otherwise it returns `nil`.
* `smoke_test?(smoke_test_id, version: 1)` If the current user has a valid cookie for the smoke test that cookie value is returned. Otherwise it returns `nil`.

Route Constraints
-------------
`eeny-meeny` allows you to use the following route constraints:

* `EenyMeeny::ExperimentConstraint` allows you to route participants of an experiment and/or experiment variation to a different route than non-participants.
* `EenyMeeny::SmokeTestConstraint` allows you to route traffic from users with a smoke test cookie to a different route than non-participants.

In order to use the route constraints you need to require them in `routes.rb` (e.g. `require 'eeny-meeny/routing/experiment_constraint'` and `require 'eeny-meeny/routing/smoke_test_constraint'`)

Rake tasks
-------------
`eeny-meeny` adds the following rake tasks to your project.

* `eeny_meeny:cookie:experiment[experiment_id]`. Creates and outputs a valid cookie for the given experiment id.
* `eeny_meeny:cookie:experiment_variation[experiment_id,variation_id]` creates and outputs a valid cookie for the given variation of the experiment with the given experiment_id.
* `eeny_meeny:cookie:smoke_test[smoke_test_id,version]` Creates and outputs a valid smoke test cookie for a smoke test with the given id and version. `version` will default to `1` if not given.

You can execute the rake tasks like this:

* `rake eeny_meeny:cookie:experimet[experiment_id]`
* `rake eeny_meeny:cookie:experimet_variation[experiment_id, a]`
* `rake eeny_meeny:cookie:smoke_test[shadow]`
* `rake eeny_meeny:cookie:smoke_test[shadow,2]`

You can add the resulting cookie to your browser by copying the cookie string and use the following command in the JS console of your browser.

```
document.cookie = '<cookie string excluding httponly>';
```

Please note that the `HttpOnly` attribute will prevent you from adding the cookie to your browser through JS. You will therefor have to remove the `HttpOnly` part of the cookie string before adding the cookie to your browser.

Query parameters
-------------
By default it is possible to trigger smoke tests and experiment variations through query parameters.

Executing a request to `/?smoke_test_id=my_secret` will trigger the `my_secret` smoke test.

Executing a request to `/?eeny_meeny_my_page_v1=old` will trigger the `old` varition of the `my_page` experiment.

For experiments the parameter needs to match the pattern `eeny_meeny_<experiment_id>_v<experiment_version>=<variation_id>`

Please note that this behavior can be disabled through the `query_parameters` configuration.

Setting up Experiments
-------------
It is easiest to define your experiments in YAML files and load them with as shown in the **Configuration** section.

When setting up a new experiment you need to provide the following information:

* `experiment_id` This is the key that encapsulates the rest of your experiment configuration in the YAML file (see `:experiment_1:` the **Configuration** section).
* `name` The name/title of your experiment.
* `version` (optional) the version of your experiment. Defaults to `1`.
* `start_at` (optional) the start time of your experiment. Will enable the experiment at the given time.
* `end_at` (optional) the end time of your experiment. Will disable the experiment at the given time.
* `variations` The set of variations to be included in your experiment (see options for variations below).

A variation needs the following information:

* `variation_id` This is the key that encapsulates the rest of your variation configuration in the YAML file (see `:a:` the **Configuration** section).
* `name` The name/title of your varition.
* `weight` The weight of the variation. Defaults to `1`. This can be a floating or integer number. The final weight of the variation will be `weight / sum_of_variation_weights`.

You can define additional variation attributes as part of the experiment configuration. These attributes will be accessible as a `Hash` returned from the `options` method on variation objects.

If you want to force all your users to get their experiment cookie updated, then you can change the `version` option on your experiment. This might for instance be useful if you want to remove an under-performing variation from your experiment. Or when gradually rolling a feature out to the public.

Split testing
-------------
The `eeny-meeny` gem can be used to split test features in your Rails application. The goal of split testing is to test a new feature/design/component on your website on a selected fraction of the website sessions and measure its performance.

With `eeny-meeny` you are able to testing multiple variations and select the weight of each experiment variation. This allows you to fine-tune your experiment and gradually roll a change out to your users.

If you want to render a different partial as for users that participates in a specific variation of your experiment, then you can use the `participates_in?(experiment_id, variation_id: variation_id)` helper in your view.

```
...
%div.content
    - if participates_in?(:my_experiment, variation_id: :my_variation)
        = render 'my_variation_partial'
    - else
        = render 'normal_partial'
```

If you want to do slightly different things in your controller for users that participates in a variation of your experiment, then you can do as follows:

```
def show
    if participates_in?(:my_experiment, variation_id: :my_variation)
        # variation specific code
    else
        # normal code
    end
end
```

It is also possible to use `participates_in?(:my_experiment)` to get the variation that the user participates in; and possible show the data stored in the experiment variation.

Full page split tests
-------------
If you want to completely redesign a page but test it in production as a split test against your old page, using identical routes, then it can be achieved as follows:

 1. Create an experiment like this:

    ```
    :example_page:
        :name: Test V1 vs. V2
        :v1:
            :name: First version of the page
            :weight: 0.9
        :v2:
            :name: Second version of the page
            :weight: 0.1
    ```

 2. Namespace your controller and views (ex. `ExamplesController` becommes `V1::ExamplesController` )
 3. Copy the route(s) for `ExamplesController` and use `controller: 'v1/examples`
 4. Add `require 'eeny-meeny/routing/experiment_constraint` to `routes.rb`
 4. Surround your `v1/examples` route(s) with the following constraint:

    ```
    constraints(EenyMeeny::ExperimentConstraint.new(:example_page, variation_id: :v1) do
        # your v1 routes goes here.
    end
    ```

Now 90% of the users will experience V1 and 10% will experience V2.

Measuring your results
-------------
`eeny-meeny` leaves the choice of how to measure your results entirely in your hands.

If you track via Google Analytics (GA) or Google Tag Manager (GTM) then add markup / js events to the pages you render and measure the results in the Google Analytics interface.

If you prefer to track results / conversions in a different system then use the `participates_in?` helper to learn the user variation and send an event to your preferred analytics tool from your controller or from JS in the browser.

Smoke testing
-------------
The `eeny-meeny` gem can be used to let you test features in production without your users seeing them. It also allows you to keep hidden features in production that only will be available to the selected few that have a valid encrypted smoke test cookie in their browser.

If you want a specific route to only be available as a smoke test, then you can add the following route.

    ```
    constraints(EenyMeeny::SmokeTestConstraint.new(:shadow_test) do
        # your 'shadow test' routes
    end
    ```

If you want to render a different partial as a smoke test, then you can use the `smoke_test?(smoke_test_id)` helper in your view.

```
...
%div.content
    - if smoke_test?(:shadow_test)
        = render 'smoke_test_partial'
    - else
        = render 'normal_partial'
```

If you want to do slightly different things in your controller as a smoke test, then you can do as follows:

```
def show
    if smoke_test?(:shadow_test)
        # smoke test specific code
    else
        # normal code
    end
end
```

Special thanks
-------------
As part of building this gem I borrowed the `Encryptor` class from the `encrypted_cookie` gem (https://github.com/cvonkleist/encrypted_cookie)

All credits for the cookie encryption goes to that project.
