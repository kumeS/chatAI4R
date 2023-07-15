#load script
source("https://gist.githubusercontent.com/kumeS/ba0a6219b180a42c4cdc82baf2d4b47e/raw/0b303d8927dfc294b475240f81d63cfca5fe7794/generateImage_for_gist.R")

#R script
browseURL("https://gist.github.com/kumeS/ba0a6219b180a42c4cdc82baf2d4b47e")

#自作したプロンプト
pr <- "white cat island sea ocean july hokkaido bear happy"

#実行: DALL·E 2を実行
img <- generateImage4R(pr)

#結果表示
Display(img)

#GPT-4が生成したプロンプト
gpt <- "Create an image of a joyful white cat, playfully prancing on a sandy island surrounded by the blue ocean, under the radiant July sun in Hokkaido, Japan. To one side, a friendly local bear observes the scene with amusement."

#実行: DALL·E 2を実行
gpt_img <- generateImage4R(gpt)

#結果表示
Display(gpt_img)

#photorealisticプラグインでプロンプト生成 + GPT-4でDALL-E 2が理解しやすいに最適化

#案1
photo1 <- "Imagine a serene scene in Hokkaido in July. A white cat is happily lounging on an island surrounded by the vast ocean. In the distance, a bear is also enjoying the summer day. The scene is captured with a high-resolution 16k camera, using a raw style to highlight the natural beauty of the scene. The lighting is soft, illuminating the scene with the warm glow of a summer day. The color palette is dominated by the cool blues of the ocean and the warm whites of the cat and the sandy island. The composition is balanced, with the cat in the foreground and the bear in the distance, creating a sense of depth."

#実行: DALL·E 2を実行
photo1_img <- generateImage4R(photo1)

#結果表示
Display(photo1_img)

#案2
photo2 <- "Picture a summer day in Hokkaido. A white cat is basking in the sun on an island in the middle of the sea. Not too far away, a bear is also enjoying the day. The scene is captured in a raw style with a high-resolution 16k camera. The lighting is natural, casting soft shadows and highlighting the textures of the scene. The colors are vibrant, with the blue of the ocean contrasting with the white of the cat and the brown of the bear. The composition is carefully arranged, with the cat and the bear positioned to draw the viewer's eye across the scene."

#実行: DALL·E 2を実行
photo2_img <- generateImage4R(photo2)

#結果表示
Display(photo2_img)

