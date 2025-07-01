# ビルド時テスト（R CMD check / devtools::check()）
# API Key不要の基本機能テストのみ実行
# 包括的テストは tests/test_execution.R を使用

library("chatAI4R")

# テスト設定
options(testthat.use_colours = FALSE)

# 基本機能テストのみ実行（高速・API Key不要）
testthat::test_file("testthat/test_chatAI4R.R")

