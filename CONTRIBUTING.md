**Contributing to Mamba**
=================

Thanks for your interest in this project!

This document consists of guidelines to assist you in contributing to this open source project.

Things to know before getting started
-------------------------------------

#### Design and Scope

If you have an idea for a feature, improvement or bug fix, you may want to discuss with us first by submitting an [issue](https://github.com/comcast/mamba/issues) before doing the actual work. This is particularly true with ideas that might expand the scope of mamba beyond its mission of parsing, validating and writing HTTP Live Streaming (HLS) playlists.

Contributing
-------------------------------------

We would love to read your pull request. The team at Comcast is focused on making this project work for our customers and environment, but would love for this project to support as many people and projects as possible. We cannot do that without contributions from other teams and individuals.

By participating in this project, you are agreed to abide by our [code of conduct](https://github.com/comcast/mamba/blob/develop/CODE_OF_CONDUCT.md)

Your code doesn't have to be perfect! Do your best (try to follow our [guidelines](https://github.com/comcast/mamba/blob/develop/CONTRIBUTING.md#guidelines)) and submit a [pull request](https://github.com/comcast/mamba/pulls). We'll work with you to make sure it fits properly into the project. (If you've never made a pull request, it's simple. Github has a tutorial [here](https://help.github.com/articles/using-pull-requests/).)

Guidelines
----------
Following the project conventions will make the pull request process go faster and smoother.

#### Coding Standards

We try to follow the swift.org [style guidelines](https://swift.org/documentation/api-design-guidelines/)

All code should be in Swift 4 (unless fixing something in the C/Objective-C Parsing code).

Methods should be short. Try to make your changes look like the surrounding code.

All public methods and data should be [documented](http://nshipster.com/swift-documentation/)

#### One pull request per feature

Make each pull request as small as possible. For example, if you're adding three validation improvements, make each a separate pull request. If you're adding interdependent or related changes, make a pull request for each, starting at the lowest level.

#### Tests

Make sure all existing tests pass. If you change the way something works, be sure to update tests to reflect the change. Add unit tests for new code.

Tests should cover both "happy path" and failure scenarios.

Every line of code that can be tested should be tested.

#### Commit messages

Try to make your commit messages follow [git best practices](http://chris.beams.io/posts/git-commit/).

1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain what and why vs. how

This makes it easier for people to read and understand what each commit does, on both the command line interface and Github.com.

---

Don't let all these guidelines discourage you. We're more interested in community involvement than perfection.

Thanks again for your support!