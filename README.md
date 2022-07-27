# swift-cli-publisher

Action to sync release updates to [registrar](https://github.com/swift-nav/package-registry)

---

## Table of Content

- [What it do?](#what-it-do)
- [Inputs](#inputs)
    - [Authentication Inputs](#authentication-inputs)
    - [Release metadata](#release-metadata)
        - [Autofilled Variables](#autofilled-variables)
        - [Environment Variables](#environment-variables)
            - [Required flags](#required)
            - [Optional flags](#optional)
- [Usage](#usage)
    - [Example](#example)

---

## What it do?

Composite action aimed at hooking into release workflows of registered packages and
automatically creating a pull request in the registrar.

Generates templated metadata via jq (don't have to install excess tools) and inserts
into the registry

Requires GitHub account to which pull request is created from

---

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

#### Autofilled Variables

- `NAME` is provided via repository context from caller
- `VERSION` is provided via repository context from caller

#### Environment Variables

##### Required

- `DIR_(LINUX|MAC|WIN)`: the base directory array of binary of each OS
    - `DIR_LINUX` - linux module
    - `DIR_MAC` - macOS module
    - `DIR_WIN` - windows module
- `DL_(LINUX|MAC|WIN)` the paths/names array to download binaries for each OS
    - `DL_LINUX` - linux module
    - `DL_MAC` - macOS module
    - `DL_WIN` - windows module
- `TOOLS` is the tool names, provided as string delimited by `,`

##### Optional

- `BASE_URL` corresponds to web download URL, providing this parameter opts for Web instead of GitHub
- `PROJECT_SLUG` in the format "ORG/NAME", defaults to `swift-nav/$NAME`
- `LINKED` not sure what this is to be honest, defaults to false

---

## Usage

```yml
# Pull this script from marketplace
- name: "Publish to package registry"
  uses: swift-nav/swift-cli-publisher@v1
  env:
    DIR_LINUX: "dir+linux"
    DIR_MAC: "dir+mac"
    DIR_WIN: "dir+win"
    DL_LINUX: "dl+linux"
    DL_MAC: "dl+mac"
    DL_WIN: "dl+win"
    TOOLS: "tool1,tool2"
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    gh-name: ${{ secrets.GITHUB_NAME }}
    gh-email: ${{ secrets.GITHUB_EMAIL }}
```

### Example

See real example in [main.yml](https://github.com/swift-nav/publish-test-adrian/blob/main/.github/workflows/main.yml)
