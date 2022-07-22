# swift-cli-publisher
Action to sync release updates to registrar

---

## Inputs

- `token`: Private access token to provide access to private repos and to create pull requests under
- `gh-name`: Github account name (needs to be fixed, defaults not working)
- `gh-email`: Github account email (needs to be fixed, defaults not working)

- `name`: Name of the package to be updated
- `version`: Version of release

## Example

```yml
# Needed to pull private repo with token
- name: Get composite run steps repository
  uses: actions/checkout@v3
  with:
    repository: swift-nav/swift-cli-publisher
    token: ${{ secrets.SWIFTNAV_TRAVIS_GITHUB_TOKEN }}

# Run the composite action
- name: Run action from private repo
  uses: ./
  with:
    name: "esthri"
    version: "1.3.0"
    token: ${{ secrets.SWIFTNAV_TRAVIS_GITHUB_TOKEN }}
```
