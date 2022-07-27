# swift-cli-publisher

Action to sync release updates to [registrar](https://github.com/swift-nav/package-registry)

---

## Table of Content

- [What it do?](#what-it-do)
- [Inputs](#inputs)
    - [Authentication Inputs](#authentication-inputs)
    - [Release metadata](#release-metadata)
        - [Environment Variables](#environment-variables)
- [Usage](#usage)
    - [Example](#example)

---

## What it do?

Composite action aimed at hooking into release workflows of registered packages and
automatically creating a pull request in the registrar.

Generates templated metadata via jq (don't have to install excess tools) and inserts
into the registry

Requires GitHub account to which pull request is created from

## Inputs

### Authentication Inputs

```diff
+ 'token': 
Private access token to provide access to private repos and to create pull requests under

+ 'gh-name': 
Github account name

+ 'gh-email': 
Github account email
```

### Release metadata

Passed as environment variables, currently uses jq to create hardcoded :( template derived
from [swift-cli](https://github.com/swift-nav/swift-cli/blob/e6c6e72e76b89f99b2684ec6703dff0c60a3737b/swift/src/types.rs#L18)
as being the simplest choice (assumes no modifications to template) without actually pulling swift-cli
and serializing Package struct

#### Environment Variables

- `NAME` is provided via repository context from caller
- `VERSION` is provided via repository context from caller
- `BASE_DIR` the base directory array of binary of each OS
    - Indexes:
        - `0` - linux module
        - `1` - macOS module
        - `2` - windows module
- `BASE_URL` corresponds to web download URL, providing this parameter opts for Web instead of GitHub
- `PROJECT_SLUG` is autofilled with swift-nav owner unless provided otherwise
- `DOWNLOAD_FILES` the paths/names array to download binaries for each OS
    - Indexes:
        - `0` - linux module
        - `1` - macOS module
        - `2` - windows module
- `TOOLS` is the tool names, provided as string delimited by `,`
- `LINKED` not sure what this is to be honest

## Usage

```yml
- name: "Publish to package registry"
  uses: swift-nav/swift-cli-publisher@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    gh-name: ${{ secrets.GITHUB_NAME }}
    gh-email: ${{ secrets.GITHUB_EMAIL }}
```

### Example

See real example in [main.yml](https://github.com/swift-nav/publish-test-adrian/blob/main/.github/workflows/main.yml)
