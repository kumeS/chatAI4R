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
#Midjourney用(Photorealistic画像)のプロンプト作成支援ツール

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


m1 <- "Imagine a unique perspective of Japan in July. A large, detailed map of Japan is laid out, with a special emphasis on the vastness of Hokkaido. A white cat playfully sits on the map, adding a touch of whimsy to the scene. The Japan Trench is depicted as a significant feature, its huge size clearly marked. The image is captured in a raw style with a high-resolution 16k camera, the lighting is natural, and the colors are vibrant, with the white of the cat contrasting against the colors of the map."
m1_img <- generateImage4R(m1)
Display(m1_img)

m2 <- "Picture a large, detailed map of Japan during the summer month of July. The island of Hokkaido is prominently displayed, and the immense Japan Trench is clearly marked. A white cat is playfully positioned on the map, adding a touch of charm to the scene. The image is captured in a raw style with a high-resolution 16k camera. The lighting is soft, highlighting the details of the map and the cat, and the colors are bright and clear, with the white of the cat standing out against the map."
m2_img <- generateImage4R(m2)
Display(m2_img)

m3 <- "A white cat lounging on a detailed map of Japan during the warm month of July. The map is unique, with the Japan Trench artistically represented as a dramatic cliff. The scene is captured in a raw style, with natural lighting and vibrant colors."
m3_img <- generateImage4R(m3)
Display(m3_img)

m4 <- "Imagine a detailed and highly realistic map of Japan. The map is captured in a raw style with a high-resolution 16k camera, highlighting the intricate details of Japan's geography. The lighting is natural, illuminating the map's features, and the colors are vibrant, reflecting the diverse landscapes of Japan."
m4_img <- generateImage4R(m4)
Display(m4_img)

m5 <- "Picture a large, detailed map of Japan. The map is rendered in a raw style with a high-resolution 16k camera, showcasing the complexity of Japan's geography. The lighting is soft, highlighting the details of the map, and the colors are bright and clear, representing the various regions of Japan."
m5_img <- generateImage4R(m5)
Display(m5_img)
