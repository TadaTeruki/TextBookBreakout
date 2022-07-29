// [ particle.pde ] パーティクルに関する機能の定義

/*
-------------------------------------------------------------
クラス : unit_particle
 - 独立した振る舞いを持つ各パーティクルの情報を管理
 - unit_particleが他クラスによって直接生成されることはなく、
   パーティクルの集合を表すクラス particle_infoの一部として生成される
-------------------------------------------------------------
*/

class unit_particle {
  // x, y   : x座標とy座標
  // wh     : 縦横幅
  // dx     : x方向の速度
  // dy     : y方向の速度
  float x, y, wh, dx, dy;

  // is_circle : 円として描画されるかどうか (そうでない場合は、矩形として描画される)
  boolean is_circle;

  // particle_type: パーティクル演出の種類
  //  - PARTICLE_TYPE_METEO_FALLEN (隕石の地表落下)など、いくつかの種類を設けている (global.pdeを参照)
  //    パーティクルの種類によって、動きや大きさの遷移のしかたが変わる
  int particle_type;

  // time : 内部時間
  float time;

  // col : 色
  color col;

  // 初期化
  unit_particle(float _x, float _y, float _wh, boolean _is_circle, color _col, float _dx, float _dy, int _particle_type) {
    x = _x;
    y = _y;
    wh = _wh;
    particle_type = _particle_type;
    dx = _dx;
    dy = _dy;
    is_circle = _is_circle;
    col = _col;
    time = 0;
  }

  // フレームごとの処理を実行
  boolean process() {

    float dwh = 0;
    switch(particle_type) {  
    case PARTICLE_TYPE_METEO_TAIL:
      {
        dwh += -wh*0.005;
        break;
      }  
    case PARTICLE_TYPE_METEO_BROKEN:
      {
        dwh += -wh*0.07;
        break;
      }
    case PARTICLE_TYPE_METEO_FALLEN:
      {
        dwh += -wh*0.07;
        break;
      }
    case PARTICLE_TYPE_BALL_TAIL:
      {
        dwh += -wh*0.1;
        break;
      }
    }
    time++;

    x +=  dx;
    y +=  dy;
    wh += dwh;

    if (wh < 0.0) return false;

    return true;
  }

  // 描画
  void draw(float pt_x, float pt_y, float scale) {
    noStroke();
    fill(red(col), green(col), blue(col));
    float nwh = wh*scale;
    float nx = x*scale;
    float ny = y*scale;
    if (is_circle) {
      circle(pt_x+nx, pt_y+ny, nwh/2);
    } else {
      rect(pt_x+nx-nwh/2, pt_y+ny-nwh/2, nwh, nwh);
    }
  }
}



/*
----------------------------------------------
クラス : particle_info 
 - パーティクルの集合を管理
 - パーティクル生成時、このクラスでの処理を通して、パーティクル演出の種類(particle_type)が適用される
----------------------------------------------
*/

class particle_info {
  // particle_type: パーティクル演出の種類
  int type;

  // x, y   : x座標とy座標
  // scale  : 標準の大きさと比べた相対的な大きさ
  float x, y, scale;

  // available: パーティクルが1つでも有効かどうか
  boolean available;

  // units: 各パーティクルの情報
  ArrayList<unit_particle> units;

  // 初期化
  particle_info(int _type, float _x, float _y, float _scale) {
    type = _type;
    x = _x;
    y = _y;
    scale = _scale;
    available = true;

    units = new ArrayList<unit_particle>();

    switch (type) {
    case PARTICLE_TYPE_NONE:
      {
        available = false;
        break;
      }	
    case PARTICLE_TYPE_METEO_TAIL:
      {
        units.add(new unit_particle(0, 0, 1.0, false, color(210), 0, 0, type));
        break;
      }	
    case PARTICLE_TYPE_METEO_BROKEN:
      {
        float ptnum = 8.0;
        for (float i = 0; i < ptnum; i++) {
          float angle = (PI*2.0)/ptnum*i;
          float dx = cos(angle)*0.04;
          float dy = sin(angle)*0.04;
          units.add(new unit_particle(0, 0, 1.0, true, color(240), dx, dy, type));
        }
        break;
      }
    case PARTICLE_TYPE_METEO_FALLEN:
      {
        float ptnum = 16.0;
        for (float i = 0; i < ptnum; i++) {
          float angle = (PI*2.0)/ptnum*i;
          float dx = cos(angle)*random(0.01, 0.05);
          float dy = sin(angle)*random(0.01, 0.05);
          units.add(new unit_particle(0, 0, 1.0, true, color(240), dx, dy, type));
        }
        break;
      }
    case PARTICLE_TYPE_BALL_TAIL:
      {
        units.add(new unit_particle(0, 0, 1.0, true, color(230), 0, 0, type));
        break;
      }
    }
  }

  // フレームごとの処理
  boolean process() {

    for (int i=0; i<units.size(); i++) {
      if (!units.get(i).process()) {
        units.remove(i);
        i--;
      }
    }
    if (units.size() == 0) {
      available = false;
    }

    return available;
  }

  // 描画
  void draw() {
    for (int i=0; i<units.size(); i++) {
      units.get(i).draw(x, y, scale);
    }
  }
}


/*
以下、パーティクルの生成に関わるコンテナおよび関数

クラス内のメソッドとして記述されておらず、あえてグローバルな要素となっているのは
あらゆるクラスで実行され、かつメソッド間での引数としてのやり取りが難しいため
*/

// パーティクルの集合を格納する可変長リスト
ArrayList<particle_info> particles;

// パーティクルの初期化
void init_particles() {
  particles = new ArrayList<particle_info>();
}

// パーティクルの生成
void generate_particle(int type, float x, float y, float scale) {
  particles.add(new particle_info(type, x, y, scale));
}

// 存在する全部のパーティクルの集合のフレームごとの処理
void process_particles() {
  for (int i=0; i<particles.size(); i++) {
    if (particles.get(i).process() == false) {
      particles.remove(i);
    }
  }
}

void draw_particles() {
  for (int i=0; i<particles.size(); i++) {
    particles.get(i).draw();
  }
}
