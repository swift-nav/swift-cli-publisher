#!/usr/bin/env bash
TEMPLATE_FILE="template.json"

echo "Generating new $VERSION release for $NAME"

# calculate local shas for binaries of each supported os. If a file does not exist, leave field blank.
sha_linux=""
sha_macos=""
sha_windows=""
if test -f "${DL_LINUX}";
then 
  echo hello
  sha_linux=shasum -a 256 "$DL_LINUX"
fi

if test -f "${DL_MACOS}";
then 
  echo hello
  sha_macos=shasum -a 256 "$DL_MACOS"
fi

if test -f "${DL_WIN}";
then 
  echo hello
  sha_windows=shasum -a 256 "$DL_WIN"
fi

# Should probably use serialization from Package struct
NEW_RELEASE=$(jq \
  --arg name "$NAME" \
  --arg version "$VERSION" \ 
  \
  --arg dir_linux "${DIR_LINUX}" \
  --arg dir_mac "${DIR_MAC}" \
  --arg dir_win "${DIR_WIN}" \
  \
  --arg base_url "${BASE_URL}" \
  --arg project_slug "${PROJECT_SLUG:="swift-nav/$NAME"}" \
  --arg dl_linux "${DL_LINUX}" \
  --arg dl_mac "${DL_MAC}" \
  --arg dl_win "${DL_WIN}" \
  \
  --arg tools "${TOOLS}" \
  --argjson linked "${LINKED:=false}" \
  --compact-output \
  '.name=$name
  | .version=$version

  | .base_dir.linux=$dir_linux
  | .base_dir.macos=$dir_mac
  | .base_dir.windows=$dir_win

  | .sha256.linux=sha_linux
  | .sha256.macos=sha_macos
  | .sha256.windows=sha_windows

  | if $base_url=="" then
  (
    .download.GitHub.project_slug=$project_slug
    | .download.GitHub.linux=$dl_linux
    | .download.GitHub.macos=$dl_mac
    | .download.GitHub.windows=$dl_win
  )
  else
  (
    .download.Web.base_url=$base_url
    | .download.Web.linux=$dl_linux
    | .download.Web.macos=$dl_mac
    | .download.Web.windows=$dl_win
  )
  end

  | .tools=($tools | split(","))
  | .linked=$linked' \
  $TEMPLATE_FILE)

printf "%s\n" "$NEW_RELEASE" >> data/"${NAME,,}"
