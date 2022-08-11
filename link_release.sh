#!/usr/bin/env bash
TEMPLATE_FILE="template.json"

echo "Generating new $VERSION release for $NAME"

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
