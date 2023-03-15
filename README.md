# yapc2023_LT


## 初期設定
### 環境変数
.envに以下の環境変数を入れる
SLACK_WEBHOOK_URL：slackワークフロービルダーのwebhook url。ワークフローの変数にtrash_typesを入れるとゴミ情報が受け取れる。
CITY：町の名前を入れる(例：大町)

### htmlファイル
`wget https://www.city.kamakura.kanagawa.jp/nagocs/new_shuushuubi.html -O src/index.html`
