# Contributing to Socrata Habitat Plans

Issue submissions and pull requests are welcome. Keep in mind that these plans may be opinionated to our particular use. As such, we will mostly accept pull request to, say, fix bugs or add additional config options. We may be less inclined, however, to merge pull requests that change default behaviors in ways incompatible with our usage.

## Submitting Issues

Not every contribution comes in the form of code. Submitting, confirming, and triaging issues is an important task for any project. New issues for Socrata Habitat plans can be submitted via GitHub.

## Contributing Process

Contributions can be submitted via GitHub pull requests. See [this article](https://help.github.com/articles/about-pull-requests/) if you're not familiar with GitHub Pull Requests. In brief:

1. Fork the project's repo in GitHub.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Add code and tests for the new feature.
4. Ensure all tests pass (`HAB_PLAN=<plan_name> test/full.sh`).
5. Add a brief description of the change to `CHANGELOG.md`.
6. Commit your changes (`git commit -am 'Add some feature'`).
7. Push the branch to GitHub (`git push origin my-new-feature`).
8. Create a new pull request.
9. Ensure the build process for the pull request succeeds.
10. Enjoy life until the change can be reviewed by a project maintainer.
