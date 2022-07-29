// [ meteo.pde ] 隕石に関する機能の定義

/*
------------------------------------
クラス : meteo_flag
 - 他クラスとの隕石の振る舞いのやり取りに使う
------------------------------------
*/
class meteo_flag {
  
  // broken: 対象の隕石がボールによって壊されたかどうか, fallen: 対象の隕石が地表に落下したかどうか
  boolean broken, fallen;

  // コンストラクタ
  meteo_flag() {
    broken = false;
    fallen = false;
  }
}



/*
----------------------------------------------
クラス : meteo_info
 - 一つ一つの隕石の情報を管理
 - ボールとの衝突判定、あるいは地表への落下判定を行い、
   クラス meteo_flag を通して他クラスと結果を共有する
----------------------------------------------
*/

class meteo_info {

  // x, y : 隕石のx座標およびy座標の位置
  // wh   : 隕石の幅と高さ
  // v    : 隕石の速度
  float x, y, wh, v;
  
  // targ_x, targ_y: 隕石の目的地のx座標およびy座標の位置
  float targ_x, targ_y;

  // 初期化
  // 隕石の情報は、初期化時にランダムで決定される
  meteo_info(float _min_x, float _max_x, float _min_y, float _max_y, 
    float _min_wh, float _max_wh, 
    float _targ_y, float _min_v, float _max_v) {

    x  = random(_min_x, _max_x);
    y  = random(_min_y, _max_y);
    wh = random(_min_wh, _max_wh);
    targ_x = random(_min_x, _max_x);
    targ_y = _targ_y;
    v = random(_min_v, _max_v);
  }

  // 隕石の進む角度の取得
  float get_angle() {

    if (x == targ_x) {
      return -PI;
    }

    float raw_angle = atan((targ_y-y)/(targ_x-x));

    if (targ_x < x) {
      return raw_angle;
    } else {
      return raw_angle-PI;
    }
  }

  // フレームごとの処理
  meteo_flag process(ball_info binfo) {

    if (TIME%METEO_ANIMATION_INTERVAL == 0) generate_particle(PARTICLE_TYPE_METEO_TAIL, x, y, wh*0.3);

    float angle = get_angle();
    x += -cos(angle)*v;
    y += -sin(angle)*v;

    meteo_flag flag = new meteo_flag();

    if (binfo.is_laid == false && x < binfo.x+binfo.r && y < binfo.y+binfo.r && x > binfo.x-binfo.r && y > binfo.y-binfo.r) {
      flag.broken = true;
      generate_particle(PARTICLE_TYPE_METEO_BROKEN, x, y, wh);
    }
    if ( y > targ_y) {
      flag.fallen = true;
      generate_particle(PARTICLE_TYPE_METEO_FALLEN, x, y, wh);
    }
    return flag;
  }

  // 描画
  void draw() {
    stroke(180);
    int mai = METEO_ANIMATION_INTERVAL;
    strokeWeight((mai-TIME%mai)/8);
    noFill();
    float nwh = wh/4+wh/4*(float(TIME%mai)/mai)*3;
    rect(x-nwh/2, y-nwh/2, nwh, nwh);

    noStroke();
    fill(220);
    rect(x-wh/4, y-wh/4, wh/2, wh/2);
  }
}
