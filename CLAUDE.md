# plugin-packager

Claude Code のスキルリポジトリを Plugin + Agent Skills の両用配布構造に変換するスキル/コマンドパッケージ。

## リポジトリ構造

```
plugin-packager/
├── .claude-plugin/
│   ├── plugin.json                 # プラグインマニフェスト
│   └── marketplace.json            # Marketplace カタログ
├── skills/
│   └── plugin-packager/
│       └── SKILL.md                # パッケージング知識・手順スキル
├── commands/
│   └── package.md                  # /package スラッシュコマンド
├── install.sh                      # レガシーインストーラ（plugin 未対応環境向け）
├── CLAUDE.md                       # 開発ガイド（このファイル）
├── LICENSE                         # MIT
├── README.md                       # ユーザー向けドキュメント（英語）
└── README.ja.md                    # ユーザー向けドキュメント（日本語）
```

### スキルとコマンドの役割分担

| ファイル | 用途 |
|---------|------|
| `skills/plugin-packager/SKILL.md` | パッケージングの知識・判断基準・手順を定義。自然言語でのトリガーにも対応 |
| `commands/package.md` | `/package` スラッシュコマンドの手順を定義。走査→分析→確認→変換の対話フロー |

## スキル・コマンドの修正方法

### スキルの修正

1. `skills/plugin-packager/SKILL.md` を編集
2. YAML frontmatter の `name`, `description`（トリガー条件を含む）を維持する
3. 配布方法の判断基準や構造変換の手順を更新

### コマンドの修正

1. `commands/package.md` を編集
2. YAML frontmatter の `allowed-tools`, `description` を維持する
3. 対話フロー（走査→分析→確認→変換→レポート）の手順を更新

## install.sh の動作

### インストール（引数なし）

1. `~/.claude/` の存在を確認（なければエラー終了）
2. ディレクトリを作成:
   - `~/.claude/skills/plugin-packager/`
   - `~/.claude/commands/`
3. ファイルをコピー（`cp -f`、symlink ではない）:
   - スキル SKILL.md × 1
   - コマンド × 1
4. 完了メッセージと利用可能なコマンド一覧を表示

### `--check`

インストール状態を確認し、各項目の OK/warn を表示。ファイルの変更はしない。

### `--uninstall`

- `~/.claude/skills/plugin-packager/` を削除
- `~/.claude/commands/package.md` を削除

## 配布構造の自己適用

このリポジトリ自体が Plugin + Agent Skills の両用配布構造になっている:

- **Plugin として**: `.claude-plugin/plugin.json` が `skills/` と `commands/` を参照
- **Agent Skills として**: `skills/plugin-packager/SKILL.md` が YAML frontmatter 付きで存在
- **レガシーとして**: `install.sh` が `~/.claude/` にファイルをコピー

## コーディング規約

- **ドキュメント・コメント**: 日本語
- **コード（変数名・関数名）**: 英語
- スキルは YAML frontmatter + Markdown
- コマンドは YAML frontmatter（`allowed-tools`, `description`）+ Markdown
- README.md は英語、README.ja.md は日本語（相互参照リンク付き）
