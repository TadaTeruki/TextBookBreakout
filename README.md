
<<<<<<< HEAD
# 教科書Breakout
=======
# TextBookBreakout
>>>>>>> rename

制作 : 多田 瑛貴

<img src="https://user-images.githubusercontent.com/69315285/181797584-5ee26c4f-5110-453d-ae63-7e4d67915e36.png" height="300" />

## あらすじ
<span style="line-height:1.5">
宇宙から未知の隕石群がやってきた！<br>
このままでは地球は滅亡してしまいます.<br>
華の未来大のエースとして選ばれしあなたは、<br>
大量の隕石から、地球を守る役目を果たすこととなりました.<br>
<br>
未来大生に託された<span style="font-weight:bold">「最終兵器」</span>を駆使し、地球の未来を守りましょう！
</span>

## 工夫ポイント

- **教科書をコントローラとして利用**
<span style="font-size:smaller">全操作が教科書で完結。教科書認識の実装には相当時間をかけた</span>

- **ラケットの角度が柔軟に変わる**
<span style="font-size:smaller">ボールの当たり判定・進行方向もラケットの角度で調節可能。この実装も難しかった</span>

- **背景画像の自動生成** - 関数noise()を活用
<span style="font-size:smaller">ゲーム初期化時、描画内容を画像データとして内部で事前に生成。ループを軽量化</span>

- **演出面の強化** - エフェクトの生成・イージング

- **BGM・一部効果音は自力で制作**
- カメラ・オーディオ機能以外、**外部ライブラリ未使用**


## 開発・実行環境

Processing 3.5.4

## プレイ方法

### Processing(IDE)を使った実行

1. ディレクトリ `TextBookBreakout` 内の `TextBookBreakout.pde` を開く
2. 実行する

## 注意点

実行可能環境の拡大に努めていますが、以下の状況では動作が難しいことが判明しています :<br>

 - 日本語でセットアップされたWindowsの環境
    (実行ファイルへのパス内に日本語の文字で書かれたディレクトリがあると、実行できないようです)
