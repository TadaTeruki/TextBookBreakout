// [ background.pde ] 背景画面に関する機能の定義

/*
------------------------------------------------------------------------
クラス : background_info
 - 背景画面を管理
 - 景色の自動生成とイメージへの書き込み・各フレームでの読み出し
   (イメージを通さず生成と描画を各フレームごとに行うこともできるが、処理が非常に低速)
------------------------------------------------------------------------
*/

class background_info {

  // 背景画面のイメージ
  PImage background_img;

  // game_x, game_w: ウインドウ全体のうちの、ブロック崩し画面の横の位置と幅
  float game_x, game_w;

  // 以下、山の生成に関する要素---

  // mountain_max_noise: 各x方向ピクセル・奥行きごとのノイズの最大値
  int[][] mountain_max_noise;

  // mountain_base_max_height: 山の奥行きの最大値
  int mountain_base_max_height;

  // mountain_base_interval: 山の奥行きの間隔
  int mountain_base_interval;

  // mountain_min_height, mountain_max_height: 山の最大・最低の高さ
  int mountain_min_height, mountain_max_height;

  // 山のおおよその数
  float mountain_num;

  // ---


  // コンストラクタ
  // 山の生成・イメージへの書き込みは初期化時に一括で行う
  background_info(float _game_x, float _game_w) {

    game_x = _game_x;
    game_w = _game_w;

    mountain_base_max_height = 80;
    mountain_base_interval = 2;
    mountain_min_height = 0;
    mountain_max_height = MOUNTAIN_HEIGHT;
    mountain_num = 2.0;

    background_img = createImage(BASE_WIDTH, BASE_HEIGHT, ARGB);

    for (int y = 0; y < int(BASE_HEIGHT); y++) {
      color down = color(90, 110, 170), up = color(220, 180, 150);
      for (int x = 0; x < int(BASE_WIDTH); x++) {
        put_pixel(x, y, blend_color(float(y)/BASE_HEIGHT, up, down));
      }
    }

    mountain_max_noise = new int[mountain_base_max_height+1][int(BASE_WIDTH)+1];

    int max_base = mountain_base_max_height/mountain_base_interval;

    for (int base = 0; base<max_base; base++) {

      for (int x = 0; x <int(BASE_WIDTH); x++) {

        mountain_max_noise[base][x] = 0;

        float z = float(base)/float(max_base);

        float noise = octaved_noise(float(x)/float(BASE_WIDTH)*mountain_num, z, 0.0, 18, 0.6);
        float terrain = (noise*(z+1.0))*0.5;

        int mountain_noise = int(terrain*float(mountain_max_height-mountain_min_height))+mountain_min_height+base;
        if (mountain_max_noise[base][x] < mountain_noise) {
          mountain_max_noise[base][x] = mountain_noise;
        }
      }
    }

    for (int x = 0; x<int(BASE_WIDTH); x++) {

      for (int base = 0; base<max_base; base++) {
        color c2 = color(120, 160, 170);
        color c1 = color(70, 60, 95);
        color mountain_color = blend_color(float(base)/float(max_base), c1, c2);

        float adj = (mountain_max_height-mountain_min_height)*0.25;

        int y_start = int(BASE_HEIGHT-mountain_max_noise[base  ][x] +adj);

        if (base == 0) {
          for (int y = y_start; y <= int(BASE_HEIGHT); y++) {
            put_pixel(x, y, mountain_color);
          }
        } else {
          for (int y = y_start; y <= int(BASE_HEIGHT-mountain_max_noise[base-1][x]) +adj; y++) {
            put_pixel(x, y, mountain_color);
          }
        }
      }
    }
  }

  // イメージへのピクセル単位での書き込み
  void put_pixel(int x, int y, color col) {
    if (x >= BASE_WIDTH || y >= BASE_HEIGHT) return;
    background_img.pixels[y*int(BASE_WIDTH)+x] = col;
  }


  // 描画 (イメージの読み出し)
  void draw() {
    image(background_img, 0, 0);
  }
}
