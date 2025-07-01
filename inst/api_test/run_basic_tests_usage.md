# run_basic_tests.sh 実行方法

## 概要
`run_basic_tests.sh`は、chatAI4Rパッケージの統合テストを実行するためのシェルスクリプトです。複数のAPI プロバイダーをサポートしています。

## 実行場所
```bash
cd tests/
```

## 基本構文
```bash
./run_basic_tests.sh [OPTIONS]
```

## オプション

### APIキー設定
- `-k, --api-key KEY`: OpenAI API key (sk-...)
- `-g, --gemini-key KEY`: Google Gemini API key  
- `-r, --replicate-key KEY`: Replicate API token
- `-d, --dify-key KEY`: Dify API key
- `-l, --deepl-key KEY`: DeepL API key
- `-i, --ionet-key KEY`: io.net API key

### テスト設定
- `-m, --mode MODE`: テストモード (utilities|api-only|full|extended)
- `-q, --quiet`: 静寂モード（出力を減らす）
- `-h, --help`: ヘルプメッセージ表示

## 実行モード

### 1. utilities モード（APIキー不要）
```bash
./run_basic_tests.sh
# または
./run_basic_tests.sh -m utilities
```
- 6つの基本機能テスト
- 実行時間: 約10秒
- API接続不要

### 2. api-only モード
```bash
./run_basic_tests.sh -k sk-xxx... -m api-only
```
- 12個のAPI テスト
- 実行時間: 約30秒
- 少なくとも1つのAPIキーが必要

### 3. full モード
```bash
./run_basic_tests.sh -k sk-xxx... -m full
```
- 18個の包括的テスト（utilities + api-only）
- 実行時間: 約60秒
- 少なくとも1つのAPIキーが必要

### 4. extended モード
```bash
./run_basic_tests.sh -k sk-xxx... -i io-xxx... -m extended
```
- 23個の全テスト（full + 拡張API）
- 実行時間: 3-5分
- 複数のAPIキーが推奨

## サポートAPIプロバイダー

### OpenAI
- URL: https://platform.openai.com/
- キー形式: `sk-`で始まる
- 主要プロバイダー

### Google Gemini
- URL: https://makersuite.google.com/
- 高性能言語モデル

### Replicate
- URL: https://replicate.com/
- オープンソースモデル

### Dify
- URL: https://dify.ai/
- ワークフロー統合

### DeepL
- URL: https://www.deepl.com/
- 高品質翻訳API

### io.net
- URL: https://cloud.io.net/
- 分散GPU計算

## 出力
- 実行結果はコンソールのみに出力
- ログファイルは生成されません

## 実行例

### 基本テスト（APIキーなし）
```bash
./run_basic_tests.sh
```

### OpenAI のみ
```bash
./run_basic_tests.sh -k sk-your-openai-key -m full
```

### 複数API
```bash
./run_basic_tests.sh -k sk-key -g gemini-key -m extended
```

### io.net テスト
```bash
./run_basic_tests.sh -k sk-key -i ionet-key -m extended
```

### 静寂モード
```bash
./run_basic_tests.sh -k sk-key -m full -q
```

## テスト結果の解釈

### 終了コード
- `0`: 全テスト成功
- `1`: 1つ以上のテスト失敗

### コンソール出力
- `✓ PASSED`: テスト成功
- `✗ FAILED`: テスト失敗  
- `⊝ SKIPPED`: APIキー不足でスキップ

### 一般的な失敗原因
1. 無効なAPIキー
2. ネットワーク接続問題
3. API制限超過
4. パッケージの依存関係問題

## 注意事項
- APIテストは実際の課金対象となります
- ネットワーク環境により実行時間が変動します
- 複数のAPIキーを設定することで、より包括的なテストが可能です
- 各プロバイダーの利用規約と課金体系を確認してください 