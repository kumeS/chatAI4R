# UNDER DEVELOPMENT
# chatAI4BI: Chat-based Artificial Intelligence for Bioinformatic in R

## Description

Chat-based Artificial Intelligence (AI) for Bioinformatics, "chatAI4BI," is an R package designed to integrate the ChatGPT API with bioinformatics. This package aims to enable efficient data analysis and knowledge discovery based on a large language model (LLM)-based AI technique, ChatGPT. The package utilizes the ChatGPT API for natural language processing and provides a set of functions capable of executing various bioinformatics analysis methods.

## About this project

- R language usage for AI API
  - ChatGPT API
  - DeepL API
  - Text embeddings API (text-embedding-ada-002)
- LLM-based AI technique for Bioinformatics
  - ゲノム解析, タンパク質構造予測, 遺伝子発現解析, 変異解析
  - 自動解析: 解析デザイン, 統計, データ可視化, 考察, 質問応答
  - 専門文章の言語モデル: 自然言語での質問応答

## Installation

1. Start R.app

2. Run the following commands in the R console.

```r
#CRAN-version
install.packages("chatAI4BI")
library(chatAI4BI)

#Dev-version
devtools::install_github("kumeS/chatAI4BI")
library(chatAI4BI)
```

## Basic functions

- chat4R: Interact with GPT-3.5-turbo (default) using OpenAI API
- textEmbedding: Text Embedding from OpenAI API
- deepel: DeepL Translation Function

## Task-specific functions

- riken_pressrelease_text_jpn: 
- riken_pressrelease_textEmbedding
 
## Simple usage




## License

Copyright (c) 2023 Satoshi Kume released under the [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## Cite

Kume S. (2023) chatAI4BI: Chat-based Artificial Intelligence for Bioinformatic in R.

```
#BibTeX
@misc{Kume2023chatAI4BI,
  title={chatAI4BI: Chat-based Artificial Intelligence for Bioinformatic in R},
  author={Kume, Satoshi}, year={2023},
  publisher={GitHub}, note={R Package},
  howpublished={\url{https://github.com/kumeS/chatAI4BI}},
}
```

## Contributors

- Satoshi Kume

