#!/usr/bin/env bash
# plugin-packager インストールスクリプト
# Skills と commands を ~/.claude/ にインストールする
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

# インストール対象
SKILL_SRC="${SCRIPT_DIR}/skills/plugin-packager"
COMMANDS_SRC="${SCRIPT_DIR}/commands"

SKILL_DST="${CLAUDE_DIR}/skills/plugin-packager"
COMMANDS_DST="${CLAUDE_DIR}/commands"

# 色出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[info]${NC} $*"; }
ok()    { echo -e "${GREEN}[ok]${NC} $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC} $*"; }
error() { echo -e "${RED}[error]${NC} $*" >&2; }

# --- check サブコマンド ---
do_check() {
  local has_error=0

  info "インストール状態を確認中..."

  # Claude Code ディレクトリ
  if [[ -d "${CLAUDE_DIR}" ]]; then
    ok "~/.claude/ が存在します"
  else
    error "~/.claude/ が見つかりません (Claude Code 未インストール?)"
    has_error=1
  fi

  # plugin-packager skill
  if [[ -f "${SKILL_DST}/SKILL.md" ]]; then
    ok "plugin-packager skill がインストール済み"
  else
    warn "plugin-packager skill が未インストール"
    has_error=1
  fi

  # commands
  local cmd_count=0
  for cmd in package; do
    if [[ -f "${COMMANDS_DST}/${cmd}.md" ]]; then
      cmd_count=$((cmd_count + 1))
    fi
  done
  if [[ ${cmd_count} -eq 1 ]]; then
    ok "コマンド: ${cmd_count}/1 インストール済み"
  else
    warn "コマンド: ${cmd_count}/1 インストール済み"
    has_error=1
  fi

  if [[ ${has_error} -eq 0 ]]; then
    echo ""
    ok "すべて正常です"
    return 0
  else
    echo ""
    warn "一部の項目が未インストールです。install.sh を実行してください。"
    return 1
  fi
}

# --- uninstall サブコマンド ---
do_uninstall() {
  info "plugin-packager をアンインストール中..."

  # Skill
  if [[ -d "${SKILL_DST}" ]]; then
    rm -rf "${SKILL_DST}"
    ok "削除: ${SKILL_DST}"
  fi

  # Command
  if [[ -f "${COMMANDS_DST}/package.md" ]]; then
    rm -f "${COMMANDS_DST}/package.md"
    ok "削除: ${COMMANDS_DST}/package.md"
  fi

  echo ""
  ok "アンインストール完了"
}

# --- install ---
do_install() {
  info "plugin-packager をインストール中..."

  # 前提チェック: ~/.claude/ が存在するか
  if [[ ! -d "${CLAUDE_DIR}" ]]; then
    error "~/.claude/ が見つかりません。Claude Code をインストールしてから再実行してください。"
    exit 1
  fi

  # ディレクトリ作成
  mkdir -p "${SKILL_DST}"
  mkdir -p "${COMMANDS_DST}"

  # plugin-packager skill
  cp -f "${SKILL_SRC}/SKILL.md" "${SKILL_DST}/SKILL.md"
  ok "インストール: plugin-packager/SKILL.md"

  # commands
  local cmd_count=0
  for cmd_file in "${COMMANDS_SRC}"/*.md; do
    if [[ -f "${cmd_file}" ]]; then
      cp -f "${cmd_file}" "${COMMANDS_DST}/"
      cmd_count=$((cmd_count + 1))
    fi
  done
  ok "インストール: コマンド ${cmd_count} 個"

  echo ""
  ok "インストール完了!"
  echo ""
  info "利用可能なコマンド:"
  echo "  /package    リポジトリを Plugin + Agent Skills 配布構造に変換"
}

# --- メイン ---
case "${1:-}" in
  --check)
    do_check
    ;;
  --uninstall)
    do_uninstall
    ;;
  --help|-h)
    echo "使い方: install.sh [--check|--uninstall|--help]"
    echo ""
    echo "  (引数なし)    インストール実行"
    echo "  --check       インストール状態を確認"
    echo "  --uninstall   アンインストール"
    echo "  --help        このヘルプを表示"
    ;;
  "")
    do_install
    ;;
  *)
    error "不明なオプション: $1"
    echo "使い方: install.sh [--check|--uninstall|--help]"
    exit 1
    ;;
esac
