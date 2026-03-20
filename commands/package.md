---
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
description: "リポジトリを走査し、Plugin + Agent Skills の両用配布構造に変換する"
---

# /package

カレントリポジトリを走査・分析し、Claude Code Plugin と Agent Skills の両方で配布可能な構造に変換する。

## 手順

### 1. リポジトリ走査

以下のパスを検出する:

- `skills/` — Plugin 構造のスキル
- `.claude/skills/` — 旧構造のスキル
- `commands/` — Plugin 構造のコマンド
- `.claude/commands/` — 旧構造のコマンド
- `hooks/` — Hook 定義
- `.claude-plugin/plugin.json` — 既存のプラグインマニフェスト
- `.claude-plugin/marketplace.json` — 既存の Marketplace カタログ
- `install.sh` — レガシーインストーラ
- `README.md` — README
- `LICENSE` — ライセンスファイル

SKILL.md ファイルの YAML frontmatter (`name`, `description`) を確認する。

### 2. 分析結果を表示

検出したコンポーネントとその状態をテーブル形式で表示する:

```
=== リポジトリ分析結果 ===

コンポーネント:
  [検出] skills/plugin-packager/SKILL.md (frontmatter: OK)
  [検出] commands/package.md
  [未検出] hooks/
  [検出] .claude-plugin/plugin.json
  [検出] install.sh

推奨配布方法:
  メイン: Plugin (/plugin install) — commands が含まれるため
  補助: Agent Skills (npx skills add) — skills のみ配布

必要な変換:
  - .claude/skills/ → skills/ への移動（該当する場合）
  - .claude/commands/ → commands/ への移動（該当する場合）
  - plugin.json の生成/更新
  - marketplace.json の生成/更新
  - README のインストールセクション更新
```

### 3. ユーザーに確認

変換内容を一覧表示し、ユーザーの確認を待つ。

確認事項:
- GitHub ユーザー名/オーガニゼーション名（plugin.json の author に使用）
- リポジトリの GitHub URL
- 変換を実行してよいか

### 4. 変換を実行

ユーザーの確認後、以下の変換を順番に実行する:

1. **ディレクトリ構造の正規化**:
   - `.claude/skills/<name>/SKILL.md` → `skills/<name>/SKILL.md`
   - `.claude/commands/<name>.md` → `commands/<name>.md`
   - 移動元のファイルを削除

2. **`.claude-plugin/plugin.json` の生成/更新**:
   - 既存の plugin.json がある場合はマージ（ユーザー設定を尊重）
   - ない場合は新規作成

3. **`.claude-plugin/marketplace.json` の生成/更新**:
   - 既存の marketplace.json がある場合はマージ
   - ない場合は新規作成

4. **install.sh の生成/更新**:
   - パスを新構造に合わせて更新
   - 存在しない場合は新規生成

5. **README のインストールセクション更新**:
   - 3段構成のインストール手順を生成
   - 既存の README がある場合はインストールセクションのみ更新

### 5. 互換性チェックレポート

変換後に以下を検証し、レポートを表示する:

```
=== 互換性チェックレポート ===

Plugin 互換性: OK/NG
  [理由の詳細]

Agent Skills 互換性: OK/Partial/NG
  [理由の詳細]

含まれないコンポーネント警告:
  [Agent Skills で配布されない commands/hooks の一覧]
```

## 引数

`$ARGUMENTS` — オプション。以下を指定可能:
- `--dry-run` — 分析のみ実行し、変換は行わない
- `--force` — 確認なしで変換を実行
- GitHub owner/repo 形式（例: `hummer98/my-plugin`）

## 注意事項

- 既存のファイルを上書きする前に差分を表示し確認する
- git で管理されている場合、変換前にコミットされていない変更がないか確認する
- `.claude/` 配下のファイルを移動する場合、元のファイルを削除する前に移動先を確認する
