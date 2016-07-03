eeny-meeny
==========================
[![Code Climate](https://codeclimate.com/github/corthmann/eeny-meeny/badges/gpa.svg)](https://codeclimate.com/github/corthmann/eeny-meeny)
[![Test Coverage](https://codeclimate.com/github/corthmann/eeny-meeny/badges/coverage.svg)](https://codeclimate.com/github/corthmann/eeny-meeny/coverage)

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

* `config.eeny_meeny.cookies.path` Defaults to `'/'`. Sets the `path` cookie attribute. If this configuartion is set to `nil` it means that each page will get its own cookie.
* `config.eeny_meeny.cookies.same_site` Defaults to `:strict`. Accepts: `:strict`, `:lax` and `nil`. Sets the `SameSite` cookie attribute. Selecting `nil` will disable the header on the cookie.
* `config.eeny_meeny.secure` Boolean value. Defaults to `true` and determines if experiment cookies should be encrypted or not.
* `config.eeny_meeny.secret` sets the secret used for encrypting experiment cookies.
* `config.eeny_meeny.experiments` list of experiment-data. It is easiest to load this from a `.yml` file with the following structure:

```
:experiment_1:
  :name: Awesome Experiment
  :version: 1
  :variations:
    :a:
      :name: Variation A
      :weight: 0.8
      :options:
        :message: A rocks, B sucks
    :b:
      :name: Variation B
      :weight: 0.2
      :options:
        :message: B is an all-star!
```

Usage
-------------
`eeny-meeny` adds the following helpers to your controllers and views:

* `participates_in?(experiement_id, variation_id: nil)` Returns the chosen variation for the current user if he participates in the experiment.

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
 4. Add `require 'eeny-meeny/route_constraint` to `routes.rb`
 4. Surround your `v1/examples` route(s) with the following constraint:
    ```
    constraints(EenyMeeny::RouteConstraint.new(:example_page, variation_id: :v1) do
        # your v1 routes goes here.
    end
    ```

Now 90% of the users will experience V1 and 10% will experience V2.

Special thanks
-------------
As part of building this gem I borrowed the `Encryptor` class from the `encrypted_cookie` gem (https://github.com/cvonkleist/encrypted_cookie)

All credits for the cookie encryption goes to that project.
