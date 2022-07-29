// [ paddle.pde ] 隕石に関する機能の定義

/*
----------------------------------------------
クラス : paddle_info
 - パドルの情報を管理
 - フレームごとの処理を定義
 - 描画内容を定義
----------------------------------------------
*/

class paddle_info {
  // x, y   : x座標とy座標
  // w, h   : 縦幅と横幅
  // angle  : 角度
  float x, y, w, h, angle;

  // sim_x     : 描画する際の擬似的なx座標の値 
  // sim_angle : 描画する際の擬似的な角度の値
  // - x や angleをパドルの描画にそのまま使った場合、かくついた動きとなり、視認性が下がる。
  //   そのことから、パドルの動きを擬似的にスムーズにする方策として、元の変数の値の移動を補間する別の変数を用意している。
  //   なおこれらは、ボールとの衝突判定においても都合が良いことから、描画だけでなく衝突判定にも使われる。
  float sim_x, sim_angle;

  // line_width: 描画時の枠の太さ。教科書を振り上げるまで減少し続ける
  // first_line_width: line_widthの最小値
  float line_width, first_line_width;

  // 初期化
  paddle_info(float _x, float _y, float _w, float _h, float _first_line_width) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    sim_x = _x;

    angle = 0;
    sim_angle = 0;
    first_line_width = 2;
    line_width = first_line_width;
  }

  // 描画
  void draw() {
    translate(sim_x, y);
    rotate(-sim_angle);

    strokeWeight(line_width);

    stroke(150);
    noFill();
    rect(-w/2, -h, w, h);

    noStroke();
    fill(230);
    rect(-w/2, -h, w, h);

    if (line_width != first_line_width) {
      line_width = (line_width-first_line_width)*0.95+first_line_width;
    }

    rotate(sim_angle);
    translate(-sim_x, -y);
  }

  // フレームごとの処理
  void process(controller_info cinfo) {
    if (cinfo.reliable == true) {
      x = cinfo.middle_point_x_01*float(BASE_WIDTH);
      angle = cinfo.angle;
    }

    sim_x = (x-sim_x)*0.25+sim_x;
    sim_angle = (angle-sim_angle)*0.25+sim_angle;
  }

  // 枠線を太くする処理
  void enbold() {
    line_width = 15;
  }
}
