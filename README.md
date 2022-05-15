# RealmSync

以下を実行し、ライブラリをインストールして下さい  
`pod update`


## ファイル構成　　

- Database
  - Project（同期時に必要と思われるテーブル）
  - Schedule（同期して欲しいトランザクション。画面で表示・入力しているテーブル）
  - User（同期時に必要と思われるテーブル）  
- Util
  - Constant（定数を定義）
- ListViewController（最初の画面。Scheduleの内容を表示）
- InputViewController（入力画面。Scheduleに出力）
