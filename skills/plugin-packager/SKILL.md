---
name: plugin-packager
description: >
  Claude Code のスキルリポジトリを Plugin + Agent Skills の両用配布構造に変換するスキル。
  トリガー: ユーザーが「パッケージ化」「plugin 化」「配布構造」「package」「plugin structure」に言及した場合、
  または /package コマンドが実行された場合。
  提供: リポジトリ走査・分析、配布方法の判断、構造変換、互換性チェック。
---

# plugin-packager

Claude Code のスキル/コマンド/hooks を含むリポジトリを、Claude Code Plugin (`/plugin install`) と Agent Skills (`npx skills add`) の両方で配布可能な構造に変換する。

## 配布方式の概要

| 方式 | コマンド | 配布対象 |
|------|---------|---------|
| Plugin (公式) | `/plugin install` | skills + commands + hooks |
| Agent Skills (Vercel) | `npx skills add` | skills のみ |
| install.sh (レガシー) | `./install.sh` | git clone + ファイルコピー |

## 手順

### ステップ 1: リポジトリ走査と分析

以下のディレクトリ・ファイルを検出する:

```
検出対象:
  skills/        → Plugin 構造のスキル
  .claude/skills/ → 旧構造のスキル（要移動）
  commands/       → Plugin 構造のコマンド
  .claude/commands/ → 旧構造のコマンド（要移動）
  hooks/          → Hook 定義
  .claude-plugin/plugin.json → 既存のプラグインマニフェスト
  install.sh      → レガシーインストーラ
```

各 SKILL.md の YAML frontmatter (`name`, `description`) の有無を確認する。

### ステップ 2: 配布方法の判断

検出したコンポーネントに基づき、以下の基準で推奨配布方法を決定する:

| 条件 | 推奨配布方法 |
|------|------------|
| skills のみ | Agent Skills (`npx skills add`) をメイン推奨。Plugin は任意 |
| skills + commands | Plugin (`/plugin install`) を推奨。Agent Skills は補助（skills のみ） |
| skills + commands + hooks | Plugin 必須。Agent Skills は補助 |
| hooks のみ | Plugin 必須。Agent Skills 非対応 |

### ステップ 3: 構造変換

#### 3a. ディレクトリ構造の正規化

旧構造から Plugin 互換構造へ移動する:

```
変換前（旧構造）:
  .claude/skills/<name>/SKILL.md → skills/<name>/SKILL.md
  .claude/commands/<name>.md     → commands/<name>.md

変換後（Plugin 互換構造）:
  skills/<name>/SKILL.md    （Plugin + Agent Skills 両対応）
  commands/<name>.md         （Plugin のみ）
```

**重要**: 移動後に `.claude/` 側のファイルは削除する。重複があると混乱の原因になる。

#### 3b. plugin.json の生成

`.claude-plugin/plugin.json` を以下の形式で **厳密に** 生成する:

```json
{
  "name": "<リポジトリ名>",
  "version": "1.0.0",
  "description": "<English description of the plugin>",
  "author": {
    "name": "<GitHub ユーザー名>"
  },
  "homepage": "https://github.com/<ユーザー名>/<リポジトリ名>",
  "repository": "https://github.com/<ユーザー名>/<リポジトリ名>",
  "license": "MIT",
  "keywords": ["<関連キーワード>"]
}
```

**バリデーション要件（必ず遵守）**:
- `author` は **必ずオブジェクト** `{"name": "..."}` にすること。**文字列は不可**（`/plugin install` でバリデーションエラーになる）
- `description` は **英語** で記述すること（国際的なマーケットプレイスで表示されるため）
- `commands` フィールドはコマンドが存在する場合のみ含める
- `hooks` フィールドは hooks が存在する場合のみ含める（例: `"hooks": {"SessionStart": [...]}`)

#### 3c. marketplace.json の生成

`.claude-plugin/marketplace.json` を以下の形式で **厳密に** 生成する:

**重要**: `catalog` 形式（旧式）は使用禁止。必ず `plugins` 配列形式で生成すること。

```json
{
  "name": "<ユーザー名>-<リポジトリ名>",
  "owner": {
    "name": "<ユーザー名>",
    "email": "github@<ユーザー名>"
  },
  "plugins": [
    {
      "name": "<プラグイン名>",
      "source": "./",
      "description": "<English description>",
      "version": "1.0.0",
      "author": {
        "name": "<ユーザー名>"
      },
      "repository": "https://github.com/<ユーザー名>/<リポジトリ名>",
      "license": "MIT"
    }
  ]
}
```

**バリデーション要件（必ず遵守）**:
- トップレベルに `name`, `owner`, `plugins` の 3 フィールドが **必須**（欠けると `/plugin marketplace add` が失敗する）
- `catalog` 形式 (`catalog.skills`, `catalog.commands`) は **使用禁止**（旧式で認識されない）
- `owner` は `name` フィールドが必須。`email` は任意
- `plugins[].author` は **必ずオブジェクト** `{"name": "..."}` にすること
- `description` は **英語** で記述すること

#### 3d. install.sh のパス更新

既存の install.sh がある場合、パスを新構造に合わせて更新する:
- `.claude/skills/` → `skills/`
- `.claude/commands/` → `commands/`

install.sh が存在しない場合、レガシーインストーラを新規生成する。

### ステップ 4: README インストールセクション生成

コンポーネント構成に応じて、適切なインストール手順を 3 段構成で生成する:

```markdown
## Installation

### As a Plugin (Recommended)  ← commands/hooks がある場合のみ「Recommended」表記

\`\`\`
# Add marketplace
/plugin marketplace add <owner>/<repo>

# Install
/plugin install <name>@<owner>-plugins
\`\`\`

### Skills Only (via Agent Skills)  ← skills がある場合

\`\`\`bash
npx skills add <owner>/<repo>
\`\`\`

> **Note**: This installs skills only (no slash commands or hooks).
> Use the plugin install above for the full experience.

### Manual Install (Legacy)  ← install.sh がある場合

\`\`\`bash
git clone https://github.com/<owner>/<repo>.git
cd <repo>
./install.sh
\`\`\`
```

**判断ルール**:
- commands/hooks がない場合: Agent Skills を「Recommended」にし、Plugin セクションは「Optional」表記にする
- commands/hooks がある場合: Plugin を「Recommended」にする
- install.sh がない場合: Manual Install セクションを省略する

### ステップ 5: 互換性チェックレポート

変換後に以下のレポートを出力する:

```
=== 互換性チェックレポート ===

Plugin 互換性: OK
  ✓ .claude-plugin/plugin.json が存在
  ✓ skills/ ディレクトリが存在
  ✓ commands/ ディレクトリが存在

Agent Skills 互換性: Partial
  ✓ skills/<name>/SKILL.md が存在
  ✓ YAML frontmatter に name, description が含まれる
  ⚠ commands/ は Agent Skills では配布されません
  ⚠ hooks/ は Agent Skills では配布されません

含まれないコンポーネント警告:
  Agent Skills で配布されないもの:
    - commands/package.md
    - hooks/pre-commit.sh
```

**判定基準**:
- Plugin 互換性: plugin.json が存在し、skills/commands パスが正しければ OK
- Agent Skills 互換性:
  - OK: skills のみで SKILL.md の frontmatter が正しい
  - Partial: skills 以外のコンポーネントがある（配布されない旨を警告）
  - NG: skills がない、または frontmatter が不正

## SKILL.md の frontmatter 仕様

Agent Skills で正しく認識されるには、各 SKILL.md に以下の YAML frontmatter が必要:

```yaml
---
name: <スキル名>
description: >
  <トリガー条件を含む詳細な説明>
---
```

- `name` は必須。スキルの一意な識別子。
- `description` は必須。Claude がスキルを自動選択するためのトリガー条件を含めること。

## plugin.json のフィールド仕様

| フィールド | 必須 | 説明 |
|-----------|------|------|
| `name` | ○ | プラグイン名（リポジトリ名と一致推奨） |
| `version` | ○ | セマンティックバージョニング |
| `description` | ○ | プラグインの説明（**英語必須**） |
| `author` | ○ | `{ "name": "..." }` **（オブジェクト必須。文字列は不可）** |
| `repository` | ○ | GitHub リポジトリ URL |
| `license` | △ | ライセンス識別子（MIT 推奨） |
| `keywords` | △ | 検索用キーワード配列 |
| `skills` | ○ | スキルディレクトリパス（`"./skills/"` 推奨） |
| `commands` | △ | コマンドディレクトリパス（存在する場合のみ） |
| `hooks` | △ | Hook 定義（存在する場合のみ） |

## コンポーネントごとの配布対応表

| コンポーネント | Plugin | Agent Skills | install.sh |
|---------------|--------|-------------|------------|
| skills/ | ○ | ○ | ○ |
| commands/ | ○ | × | ○ |
| hooks/ | ○ | × | △（要カスタム） |
| templates/ | ○（skills 内） | ○（skills 内） | ○ |
