# Claude Dev Container

Claude Code を Docker 上で実行するための開発環境です。

---

## 設計方針

- コンテナ完結型
- Claude Pro（Web版）のログイン方式を使用
- APIキー不要
- 認証情報はホスト側の `volumes/` ディレクトリに bind mount で保存
- ホスト環境を汚さない
- build context は `./docker` に限定
- 作業ディレクトリは `./volumes/workspace` にマウント

---

## ディレクトリ構成

```
project-root/
├─ volumes/              # コンテナへの bind mount ディレクトリ
│   ├─ workspace/        # 作業対象のコード（コンテナ内 /workspace にマウント）
│   └─ home/
│       └─ claude/
│           ├─ .zshrc    # zsh 設定ファイル
│           ├─ .claude/     # Claude 設定・履歴（gitignore済み）
│           ├─ .config/
│           │   └─ claude/  # Claude 認証情報（gitignore済み）
│           ├─ .sf/         # Salesforce CLI 設定（gitignore済み）
│           └─ .sfdx/       # Salesforce 認証情報（gitignore済み）
├─ docker/               # Docker関連定義
│   ├─ Dockerfile
│   └─ .dockerignore
├─ docker-compose.yml
├─ .env                  # ホストの UID/GID を記載（要作成・gitignore済み）
├─ .env.example          # .env のテンプレート
└─ .devcontainer/        # VS Code Dev Container 設定
```

---

## 起動方法

### 1. `.env` を作成する

```bash
cp .env.example .env
```

`.env` を開き、ホストの UID/GID を確認して設定します:

```bash
id -u  # UID
id -g  # GID
```

### 2. ビルドして起動する

```bash
docker compose up -d --build
```

### 3. コンテナに入る

```bash
docker compose exec claude-sf zsh
```

---

# 🔐 初回ログイン手順（重要）

このプロジェクトは APIキーを使用しません。

Claude Pro の Webログイン方式を利用します。

### 1️⃣ コンテナに入る

```bash
docker compose exec claude-sf zsh
```

### 2️⃣ Claude にログイン

```bash
claude login
```

### 3️⃣ 表示されたURLをブラウザで開く

- ブラウザが自動で開かない場合はURLをコピー
- Claude Pro にログイン済みのブラウザで開く
- 認証を許可する

### 4️⃣ 認証完了確認

```bash
claude auth status
```

ログイン済みと表示されれば完了です。

---

## 認証情報の保存場所

認証情報はホスト側の bind mount ディレクトリ:

```
./volumes/home/claude/.config/claude/
```

に保存されます。

コンテナを削除してもディレクトリが残る限りログインは保持されます。

---

## Salesforce 組織へのログイン

Docker 内では `sf org login web` のコールバックが機能しないため、ホストで取得した認証情報を Docker 内にインポートします。

### 1. ホストで Salesforce にログイン

ホストマシンのターミナルで実行します:

```bash
sf org login web -a <エイリアス>
```

### 2. Sfdx Auth URL を取得する

```bash
sf org display --target-org <エイリアス> --verbose
```

出力結果の中に `Sfdx Auth Url` という項目があります。`force://` で始まる長い文字列をコピーします。

### 3. auth.txt を作成して Docker 内に配置する

ホストの `volumes/workspace/` ディレクトリに `auth.txt` を作成します:

```bash
echo "force://..." > volumes/workspace/auth.txt
```

> ⚠ `auth.txt` には認証情報が含まれます。`.gitignore` に追加してください。

### 4. Docker 内で認証情報をインポートする

コンテナに入り、以下を実行します:

```bash
docker compose exec claude-sf zsh
sf org login sfdx-url -f auth.txt -d -a <エイリアス>
```

インポート後は `auth.txt` を削除することを推奨します:

```bash
rm auth.txt
```

---

## 停止

```bash
docker compose down
```

---

## 認証情報も削除する場合

```bash
rm -rf ./volumes/home/claude/.config/claude
```

⚠ これを実行すると再ログインが必要になります。

---

## 特徴

- ホストに Claude CLI 不要
- APIキー不要
- Gitに秘密情報が入らない
- プロジェクト単位で自己完結
- 再現性が高い

---

## 注意事項

- CI環境には向きません（Webログインが必要なため）
- Claude Pro 契約が必要です
- ログインセッションが失効した場合は再度 `claude login` を実行してください
