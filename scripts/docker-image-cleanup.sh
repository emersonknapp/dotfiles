#!/usr/bin/env bash
#
# Interactive docker image cleanup.
#
# Walks through every image in `docker images`, prompting keep/remove/finish for
# each, builds a removal list, confirms it, then `docker rmi`s the selected images.
#
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found on PATH" >&2
  exit 1
fi

# Read prompts from the terminal, not stdin, so this behaves under pipes too.
if [[ -r /dev/tty ]]; then
  exec 3</dev/tty
else
  exec 3<&0
fi

# Colors (only if stdout is a tty).
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; GREEN=$'\033[32m'; RED=$'\033[31m'; YELLOW=$'\033[33m'; RESET=$'\033[0m'
else
  BOLD=''; DIM=''; GREEN=''; RED=''; YELLOW=''; RESET=''
fi

# Each line: "<ref>\t<id>\t<repo:tag>\t<size>\t<created>"
# <ref> is what we pass to `docker rmi`: repo:tag when named, else the image ID.
mapfile -t IMAGES < <(
  docker images --format '{{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedSince}}' \
    | while IFS=$'\t' read -r reptag id size created; do
        if [[ "$reptag" == "<none>:<none>" ]]; then
          ref="$id"
          reptag="<none> (dangling)"
        else
          ref="$reptag"
        fi
        printf '%s\t%s\t%s\t%s\t%s\n' "$ref" "$id" "$reptag" "$size" "$created"
      done
)

if [[ ${#IMAGES[@]} -eq 0 ]]; then
  echo "No docker images found. Nothing to do."
  exit 0
fi

echo "${BOLD}Found ${#IMAGES[@]} docker image(s).${RESET}"
echo "For each: ${GREEN}Enter/k${RESET}=keep (default)  ${RED}r${RESET}=remove  ${YELLOW}f${RESET}=finish (stop prompting)"
echo

declare -a TO_REMOVE_REF=()
declare -a TO_REMOVE_LABEL=()

idx=0
total=${#IMAGES[@]}
for line in "${IMAGES[@]}"; do
  idx=$((idx + 1))
  IFS=$'\t' read -r ref id reptag size created <<<"$line"

  label="$reptag  ${DIM}($id, $size, $created)${RESET}"
  printf '%s[%d/%d]%s %s\n' "$BOLD" "$idx" "$total" "$RESET" "$label"

  while true; do
    printf '   %skeep%s / %sremove%s / %sfinish%s [K/r/f]: ' "$GREEN" "$RESET" "$RED" "$RESET" "$YELLOW" "$RESET"
    read -r -u 3 answer || answer=""
    case "${answer,,}" in
      ""|k|keep)
        echo "   ${GREEN}kept${RESET}"
        break
        ;;
      r|remove)
        TO_REMOVE_REF+=("$ref")
        TO_REMOVE_LABEL+=("$reptag  ${DIM}($id, $size)${RESET}")
        echo "   ${RED}marked for removal${RESET}"
        break
        ;;
      f|finish)
        echo "   ${YELLOW}finished prompting${RESET}"
        break 2
        ;;
      *)
        echo "   ${DIM}unrecognized; enter k, r, or f${RESET}"
        ;;
    esac
  done
done

echo
if [[ ${#TO_REMOVE_REF[@]} -eq 0 ]]; then
  echo "No images marked for removal. Done."
  exit 0
fi

echo "${BOLD}The following ${#TO_REMOVE_REF[@]} image(s) will be removed:${RESET}"
for lbl in "${TO_REMOVE_LABEL[@]}"; do
  echo "  ${RED}-${RESET} $lbl"
done
echo

printf '%sProceed with docker rmi?%s [Y/n]: ' "$BOLD" "$RESET"
read -r -u 3 confirm || confirm=""
case "${confirm,,}" in
  ""|y|yes) ;;
  *)
    echo "Aborted. No images removed."
    exit 0
    ;;
esac

echo
removed=0
failed=0
for i in "${!TO_REMOVE_REF[@]}"; do
  ref="${TO_REMOVE_REF[$i]}"
  lbl="${TO_REMOVE_LABEL[$i]}"
  printf 'Removing %s ... ' "$lbl"
  if docker rmi "$ref" >/dev/null 2>&1; then
    echo "${GREEN}ok${RESET}"
    removed=$((removed + 1))
  else
    # Surface the real error on failure (e.g. image in use by a container).
    echo "${RED}failed${RESET}"
    docker rmi "$ref" 2>&1 | sed 's/^/     /' || true
    failed=$((failed + 1))
  fi
done

echo
echo "${BOLD}Done.${RESET} Removed ${GREEN}${removed}${RESET}, failed ${RED}${failed}${RESET}."
