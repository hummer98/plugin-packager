# plugin-packager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Claude Code のスキルリポジトリを Plugin + Agent Skills の両用配布構造に変換するツール。

**[English README](README.md)**

## なぜ plugin-packager?

Claude Code のスキルを配布する方法が複数あり、毎回同じ検討が発生してセッションごとに結論がブレる問題があります:

- `/plugin install` (Anthropic 公式) — skills + commands + hooks をまとめて配布可能
- `npx skills add` (Vercel Agent Skills) — skills のみ。commands/hooks は含まれない
- `install.sh` (レガシー) — git clone + シェルスクリプトでコピー

**plugin-packager** は判断基準の統一と構造変換の自動化を行います。

## 機能

1. リポジトリを**走査**し、skills, commands, hooks, マニフェストを検出
2. コンポーネント構成を**分析**し、最適な配布方法を推奨
3. ディレクトリ構造を Plugin 互換に**変換**（`skills/`, `commands/` をルート直下に配置）
4. `plugin.json`, `marketplace.json`, README のインストールセクションを**生成**
5. Plugin と Agent Skills の互換性を**レポート**

### 配布方法の判断基準

| 検出コンポーネント | 推奨配布方法 |
|---|---|
| skills のみ | Agent Skills (`npx skills add`) をメイン推奨 |
| skills + commands | Plugin (`/plugin install`) を推奨 |
| skills + commands + hooks | Plugin 必須 |
| hooks のみ | Plugin 必須 |

## インストール

### プラグインとしてインストール（推奨）

```
# Marketplace を追加
/plugin marketplace add hummer98/plugin-packager

# インストール
/plugin install plugin-packager@hummer98-plugins
```

### スキルのみ（Agent Skills 経由）

```bash
npx skills add hummer98/plugin-packager
```

> **注意**: スキルのみインストールされます（`/package` コマンドは含まれません）。自然言語での指示（例:「このリポジトリをパッケージ化して」）は使えますが、`/package` コマンドは利用できません。フル機能が必要な場合はプラグインインストールを使用してください。

### 手動インストール（レガシー）

```bash
git clone https://github.com/hummer98/plugin-packager.git
cd plugin-packager
./install.sh
```

```bash
# インストール状態を確認
./install.sh --check

# アンインストール
./install.sh --uninstall
```

## 使い方

### クイックスタート

任意の Claude Code スキルリポジトリで `/package` コマンドを実行:

```
あなた: /package
Claude: リポジトリを走査中...

        === リポジトリ分析結果 ===

        コンポーネント:
          [検出] skills/my-skill/SKILL.md (frontmatter: OK)
          [検出] .claude/commands/my-cmd.md (移動が必要)
          [未検出] hooks/

        推奨: Plugin (/plugin install) — commands が含まれるため

        変換を実行しますか？ (y/n)

あなた: y
Claude: 変換中...
        ✓ .claude/commands/my-cmd.md → commands/my-cmd.md に移動
        ✓ .claude-plugin/plugin.json を生成
        ✓ .claude-plugin/marketplace.json を生成
        ✓ README.md のインストールセクションを更新

        === 互換性チェックレポート ===
        Plugin:       OK
        Agent Skills: Partial (commands は配布されません)
```

### 自然言語でも使える

スラッシュコマンドは必須ではありません:

```
あなた: このリポジトリを Plugin 配布できる構造にして
あなた: Agent Skills として配布可能か確認して
あなた: .claude/skills を Plugin 構造に変換して
```

### オプション

- `/package --dry-run` — 分析のみ実行し、変換は行わない
- `/package --force` — 確認なしで変換を実行
- `/package hummer98/my-plugin` — owner/repo を明示指定

## 生成されるファイル

| ファイル | 用途 |
|---------|------|
| `.claude-plugin/plugin.json` | プラグインマニフェスト（名前、バージョン、パス） |
| `.claude-plugin/marketplace.json` | Marketplace カタログエントリ |
| `install.sh` | レガシーインストーラ（`~/.claude/` にコピー） |
| README インストールセクション | 3段構成のインストール手順 |

## リポジトリ構造

```
plugin-packager/
├── .claude-plugin/
│   ├── plugin.json             # プラグインマニフェスト
│   └── marketplace.json        # Marketplace カタログ
├── skills/
│   └── plugin-packager/
│       └── SKILL.md            # パッケージング知識・手順
├── commands/
│   └── package.md              # /package スラッシュコマンド
├── install.sh                  # レガシーインストーラ
├── CLAUDE.md                   # 開発ガイド
├── LICENSE                     # MIT
├── README.md                   # 英語
└── README.ja.md                # 日本語
```

## ライセンス

MIT License — 詳細は [LICENSE](LICENSE) を参照。
