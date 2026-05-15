#!/usr/bin/env bash
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

fail() {
  echo "ERROR: $*" >&2
  failures=1
}

tracked_markdown_files() {
  git -C "$REPO_ROOT" ls-files --cached --others --exclude-standard '*.md'
}

extract_links() {
  local file="$1"

  perl -0ne '
    while (/(?:!?\[[^\]\n]+\]\(([^)\n]+)\))/g) {
      print "$1\n";
    }
    while (/^[[:space:]]*\[[^\]]+\]:[[:space:]]*(\S+)/mg) {
      print "$1\n";
    }
  ' "$file"
}

clean_target() {
  local target="$1"

  target="${target//$'\r'/}"
  target="${target#"${target%%[![:space:]]*}"}"
  target="${target%"${target##*[![:space:]]}"}"
  target="${target#<}"
  target="${target%>}"

  if [[ "$target" == *" "* && "$target" != *"%20"* ]]; then
    target="${target%% *}"
  fi

  printf '%s\n' "$target"
}

is_external_target() {
  local target="$1"

  [[ "$target" =~ ^(https?|ftp|mailto|tel|data): ]] ||
    [[ "$target" =~ ^// ]]
}

anchor_slug_exists() {
  local file="$1"
  local expected="$2"

  perl -Mstrict -Mwarnings -e '
    my ($expected, $file) = @ARGV;
    $expected =~ s/^#//;
    $expected =~ tr/A-Z/a-z/;

    my %seen;
    open my $fh, "<", $file or exit 1;
    while (my $line = <$fh>) {
      next unless $line =~ /^\s{0,3}#{1,6}\s+(.+?)\s*#*\s*$/;
      my $slug = lc $1;
      $slug =~ s/<[^>]+>//g;
      $slug =~ s/`//g;
      $slug =~ s/&amp;/and/g;
      $slug =~ s/[^a-z0-9 _-]//g;
      $slug =~ s/\s+/-/g;
      $slug =~ s/^-+|-+$//g;
      my $base = $slug;
      if ($seen{$base}++) {
        $slug = $base . "-" . ($seen{$base} - 1);
      }
      if ($slug eq $expected) {
        exit 0;
      }
    }
    exit 1;
  ' "$expected" "$file"
}

check_target() {
  local source_file="$1"
  local raw_target="$2"
  local target
  local path_part
  local anchor=""
  local candidate
  local display_source="${source_file#$REPO_ROOT/}"

  target="$(clean_target "$raw_target")"

  if [[ -z "$target" ]] || is_external_target "$target"; then
    return 0
  fi

  if [[ "$target" == *"#"* ]]; then
    anchor="${target#*#}"
    path_part="${target%%#*}"
  else
    path_part="$target"
  fi

  path_part="${path_part%%\?*}"
  path_part="${path_part//%20/ }"

  if [[ -z "$path_part" ]]; then
    candidate="$source_file"
  elif [[ "$path_part" == /* ]]; then
    candidate="$REPO_ROOT${path_part}"
  else
    candidate="$(dirname "$source_file")/$path_part"
  fi

  if [[ ! -e "$candidate" ]]; then
    fail "${display_source}: missing local Markdown target '$target'"
    return 0
  fi

  if [[ -n "$anchor" && -f "$candidate" && "$candidate" == *.md ]]; then
    if ! anchor_slug_exists "$candidate" "$anchor"; then
      fail "${display_source}: missing anchor '#$anchor' in ${candidate#$REPO_ROOT/}"
    fi
  fi
}

echo "==> Checking Markdown links"

while IFS= read -r relative_file; do
  source_file="$REPO_ROOT/$relative_file"
  while IFS= read -r target; do
    check_target "$source_file" "$target"
  done < <(extract_links "$source_file")
done < <(tracked_markdown_files)

if [[ "$failures" -ne 0 ]]; then
  exit 1
fi

echo "Markdown links look consistent."
