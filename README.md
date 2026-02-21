# Claude Dev Container

Claude Code を Docker 上で実行するための開発環境です。

---

## 設計方針

- コンテナ完結型
- Claude Pro（Web版）のログイン方式を使用
- APIキー不要
- 認証情報は Docker named volume に保存
- ホスト環境を汚さない
- build context は `./docker` に限定
- 実行対象は `./app` のみマウント

---

## ディレクトリ構成

```
project-root/
├─ app/                  # 作業対象のコード（コンテナ内 /workspace にマウント）
├─ docker/               # Docker関連定義
│   ├─ Dockerfile
│   ├─ zshrc
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
docker compose exec claude zsh
```

---

# 🔐 初回ログイン手順（重要）

このプロジェクトは APIキーを使用しません。

Claude Pro の Webログイン方式を利用します。

### 1️⃣ コンテナに入る

```bash
docker compose exec claude zsh
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

認証情報は Docker named volume:

```
claude-config
```

に保存されます。

コンテナを削除しても volume がある限りログインは保持されます。

---

## 停止

```bash
docker compose down
```

---

## 認証情報も削除する場合

```bash
docker compose down -v
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
