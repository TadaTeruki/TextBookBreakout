// [ controller.pde ] コントローラに関する機能の定義

// カメラの利用に必要なパッケージのインポート
import processing.video.*;

/*
--------------------------------------------------------------------------------
 クラス : controller_info
 - コントローラの情報を管理
 - クラス controller によって更新された位置や角度等の情報を、他クラス間でやり取りする際に使う
 --------------------------------------------------------------------------------
 */

class controller_info {

  // middle_point_x_01: コントローラのx軸方向の中央の値。0.0~1.0の値をとり、それぞれ(左端)~(右端)をしめす
  // middle_point_y_01: コントローラのy軸方向の中央の値。
  float middle_point_x_01, middle_point_y_01;

  // angle: コントローラの角度
  float angle;

  // reliable: コントローラの出す情報が正確であるかどうか
  boolean reliable;

  // knocked: 教科書が振り上げられたかどうか  
  boolean knocked;

  // check_passed: 教科書の認識のチェック(ゲーム開始時と再開時に行われる) が正しく行われたかどうか
  boolean check_passed;

  // 初期化
  controller_info() {
    middle_point_x_01 = 0.5;
    middle_point_y_01 = 0.5;
    angle             = 0;
    reliable          = false;
    knocked           = false;
    check_passed      = false;
  }
}

/*
-----------------------------------------------------------------------------------
 クラス : controller
 - カメラの撮影データを取得して教科書を認識し、コントローラの情報を生成・更新する
 - ゲームで実際に利用する情報の直接的な提供は行わず、 クラス controller_infoを通してやり取りする
 -----------------------------------------------------------------------------------
 */
class controller {

  // cognition_table: カメラの撮影データ。"青" "緑" "弱い青と緑" "それ以外" の4つのみ格納
  int[][] cognition_table;

  // x_blue_flag_sum_table  : 青ピクセルの和を、x方向1ピクセルごとの累積和テーブルとして格納
  // x_green_flag_sum_table : 緑ピクセルの和を累積和で格納　( x_blue_flag_sum_tableと同様 )
  // y_sum_table            : 青ピクセルと緑ピクセルの両方の和を、y方向1ピクセルごとの累積和テーブルとして格納
  int[]   x_blue_flag_sum_table, x_green_flag_sum_table, y_sum_table;

  // xsize, ysize: cognition_tableの縦横のサイズを格納
  int     xsize, ysize;

  // cam: processing標準のキャプチャ用オブジェクト
  Capture cam;

  // unreliable_time: コントローラの情報が正確でないフレームが連続的に続いている状態の累積時間。教科書の振り上げ認識に利用
  int     unreliable_time;

  // last_cinfo: 最後に出力されたcontroller_infoを格納
  controller_info last_cinfo;

  // check_passed: 教科書の認識のチェック(ゲーム開始時と再開時に行われる) が正しく行われたかどうか
  boolean check_passed;

  // checker_w: 教科書チェック用のセルのx方向の数, checker_h: 教科書チェック用のセルのy方向の数
  // green_checker_h: 教科書チェック用のセルの、緑色部分のy方向の数。青色部分のy方向の数は逆算で求める
  int checker_w, checker_h, green_checker_h;


  // コンストラクタ
  controller(TextBookForce gameinfo) {

    String[] cameras_list = Capture.list();

    if (cameras_list.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } else {
      cam = new Capture(gameinfo, cameras_list[0]);
      cam.start();
    }
    last_cinfo = new controller_info();

    xsize = cam.width / CONTROLLER_PIXEL_INTERVAL;
    ysize = cam.height/ CONTROLLER_PIXEL_INTERVAL;

    cognition_table = new int[ysize+1][xsize+1];

    x_blue_flag_sum_table = new int[xsize+1];
    x_green_flag_sum_table = new int[xsize+1];
    y_sum_table = new int[ysize+1];

    unreliable_time = MAX_UNRELIABLE_TIME_FOR_KNOCK / CONTROLLER_UPDATE_TIME_INTERVAL +1;

    checker_w           = 15;
    checker_h           = 22;
    green_checker_h     = 9;
    check_passed        = false;
  }

  // カメラの撮影データを再取得し、教科書を読み取った上で、計算したコントローラの情報を出力
  controller_info update() {

    if (cam.available() == false || TIME%CONTROLLER_UPDATE_TIME_INTERVAL != 0) return last_cinfo;

    cam.read();
    controller_info cinfo = last_cinfo;

    cinfo.knocked = false;
    cinfo.check_passed = check_passed;

    for (int y = 0; y < ysize; y++) y_sum_table[y] = 0;

    for (int x = 0; x < xsize; x++) {
      x_blue_flag_sum_table [x] = 0;
      x_green_flag_sum_table[x] = 0;

      for (int y = 0; y < ysize; y++) {

        color col = cam.get(x*CONTROLLER_PIXEL_INTERVAL, y*CONTROLLER_PIXEL_INTERVAL);
        float r = red(col)+255;
        float g = green(col)+255;
        float b = blue(col)+255;
        float strength = COLOR_COGNITION_STRENGTH;

        if ( b*2 > (r+g)*strength) {
          cognition_table[y][x] = COLOR_BLUE;
          x_blue_flag_sum_table [x] += 1;
          y_sum_table[y]            += 1;
        } else if ( g*2 > (r+b)*strength) {
          cognition_table[y][x] = COLOR_GREEN;
          x_green_flag_sum_table[x] += 1;
          y_sum_table[y]            += 1;
        } else cognition_table[y][x] = COLOR_NONE;
      }
    }

    for (int y = 1; y < ysize-1; y++) {
      for (int x = 1; x < xsize-1; x++) {
        if (cognition_table[y][x] != COLOR_NONE) continue;
        for (int cy = -1; cy <= 1; cy += 2) {
          if ( cognition_table[y+cy][x] != COLOR_NONE ) cognition_table[y+cy][x] = COLOR_HIDDEN;
        }
        for (int cx = -1; cx <= 1; cx += 2) {
          if ( cognition_table[y][x+cx] != COLOR_NONE ) cognition_table[y][x+cx] = COLOR_HIDDEN;
        }
      }
    }

    for (int x = 1; x < xsize; x++) {
      x_blue_flag_sum_table [x] += x_blue_flag_sum_table [x-1];
      x_green_flag_sum_table[x] += x_green_flag_sum_table[x-1];
    }

    int middle_x = 0, min_score = -1, middle_y = 0;
    final int all_sum = x_blue_flag_sum_table[xsize-1] + x_green_flag_sum_table[xsize-1];
    float blue_bias_left = 0, blue_bias_right = 0;

    for (int x = 0; x < xsize; x++) {
      int blue_sum = x_blue_flag_sum_table[xsize-1];
      int right_blue_sum = x_blue_flag_sum_table[x];
      int left_blue_sum  = blue_sum-right_blue_sum;

      int green_sum = x_green_flag_sum_table[xsize-1];
      int right_green_sum = x_green_flag_sum_table[x];
      int left_green_sum  = green_sum-right_green_sum;

      int score = abs(right_green_sum-left_green_sum+right_blue_sum-left_blue_sum);
      int min_pixel_sum = int(float(cam.width*cam.height/(CONTROLLER_PIXEL_INTERVAL*CONTROLLER_PIXEL_INTERVAL))*MIN_PIXEL_RATIO)+1;

      if ((min_score < 0 || score < min_score) &&
        right_green_sum != 0 && left_green_sum != 0 &&
        green_sum >= min_pixel_sum && blue_sum >= min_pixel_sum
        ) {
        min_score = score;
        middle_x = x;
        blue_bias_right = (float(right_blue_sum)/float(blue_sum))/(float(right_green_sum)/float(green_sum));
        blue_bias_left = (float(left_blue_sum)/float(blue_sum))/(float(left_green_sum)/float(green_sum));
      }
    }

    for (int y = 1; y < ysize; y++) {
      y_sum_table[y] += y_sum_table[y-1];
      if ( abs(all_sum/2-y_sum_table[y]) < abs(all_sum/2-y_sum_table[middle_y]) ) middle_y = y;
    }

    if (min_score > 0) {
      cinfo.reliable = true;
      cinfo.middle_point_x_01 = 1.0-float(middle_x)/float(xsize);
      cinfo.middle_point_y_01 = float(middle_y)/float(ysize);
      if (blue_bias_left != 0.0) cinfo.angle = atan(log(blue_bias_right/blue_bias_left)/log(10));
    } else cinfo.reliable = false;

    if (cinfo.reliable) {
      cinfo.knocked = (
        unreliable_time >= MIN_UNRELIABLE_TIME_FOR_KNOCK/CONTROLLER_UPDATE_TIME_INTERVAL &&
        unreliable_time <= MAX_UNRELIABLE_TIME_FOR_KNOCK/CONTROLLER_UPDATE_TIME_INTERVAL
        );
      unreliable_time = 0;
    } else {
      unreliable_time++;
    }

    return cinfo;
  }

  // 撮影データの描画。
  void draw(float stage_w, float stage_h, float alpha) {
    int cpi = CONTROLLER_PIXEL_INTERVAL;

    for (float y = 0; y < stage_h; y++) {
      for (float x = 0; x < stage_w; x++) {
        int ctx = int(x/stage_w*float(cam.width) ) / cpi;
        int cty = int(y/stage_h*float(cam.height)) / cpi;

        color nc = get(int((stage_w-x)*DRAW_SCALE), int((y)*DRAW_SCALE));

        if (cognition_table[cty][ctx] == COLOR_BLUE) {
          set(int((stage_w-x)*DRAW_SCALE), int((y)*DRAW_SCALE), blend_color(alpha, color(100, 100, 250), nc));
        }

        if (cognition_table[cty][ctx] == COLOR_GREEN) {
          set(int((stage_w-x)*DRAW_SCALE), int((y)*DRAW_SCALE), blend_color(alpha, color(100, 250, 100), nc));
        }
      }
    }
  }

  // 教科書チェック用のセルの描画。ゲーム開始時と再開時のみ実行
  void draw_checker(float stage_w, float stage_h, float alpha) {

    noStroke();

    rectMode(CENTER);

    float rect_wh    = 20;
    float margin     = 6;
    float one_block  = rect_wh+margin;
    float max_expand = 1.1;

    int passed_pixel = 0;

    int cpi = CONTROLLER_PIXEL_INTERVAL;

    for (int y = 0; y < checker_h; y++) {

      for (int x = 0; x < checker_w; x++) {
        float rect_x = (stage_w-one_block*float(checker_w))*0.5 + one_block*float(x);
        float rect_y = (stage_h-one_block*float(checker_h))*0.5 + one_block*float(y);

        int ctx = int((1.0-rect_x/stage_w)*float(cognition_table[0].length));
        int cty = int(rect_y/stage_h*float(cognition_table.length));
        float expand = 1.0;

        if (y < green_checker_h) {

          if (cognition_table[cty][ctx] == COLOR_GREEN) {
            fill(100, 200, 100, 200*alpha);
            expand = max_expand;
            passed_pixel++;
          } else {
            fill(100, 150, 100, 100*alpha);
          }
        } else {
          if (cognition_table[cty][ctx] == COLOR_BLUE) {
            fill(100, 100, 250, 250*alpha);
            expand = max_expand;
            passed_pixel++;
          } else {
            fill(100, 100, 150, 100*alpha);
          }
        }

        rect(rect_x, rect_y, rect_wh*expand, rect_wh*expand);
      }
    }

    if (float(passed_pixel)/float(checker_w*checker_h) > CONTROLLER_CHECK_PROPORTION) {
      check_passed = true;
    } else {
      check_passed = false;
    }

    rectMode(CORNER);
  }
}
