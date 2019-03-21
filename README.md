# GrabBlurUI
GrabTextureを使って狙ったUIの後ろにBlurをかける

シェーダーパラメータのみで動くので導入が楽ちん

黒マスク画像の下の3Dオブジェクト、UIの青いイメージにはブラ―がかかっていて、マスクの上の画像にはブラ―がかかってない
![sample](https://user-images.githubusercontent.com/9998998/54770771-437a7a80-4c47-11e9-92ba-cdac3f636cfb.png)

参考にさせていただいたコード
http://memo.devjam.net/clip/827

forの回数が増えると処理が比例するように重くなるためもろもろ省いてるがまだ重い
家の貧弱Windowsでblursize20にして回まわすとだいたい30FPSがギリギリ

もっと軽いアルゴリズムに変えれば使い物になるかも

そもそもGrabPass自体が重いという噂もちらほら
