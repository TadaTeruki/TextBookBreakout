// [ gamehost.pde ] ゲーム全体を包括的に管理するオブジェクトの定義

/*
----------------------------------------------
クラス : game_host
 - ゲーム全体を包括的に管理
 - ボールやパドルなど、ゲームで使う要素をまとめて管理
 - 画面遷移・設定項目の適用
----------------------------------------------
*/

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

class game_host {

  // phase: 現在のゲームの画面を管理
  //        タイトル画面なら、定数'PHASE_TITLE'と同じになる(global.pdeを参照)
  int phase;
  
  // game_x, game_y, game_w, game_h: ウインドウ全体のうちの、ブロック崩し画面の縦横の位置と幅
  float game_x, game_y, game_w, game_h;

  // ball: ボールの情報 (ball.pdeを参照)
  ball_info ball;

  // paddle: パドルの情報 (paddle.pdeを参照)
  paddle_info paddle;

  // meteo_data: 隕石の情報を格納する可変長リスト (隕石の情報に関しては、meteo.pdeを参照)
  ArrayList<meteo_info> meteo_data;
  
  // meteo_interval: 隕石が生成される間隔
  // meteo_time: 隕石の生成に使う内部時間
  int meteo_interval, meteo_time;

  // background: 背景の情報 (background.pdeを参照)
  background_info background;

  // controller_checker_alpha: 教科書認識チェックUI(ゲーム開始時と再開時に表示されるインターフェイス) の描画の透明度
  float controller_checker_alpha;

  // score: スコア, hi_score: ハイスコア
  int score, hi_score;

  // hi_score_updated: ゲームオーバー後、ハイスコアが更新されたかどうかを格納
  boolean hi_score_updated;

  // vutality: 残り数を管理
  int vitality;

  // gameover: ゲームオーバーのフラグ
  int gameover;

  Minim minim;
  AudioPlayer bgm_player;
  AudioPlayer se_start;
  AudioPlayer se_destruction;
  AudioPlayer se_swing;
  AudioPlayer se_meteo_broken;
  AudioPlayer se_meteo_fallen;
  AudioPlayer se_reflection;

  // コンストラクタ
  game_host(TextBookBreakout gameinfo, float _w01) {

    minim = new Minim(gameinfo);
    bgm_player      = minim.loadFile("./resources/TBFBGM.mp3");
    se_start        = minim.loadFile("./resources/TBFstart.mp3");
    se_destruction  = minim.loadFile("./resources/destruction1.mp3");
    se_swing        = minim.loadFile("./resources/button02b.mp3");
    se_meteo_broken = minim.loadFile("./resources/button03b.mp3");
    se_reflection   = minim.loadFile("./resources/button05.mp3");
    se_meteo_fallen = minim.loadFile("./resources/heavy_punch1.mp3");

    se_meteo_broken.setGain(0);
    se_swing.setGain(-5);
    se_destruction.setGain(-15);
    se_meteo_fallen.setGain(-10);

    game_y = 0;
    game_h = float(BASE_HEIGHT);
    game_w = float(BASE_WIDTH)*_w01;
    game_x = (float(BASE_WIDTH)-game_w)*0.5;
    background = new background_info(game_x, game_w);
    
    String hi_score_data[] = loadStrings("textbookforce_hi_score.txt");
    if (hi_score_data == null) {
      hi_score = 0;
    } else {
      hi_score = int(hi_score_data[0]);
    }

    set_phase(PHASE_TITLE);
    set_font(30);
  }

  // サイズに合わせてフォントをセット
  void set_font(int size) {
    textFont(createFont("", 16, true), size);
  }

  // 背景含むウインドウ全体を描画
  void draw_stage() {

    background.draw();
    noStroke();
    fill(0, 0, 0, 50);
    rect(0, 0, game_x, BASE_HEIGHT);
    rect(game_x+game_w, 0, BASE_WIDTH, BASE_HEIGHT);
  }

  // タイトル画面に遷移した際の最初の処理
  void init_title() {
    controller_checker_alpha = 1.0;
  }

  // 結果画面に遷移した際の最初の処理
  void init_result() {
    controller_checker_alpha = 0.0;
    gameover = 100;

    if (score > hi_score) {
      hi_score = score;
      hi_score_updated = true;
      String new_hi_score_data[] = new String[1];
      new_hi_score_data[0] = str(hi_score);
      saveStrings("textbookforce_hi_score.txt", new_hi_score_data);
    }
  }

  // ゲーム開始時の最初の処理
  void init_game() {
    ball = new ball_info(float(BASE_WIDTH/2), float(BASE_HEIGHT/2), 40, 0.28, 30);
    paddle = new paddle_info(float(BASE_WIDTH/2), float(BASE_HEIGHT)*0.9, 135, 15, 1);

    meteo_time = meteo_interval;
    meteo_data = new ArrayList<meteo_info>();
    meteo_interval = FIRST_METEO_GENERATION_INTERVAL;

    score = 0;
    vitality = MAX_VITALITY;
    gameover = 0;
    hi_score_updated = false;

    bgm_player.loop();
  }

  // タイトル画面でのフレームごとの処理内容
  void title_process(controller_info cinfo) {
    draw_stage(); 

    cont.draw(1024, 1024, 0.2);
    cont.draw_checker(1024, 1024, controller_checker_alpha);

    if (cinfo.check_passed == true) {
      se_start.play(0);
      set_phase(PHASE_GAME);
    }

    fill(240);
    textAlign(CENTER);
    set_font(30);
    text("Capture your textbook to start", game_x+game_w*0.5, game_h*0.85);
    set_font(20);

    fill(220);
    text("HI-SCORE : " + String.valueOf(hi_score), game_x+game_w*0.5, 190);
    
    set_font(40);
    for(int i=1; i >= 0; i--){
      fill(220-i*120);
      text("TextBookBreakout", game_x+game_w*0.5+i*2, 150+i*5);
    }

  }

  // 結果画面でのフレームごとの処理内容
  void result_process(controller_info cinfo) {
    draw_stage();
    process_particles();
    draw_particles();

    cont.draw(1024, 1024, 0.2);

    if (gameover > 0) {
      fill(240);
      textAlign(CENTER);
      text("GAME OVER", game_x+game_w*0.5, game_h*0.5);
      gameover--;
    } else {
      fill(240);
      textAlign(LEFT);

      set_font(30);
      text("SCORE : " + String.valueOf(score), game_x+game_w*0.2, 100);
      set_font(20);
      text("HI-SCORE : " + String.valueOf(hi_score), game_x+game_w*0.4, 150);
      if (hi_score_updated) {
        fill(240, 240, 150);
        textAlign(RIGHT);
        text("New Record! ", game_x+game_w*0.35, 150);
        fill(240);
      }
      set_font(30);

      textAlign(CENTER);
      text("Capture your textbook to restart", game_x+game_w*0.5, game_h*0.85);

      controller_checker_alpha = (1.0-controller_checker_alpha)*0.05+controller_checker_alpha;

      cont.draw_checker(1024, 1024, controller_checker_alpha);

      if (cinfo.check_passed == true && controller_checker_alpha >= 0.9) {
        se_start.play(0);
        set_phase(PHASE_GAME);
      }
    }
  }

  // 残り数表示のx座標を取得
  float get_vitality_ui_position_x(int i){
    return game_x+game_w*0.05*float(i+1);
  }

  // 残り数表示のy座標を取得
  float get_vitality_ui_position_y(){
    return game_h*0.05;
  }

  // ゲーム中の画面でのフレームごとの処理内容
  void game_process(controller_info cinfo) {
    draw_stage();
    
    
    cont.draw(1024, 1024, 0.2);
    if (controller_checker_alpha >= 0.01) {
      cont.draw_checker(1024, 1024, controller_checker_alpha);
      controller_checker_alpha *= 0.7;
    }
    process_particles();

    paddle.process(cinfo);
    int ball_collision_flag = ball.process(paddle, game_x, game_w, game_h);

    boolean ball_reflection = ball_collision_flag%2+(ball_collision_flag/2)%2+(ball_collision_flag/4)%2 != 0;
    if(ball_reflection) {
      se_reflection.play(0);
    }

    boolean ball_gone = (ball_collision_flag/8)%2 == 1;
    if (ball_gone) {
      decrease_vitality();
      se_meteo_fallen.play(0);
      generate_particle(PARTICLE_TYPE_METEO_FALLEN, ball.x, ball.y, ball.r);
    }

    paddle.draw();
    ball.draw(paddle);
    draw_particles();

    if (cinfo.knocked) {
      paddle.enbold();
      if(ball.is_laid == true){
        se_swing.play(0);
        ball.knock(paddle, game_x, game_w, game_h);
      }

    }

    meteo_time++;
    if (meteo_time > meteo_interval) {
      meteo_time = 0;

      if (meteo_interval > LAST_METEO_GENERATION_INTERVAL) {
        meteo_interval--;
      }

      meteo_data.add(
        new meteo_info(game_x, game_x+game_w, 0.0, 0.0, 
        35.0, 40.0, game_h, 0.3, 0.7)
        );
    }

    for (int i = 0; i < meteo_data.size(); i++) {
      meteo_info meteo = meteo_data.get(i);
      meteo_flag flag = meteo.process(ball);
      if (flag.broken) {
        meteo_data.remove(i);
        score += 100;
        se_meteo_broken.play(0);
        i--;
        continue;
      }
      if (flag.fallen) {
        meteo_data.remove(i);
        decrease_vitality();
        se_meteo_fallen.play(0);
        i--;
        continue;
      }
      meteo.draw();
    }

    fill(240);
    textAlign(LEFT);
    set_font(25);
    text("SCORE : " + String.valueOf(score), game_x+game_w*0.04, game_h*0.11);

    for (int i=0; i<vitality; i++){
      float vx = get_vitality_ui_position_x(i);
      float vy = get_vitality_ui_position_y();
      float r  = 20;
      stroke(210, 200);
      noFill();
      strokeWeight((40-TIME%40)/8);
      circle(vx, vy, r*(0.7+(0.3*float(TIME%40)/40.0)));

      fill(250, 200);
      noStroke();
      circle(vx, vy, r*0.7);
    }
  }


  // 残り数を一つ減らす
  void decrease_vitality() {
    vitality--;

    float vx = get_vitality_ui_position_x(vitality);
    float vy = get_vitality_ui_position_y();
    generate_particle(PARTICLE_TYPE_METEO_FALLEN, vx, vy, 20);

    if (vitality == 0) {
      for (int i = 0; i < meteo_data.size(); i++) {
        meteo_info meteo = meteo_data.get(i);
        generate_particle(PARTICLE_TYPE_METEO_FALLEN, meteo.x, meteo.y, meteo.wh);
      }
      generate_particle(PARTICLE_TYPE_METEO_FALLEN, ball.x, ball.y, ball.r*2);

      bgm_player.pause();

      se_destruction.play(0);
      set_phase(PHASE_RESULT);
    }

    
  }

  // 画面遷移を行う
  void set_phase(int _phase) {
    phase = _phase;
    switch (phase) {
    case PHASE_TITLE:
      {
        init_title();
        break;
      }
    case PHASE_GAME:
      {
        init_game();
        break;
      }
    case PHASE_RESULT:
      {
        init_result();
        break;
      }
    }
  }

  // フレームごとの処理を行う
  void main_process(controller_info cinfo) {
    switch (phase) {
    case PHASE_TITLE:
      {
        title_process(cinfo);
        break;
      }
    case PHASE_GAME:
      {
        game_process(cinfo);
        break;
      }
    case PHASE_RESULT:
      {
        result_process(cinfo);
        break;
      }
    }
  }
}
