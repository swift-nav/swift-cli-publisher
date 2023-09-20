# swift-cli-publisher

Action to sync release updates to the [package registry](https://github.com/swift-nav/package-registry)

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
automatically creating a pull request in the package registry.

Pulls swift-cli's serde_json serialized Package struct passed via environment variables.

Since most packages already uses the following template, the future will also follow this to reduce refactoring.

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

+ 'aws-access-key-id':
Optional: AWS access key ID used to provide access to the s3 bucket where the package is
stored. Only required if using to publish binaries from an s3 bucket.

+ 'aws-secret-access-key':
Optional: AWS secret access key used to provide access to the s3 bucket where the package
is stored. Only required if using to publish binaries from an s3 bucket.

+ 'aws-access-region':
Optional: AWS region to be used by the access key to log in. Only required if using to
publish binaries from an s3 bucket.
```

### Release metadata

Passed as environment variables, using rust binary (hardcoded with env vars) :( template derived
from [swift-cli](https://github.com/swift-nav/swift-cli/blob/e6c6e72e76b89f99b2684ec6703dff0c60a3737b/swift/src/types.rs#L18)

#### Autofilled Variables

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
- `(DL|DIR)_(LINUX|MAC|WIN)_(x86_64|aarch64|arm)` is the general pattern for arch specific entries
  - i.e. if you need aarch64 support for linux in downloads it would be `DL_LINUX_aarch64`
- `LINKED_TOOLS` are the tool names that are linked into `~/.local/bin`, provided as string delimited by `,`
- `UNLINKED_TOOLS` are the tool names that are *NOT* linked into `~/.local/bin`, provided as string delimited by `,`
- `TOOLS` (deprecated) are the tool names, provided as string delimited by `,` -- these are by default linked into `~/.local/bin`

##### Optional

Most "required" are also optional i.e. you don't need all 3 platforms

- `NAME` corresponds to repository name, defaults to repo name where it is called from
- `VERSION` corresponds to tag, defaults to tag where it is called from
- `BASE_URL` corresponds to web download URL, providing this parameter opts for Web instead of GitHub
- `PROJECT_SLUG` in the format "ORG/NAME", defaults to `swift-nav/$NAME`
- `LINKED` (deprecated) not used

If the package is going to be pulled in from an S3 bucket, the following must all be set

- `TOOL_SPECIFIC_SHA` will generate a SHA for each tool, not just the archive if any
   non-empty value is given.
- `S3_REGION` the region of the bucket that contains the package
- `S3_BUCKET` Name of the bucket
- `S3_PREFIX` The common prefix for all the platforms. The tools will sync all files
with the prefix `<S3_PREFIX><DL_*>`, Note the lack of a joining character between
the two.

---

## Usage

```yml
# Pull this script from marketplace
- name: "Publish to package registry"
  uses: swift-nav/swift-cli-publisher@v2
  env:
    DIR_LINUX: "dir+linux"
    DIR_MAC: "dir+mac"
    DIR_WIN: "dir+win"
    DL_LINUX: "dl+linux"
    DL_MAC: "dl+mac"
    DL_WIN: "dl+win"
    # add more if needed...
    LINKED_TOOLS: "tool1,tool2"
    UNLINKED_TOOLS: "tool3"
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    gh-name: ${{ secrets.GITHUB_NAME }}
    gh-email: ${{ secrets.GITHUB_EMAIL }}
```

### Example

See real example in [main.yml](https://github.com/swift-nav/publish-test-adrian/blob/main/.github/workflows/main.yml)
