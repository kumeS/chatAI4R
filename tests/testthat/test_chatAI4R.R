# ビルド時テスト: API Key不要の基本機能テスト
library(testthat)
library(chatAI4R)

test_that("slow_print_v2 function works", {
  # 出力をキャプチャしてテスト（高速化のため短いdelay）
  expect_output(slow_print_v2("Hello", delay = 0.01), "Hello")
  expect_output(slow_print_v2("Test", random = TRUE, delay = 0.01), "Test")
})

test_that("ngsub function works", {
  # 文字列正規化テスト
  result <- ngsub("  Hello   World  ")
  expect_true(is.character(result))
  expect_true(nchar(result) > 0)
})

test_that("removeQuotations function works", {
  # 引用符削除テスト
  result <- removeQuotations("'Hello World'")
  expect_equal(result, "Hello World")
  
  result2 <- removeQuotations('"Test String"')
  expect_equal(result2, "Test String")
})

test_that("Package loads correctly", {
  # パッケージが正常にロードされることを確認
  expect_true("chatAI4R" %in% loadedNamespaces())
})
