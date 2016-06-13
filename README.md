eeny-meeny
==========================



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

* `config.eeny_meeny.secure` is a boolean value that determines if experiment cookies should be encrypted or not.
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

* `participates_in?(experiement_id, variation_id: nil, version: 1)` Returns the chosen variation for the current user if he participates in the experiment.

Special thanks
-------------
As part of building this gem I borrowed the `Encryptor` class from the `encrypted_cookie` gem (https://github.com/cvonkleist/encrypted_cookie)

All credits for the cookie encryption goes to that project.
