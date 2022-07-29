// [ ball.pde ] ボールに関する機能の定義

/*
------------------------------------
クラス : ball_info
 - ボールの情報を管理
 - フレームごとの処理を定義
 - 描画内容を定義
------------------------------------
*/

class ball_info {
  // x, y    : x座標とy座標
  // r       : 半径
  // velocity: ボールの速さ
  float x, y, r, velocity;

  // dx: x方向の速度
  // dy: y方向の速度
  // - どちらも、要素velocityをもとに計算される
  float dx, dy;

  // max_collision_check_interval:  ボールとパドルの衝突判定の1フレームあたりの回数の最大値。
  //                                ボールとパドルのすり抜けを防ぐため、双方が近づいたときに衝突判定を高頻度にする
  int max_collision_check_interval;

  // paddle_skip: ボールとパドルの衝突判定が無効であるかどうか
  boolean paddle_skip;

  // is_laid: ボールがパドル上で待機しているかどうか
  boolean is_laid;

  // time: 内部時間
  int time;

  // コンストラクタ
  ball_info(float _x, float _y, float _r, float _velocity, int _max_collision_check_interval) {
    x = _x;
    y = _y;
    r = _r;
    velocity = _velocity;
    dx = 0;
    dy = 0;
    max_collision_check_interval = _max_collision_check_interval;
    paddle_skip = false;
    is_laid = true;
    time = 0;
  }

  // dx, dyの値をもとに、ボールの進む速さを取得
  float get_velocity() {
    return sqrt((dx*dx)+(dy*dy));
  }

  // dx, dyの値をもとに、ボールの進む角度を取得
  float get_angle() {
    if (dx == 0) {
      return 0;
    }
    float datan = atan(dy/dx);
    if (dx>0) {
      return -datan;
    } else {
      return PI-datan;
    }
  }

  // ステージからのはみ出し(x/y)、パドルとの衝突判定、ボールの落下の4つを検出し、結果をフラグとして出力。
  int check_ball_collision_flag(paddle_info pinfo, float stage_x, float stage_w, float stage_h) {
    int xflag = 0, yflag = 0, pflag = 0, goneflag = 0;
    if (x+dx < stage_x || x+dx > stage_x+stage_w) {
      xflag = 1;
    }
    if (y+dy < 0) {
      yflag = 1;
    }
    if (y+dy > stage_h) {
      goneflag = 1;
    }

    if (paddle_skip == false) {
      float ptan = tan(-pinfo.angle);
      float hdist = abs(ptan*x-y+pinfo.y-ptan*pinfo.x)/sqrt(pow(ptan, 2)+1);

      float iptan = -1.0/ptan;
      float wdist = abs(iptan*x-y+pinfo.y-iptan*pinfo.x)/sqrt(pow(iptan, 2)+1);

      if (hdist < get_velocity()*max_collision_check_interval+r*0.5 && wdist < pinfo.w/2+r*0.5) {
        pflag = 1;
      }
    }

    return xflag+yflag*2+pflag*4+goneflag*8;
  }

  // check_ball_collision_flagを実行し、結果を元にボールの振る舞いを更新する。
  int collision_process(paddle_info pinfo, float stage_x, float stage_w, float stage_h) {
    int flag = check_ball_collision_flag(pinfo, stage_x, stage_w, stage_h);
    if (flag%2 == 1) {
      dx=-dx;
      paddle_skip = false;
    }
    if ((flag/2)%2 == 1) {
      dy=-dy;
      paddle_skip = false;
    }
    if ((flag/4)%2 == 1) {

      float ball_v = get_velocity();
      float ball_angle = get_angle();
      paddle_skip = true;

      float new_angle = pinfo.angle*2-(ball_angle+PI/2);
      while (new_angle>PI)new_angle -= PI*2;
      while (new_angle<-PI)new_angle += PI*2;

      if (abs(new_angle)>PI/3) {
        if (new_angle > 0) {
          new_angle=  PI/3;
        } else {
          new_angle= -PI/3;
        }
      }

      if (dy>0) {
        dx = -sin(new_angle)*ball_v;
        dy = -cos(new_angle)*ball_v;
      }
    }

    if ((flag/8)%2 == 1) {
      gone();
    }
    return flag;
  }

  // 1フレームあたりに行う全体の処理。衝突判定、ボール動作時のパーティクルの生成などを行う。
  int process(paddle_info pinfo, float stage_x, float stage_w, float stage_h) {
    int collision_flag = 0; 
    if (is_laid) {
      dx = 0;
      dy = 0;
      x = pinfo.sim_x;
      y = pinfo.y-pinfo.h/2-r/2;
      time = 0;
      return 0;
    }

    if ( x > pinfo.y-pinfo.w/2 ) {
      for (int i = 0; i < max_collision_check_interval; i++) {
        x += dx;
        y += dy;
        collision_flag = collision_process(pinfo, stage_x, stage_w, stage_h);
      }
    } else {
      x += dx*float(max_collision_check_interval);
      y += dy*float(max_collision_check_interval);
      collision_flag = collision_process(pinfo, stage_x, stage_w, stage_h);
    }

    time++;

    if (time%4 == 0) generate_particle(PARTICLE_TYPE_BALL_TAIL, x, y, r*0.5);

    return collision_flag;
  }

  // ボールがパドルから離れる処理。
  void start_to_move(paddle_info pinfo) {
    is_laid = false;

    dx = -sin(pinfo.sim_angle)*velocity;
    dy = -cos(pinfo.sim_angle)*velocity;
  }

  // 教科書を振り上げたときのボールの挙動。
  void knock(paddle_info pinfo, float stage_x, float stage_w, float stage_h) {
    if (is_laid == false) return;

    if (pinfo.sim_x < stage_x+r || pinfo.sim_x > stage_x+stage_w+r) {
      return;
    }

    start_to_move(pinfo);
    process(pinfo, stage_x, stage_w, stage_h);
  }

  // ボール落下時の処理。
  void gone() {
    is_laid = true;
  }

  // ボールを描く処理。
  void draw(paddle_info pinfo) {
    if (!is_laid) {
      stroke(210);
      noFill();
      strokeWeight((40-time%40)/6);
      circle(x, y, r*(0.5+(0.5*float(time%40)/40.0)));

      fill(250);
      noStroke();
      circle(x, y, r*0.5);
    } else {
      fill(250);
      noStroke();
      circle(pinfo.sim_x, pinfo.y-r*0.5, r*0.5);
    }
  }
}
