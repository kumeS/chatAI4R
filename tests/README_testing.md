# chatAI4R パッケージテスト実行ガイド

このガイドでは、chatAI4Rパッケージの実行テストの使用方法について説明します。

## 📋 テストの概要

### 作成されたファイル
- `test_execution.R` - メインテストスクリプト
- `test_utilities.R` - テスト用ヘルパー関数
- `README_testing.md` - このガイド（現在のファイル）

### テストカテゴリ
1. **ユーティリティ関数** - API不要、オフラインで実行可能
2. **API関数** - OpenAI API key必要
3. **拡張API関数** - 追加のAPI key必要（Gemini等）
4. **ファイル処理** - 一時ファイルを使用したテスト
5. **エラーハンドリング** - 異常系のテスト

## 🚀 実行方法

### 前提条件
```bash
# Rがインストールされていること
R --version

# chatAI4Rパッケージがインストールされていること
R -e "library(chatAI4R)"

# testsディレクトリに移動（推奨）
cd tests/
```

### 基本的な実行コマンド

#### 方法A: testsディレクトリから実行（推奨）
```bash
# testsディレクトリに移動
cd tests/

# 1. ユーティリティ関数のみテスト（API Key不要）
./run_basic_tests.sh

# 2. 完全テスト（OpenAI API Key必要）
./run_basic_tests.sh -k "sk-your-openai-api-key-here" -m full

# 3. io.net API含む拡張テスト
./run_basic_tests.sh -k "sk-openai-key" -i "ionet-api-key" -m extended

# 4. 直接Rscriptで実行
Rscript test_execution.R --mode=utilities
```

#### 方法B: プロジェクトルートから実行
```bash
# プロジェクトルートディレクトリから
./tests/run_basic_tests.sh -k "sk-your-key" -m full

# または
Rscript tests/test_execution.R --api-key="sk-your-key" --mode=full
```

### 実際のテスト実行例

#### 例1: 最小テスト（API不要）
```bash
cd tests/
./run_basic_tests.sh
# または
Rscript test_execution.R --mode=utilities
```

#### 例2: OpenAI APIのみでテスト
```bash
cd tests/
export OPENAI_API_KEY="sk-your-actual-openai-key-here"
./run_basic_tests.sh -m full
```

#### 例3: io.net APIを含む全機能テスト
```bash
cd tests/
export OPENAI_API_KEY="sk-your-openai-key"
export IONET_API_KEY="your-ionet-api-key"
./run_basic_tests.sh -m extended
```

#### 例4: 複数API同時テスト
```bash
cd tests/
./run_basic_tests.sh \
  -k "sk-openai-key" \
  -i "ionet-key" \
  -g "gemini-key" \
  -r "replicate-key" \
  -m extended
```

### ヘルプとオプション確認
```bash
cd tests/
./run_basic_tests.sh --help
Rscript test_execution.R --help
```

## 🔧 設定オプション

### API Keys
```bash
# 基本的なOpenAI API Key（多くの関数で必須）
--api-key="sk-your-openai-api-key-here"

# 拡張API関数用のAPI Keys（オプション）
--gemini-key="your-gemini-api-key"           # Google Gemini API用
--replicate-key="your-replicate-api-token"   # Replicate API用
--dify-key="your-dify-api-key"               # Dify API用
--deepl-key="your-deepl-api-key"             # DeepL翻訳API用
--ionet-key="your-ionet-api-key"             # io.net API用

# 環境変数での設定も可能
export OPENAI_API_KEY="sk-your-openai-api-key-here"
export GoogleGemini_API_KEY="your-gemini-api-key"      # 注意：変数名が特殊
export Replicate_API_KEY="your-replicate-api-token"    # 注意：変数名が特殊
export DIFY_API_KEY="your-dify-api-key"
export DeepL_API_KEY="your-deepl-api-key"
export IONET_API_KEY="your-ionet-api-key"              # io.net API用
```

### テストモード
- `utilities` - ユーティリティ関数のみ（API Key不要）
- `api-only` - 基本API関数のみ（OpenAI API Key必要）
- `full` - 基本API関数とユーティリティ関数（OpenAI API Key必要）
- `extended` - 全ての関数（複数のAPI Key必要）

## 📊 出力ファイル

### 生成されるファイル
1. **`test_results_YYYYMMDD_HHMMSS.log`** - 実行ログ
2. **`test_results_YYYYMMDD_HHMMSS_details.json`** - 詳細結果（JSON形式）

### ログの見方
```
[2024-01-01 12:00:00] INFO: Starting chatAI4R Package Execution Tests
[2024-01-01 12:00:01] INFO: Running test: slow_print_v2_basic
[2024-01-01 12:00:02] PASS: ✓ PASSED: slow_print_v2_basic
[2024-01-01 12:00:03] ERROR: ✗ FAILED: chat4R_basic - API key invalid
[2024-01-01 12:00:04] SKIP: ⊝ SKIPPED: gemini4R_basic - No Gemini API key
```

## 🧪 テスト対象関数

### ✅ テスト対象（GUI不要）

#### ユーティリティ関数（9個）
- `slow_print_v2` - テキスト出力（タイプライター効果）
- `ngsub` - 文字列整理（空白・改行削除）
- `removeQuotations` - 引用符削除（単一・二重・バック引用符）
- `interpretResult` - 結果解釈（部分的にAPI使用）
- `textFileInput4ai` - ファイル入力処理
- `convertBullet2Sentence` - 箇条書きから文章変換（部分的にAPI使用）
- `speakInEN` - 英語音声出力（macOS専用）
- `speakInJA` - 日本語音声出力（macOS専用）
- `speakInJA_v2` - クリップボードから日本語音声出力（macOS専用）

#### 基本API関数（25個）
- `chat4R`, `chat4Rv2` - 基本チャット（OpenAI）
- `textEmbedding` - テキスト埋め込み（OpenAI）
- `conversation4R` - 会話履歴（OpenAI）
- `TextSummary` - テキスト要約（OpenAI）
- `vision4R` - 画像解析（OpenAI）

#### 拡張API関数（10個）
- `gemini4R` - Google Gemini API
- `geminiGrounding4R` - Gemini検索接地API
- `replicatellmAPI4R` - Replicate API
- `DifyChat4R` - Dify API
- `multiLLMviaionet` - io.net Multi-LLM API（23モデル対応）
- `list_ionet_models` - io.net モデル一覧取得（カテゴリ別表示）
- `multiLLM_random10` - io.net ランダム10モデル実行（バランス選択）
- `multiLLM_random5` - io.net ランダム5モデル実行（高速テスト）
- `discussion_flow_v1` - 多ボット会話（オプション：DeepL）
- `discussion_flow_v2` - 多ボット会話（オプション：DeepL）

### ❌ テスト除外（GUI依存）

#### RStudio API依存（15個）
- `proofreadEnglishText` - 英文校正（RStudio）
- `addCommentCode` - コメント追加（RStudio）
- `createRcode` - コード生成（クリップボード）
- `supportIdeaGeneration` - アイデア生成（選択テキスト）

#### システム依存
- `speakInEN`, `speakInJA` - 音声出力

## 🔍 トラブルシューティング

### よくある問題

#### 1. API Key関連
```bash
Error: API key invalid
```
**解決方法**: 正しいOpenAI API keyを使用（sk-で始まる）

#### 2. ネットワーク接続
```bash
Error: Connection timeout
```
**解決方法**: インターネット接続を確認

#### 3. パッケージ依存
```bash
Error: package 'xxx' not found
```
**解決方法**: 必要なパッケージをインストール
```r
install.packages(c("httr", "jsonlite", "assertthat"))
```

### デバッグ方法

#### 1. 詳細ログ有効化
Rscriptに以下を追加して実行：
```r
options(verbose = TRUE)
```

#### 2. 個別関数テスト
```r
# Rコンソールで個別実行
library(chatAI4R)
Sys.setenv(OPENAI_API_KEY = "your-key")
result <- chat4R("Hello")
```

#### 3. タイムアウト調整
テストスクリプト内の`timeout`値を調整：
```r
config$timeout <- 60  # 60秒に変更
```

## 📈 結果の解釈

### 終了コード
- `0` - 全テスト成功
- `1` - 一部またはすべてのテスト失敗

### 成功率の目安
- **90%以上** - 良好
- **70-90%** - 注意（API制限やネットワーク問題の可能性）
- **70%未満** - 問題あり（設定やコードの確認が必要）

## 🎯 テスト成功/失敗の判断基準

### ✅ テスト成功の条件

#### 1. カテゴリ別成功基準
- **ユーティリティ関数**: 100%成功（API不要のため）
- **基本API関数**: 80%以上成功（ネットワーク問題を考慮）
- **拡張API関数**: 70%以上成功（複数API依存のため）
- **ファイル処理**: 90%以上成功（ローカル処理主体）

#### 2. 個別テスト成功の判定
```bash
# ログ出力例
[2024-01-01 12:00:02] PASS: ✓ PASSED: function_name
[2024-01-01 12:00:03] TIME: Execution time: 1.23 seconds
[2024-01-01 12:00:04] MEMORY: Memory usage: 45.6 MB
```

**成功条件:**
- 関数がエラーなく実行完了
- 期待される戻り値の型・構造が正しい
- 実行時間が30秒以内（タイムアウト設定）
- メモリ使用量が異常でない

#### 3. 全体テスト成功の判定
```bash
# 最終結果例
========================================
FINAL RESULTS:
Total Tests: 40
Passed: 36
Failed: 3
Skipped: 1
Success Rate: 90.0%
========================================
```

**成功条件:**
- 全体成功率が80%以上
- 重要な基本機能（chat4R, textEmbedding等）が成功
- 致命的なエラー（segfault, R crashed等）が発生しない

### ❌ テスト失敗の判定

#### 1. 個別テスト失敗パターン
```bash
# 失敗ログ例
[2024-01-01 12:00:03] ERROR: ✗ FAILED: function_name - API key invalid
[2024-01-01 12:00:04] ERROR: ✗ FAILED: function_name - Connection timeout
[2024-01-01 12:00:05] ERROR: ✗ FAILED: function_name - Unexpected result format
```

**失敗と判定される条件:**
- 関数実行時にエラーが発生
- 戻り値が期待される型・構造でない
- 実行時間が30秒を超過（タイムアウト）
- APIエラー（認証失敗、レート制限等）

#### 2. 許容される失敗パターン
以下は一時的な失敗として許容される場合があります：

**ネットワーク関連:**
- `Connection timeout` - 一時的なネットワーク問題
- `Rate limit exceeded` - API制限（時間をおいて再実行）
- `Service unavailable` - APIサービス一時停止

**環境依存:**
- `API key not found` - 設定問題（修正可能）
- `Package not found` - 依存関係問題（解決可能）

#### 3. 重大な失敗パターン
以下は即座に対処が必要な失敗です：

**致命的エラー:**
- `R session crashed` - Rプロセスの異常終了
- `Segmentation fault` - メモリ関連の致命的エラー
- `Stack overflow` - 無限再帰等の重大な問題

**機能的エラー:**
- 基本API関数の全面的な失敗
- ユーティリティ関数の失敗（API不要のため）
- データ構造の破損や不正な戻り値

### 🔍 詳細な成功/失敗判定方法

#### 1. ログファイルの確認
```bash
# 詳細ログファイル
test_results_YYYYMMDD_HHMMSS.log
test_results_YYYYMMDD_HHMMSS_details.json
```

#### 2. JSON詳細結果の確認
```json
{
  "function_name": {
    "status": "PASSED",
    "execution_time": 1.23,
    "memory_usage": 45.6,
    "error_message": null,
    "result_type": "character",
    "result_length": 150
  }
}
```

#### 3. 成功率の計算
```r
# 成功率計算式
success_rate = (passed_tests / total_tests) * 100

# カテゴリ別成功率
utilities_success = passed_utilities / total_utilities * 100
api_success = passed_api / total_api * 100
```

### 📊 テスト結果の評価基準

#### 🟢 良好（推奨継続）
- 全体成功率: 90%以上
- ユーティリティ関数: 100%成功
- 基本API関数: 85%以上成功
- 実行時間: 平均2秒以内

#### 🟡 注意（確認推奨）
- 全体成功率: 70-90%
- ネットワーク関連エラーが多数
- 特定のAPI関数で繰り返し失敗
- 実行時間: 平均5秒以内

#### 🔴 問題あり（要対策）
- 全体成功率: 70%未満
- ユーティリティ関数で失敗
- 基本API関数で多数失敗
- 致命的エラーの発生
- 実行時間: 平均10秒以上

### 🛠️ 失敗時の対処法

#### 1. 段階的診断
```bash
# Step 1: ユーティリティ関数のみテスト
./run_basic_tests.sh

# Step 2: API設定確認（全APIサービス）
echo $OPENAI_API_KEY                    # OpenAI API（必須）
echo $GoogleGemini_API_KEY              # Google Gemini API
echo $Replicate_API_KEY                 # Replicate API
echo $DIFY_API_KEY                      # Dify API
echo $DeepL_API_KEY                     # DeepL翻訳API
echo $IONET_API_KEY                     # io.net API

# Step 3: 個別関数テスト
R -e "library(chatAI4R); chat4R('test')"
```

### 💡 環境変数の便利な使い方

#### 永続的なAPI Key設定
```bash
# .bashrcまたは.zshrcに追加（全APIサービス）
echo 'export OPENAI_API_KEY="sk-your-key"' >> ~/.bashrc                     # OpenAI API（必須）
echo 'export GoogleGemini_API_KEY="your-gemini-key"' >> ~/.bashrc           # Google Gemini API
echo 'export Replicate_API_KEY="your-replicate-key"' >> ~/.bashrc           # Replicate API
echo 'export DIFY_API_KEY="your-dify-key"' >> ~/.bashrc                     # Dify API
echo 'export DeepL_API_KEY="your-deepl-key"' >> ~/.bashrc                   # DeepL翻訳API
echo 'export IONET_API_KEY="your-ionet-key"' >> ~/.bashrc                   # io.net API
source ~/.bashrc

# これで以降はAPI Keyの指定が不要
./run_basic_tests.sh -m full
Rscript test_execution.R --mode=extended
```

#### セッション限定でのAPI Key設定
```bash
# 現在のセッションでのみ有効（全APIサービス）
export OPENAI_API_KEY="sk-your-key"                    # OpenAI API（必須）
export GoogleGemini_API_KEY="your-gemini-key"          # Google Gemini API  
export Replicate_API_KEY="your-replicate-key"          # Replicate API
export DIFY_API_KEY="your-dify-key"                    # Dify API
export DeepL_API_KEY="your-deepl-key"                  # DeepL翻訳API
export IONET_API_KEY="your-ionet-key"                  # io.net API

# 複数のテストを連続実行
./run_basic_tests.sh -m utilities
./run_basic_tests.sh -m api-only
./run_basic_tests.sh -m extended
```

#### API Key優先順位
1. コマンドライン引数（--api-key, -k等）
2. 環境変数（OPENAI_API_KEY等）
3. エラー（API Keyが見つからない場合）

#### 2. 問題の特定
- **設定問題**: API key、環境変数
- **ネットワーク問題**: 接続、プロキシ
- **依存関係問題**: パッケージバージョン
- **コード問題**: 関数の実装バグ

### 典型的な失敗パターン
1. **API制限** - レート制限に達した場合
2. **ネットワーク** - 接続が不安定な場合
3. **認証** - API keyが無効な場合
4. **モデル** - 指定したモデルが利用できない場合

## 🔧 カスタマイズ

### テスト追加
`test_execution.R`にテスト関数を追加：
```r
run_test("your_function_test", function() {
  result <- your_function("test input")
  if (is.expected(result)) return(TRUE)
  stop("Unexpected result")
}, "YOUR_CATEGORY")
```

### 新しいAPI追加
`test_utilities.R`にモック応答を追加：
```r
mock_your_api_response <- function() {
  list(
    result = "mock response",
    status = "success"
  )
}
```

### レポート形式変更
HTMLレポート生成：
```r
source("test_utilities.R")
generate_html_report(test_results, "custom_report.html")
```

## 📚 参考情報

### API制限について
- OpenAI: 1分間に3リクエスト（無料プラン）
- 大量テスト時は有料プランを推奨

### パフォーマンス最適化
- テスト並列実行は現在未対応
- 大量テスト時はバッチ実行を推奨

### セキュリティ
- API keyをコードに直接書かない
- 環境変数での管理を推奨
- テスト終了後はAPI keyをクリア

## 📞 サポート

### 問題報告
GitHubのIssuesでバグ報告してください：
https://github.com/kumeS/chatAI4R/issues

### 貢献方法
プルリクエストで改善提案を歓迎します：
- テストケースの追加
- バグ修正
- ドキュメント改善