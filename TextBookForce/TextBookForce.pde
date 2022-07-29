/*
=================
 TextBookForce
 制作: 多田 瑛貴
 2022-06-15
=================

 - あらすじ -

宇宙から未知の隕石群がやってきた！
このままでは地球は滅亡してしまいます.
華の未来大のエースとして選ばれしあなたは、
大量の隕石から、地球を守る役目を果たすこととなりました.

未来大生に託された最終兵器
“Processingプログラミングで学ぶ　情報表現入門”
 ( 美馬 義亮 先生著, 出版 : 公立はこだて未来大学出版会 ) 
を駆使し、地球の未来を守りましょう！

 - 操作方法 - 

 - 教科書をカメラにうつしてゲームスタート
 - カメラの前で、教科書を傾けたり横に移動すると、パドルが動く
 - ボールを放つ際は、教科書をカメラに写らなくなる角度まで前に傾け、すばやく戻す

*/


// コントローラの情報 (controller.pdeを参照)
controller  cont;
// ゲーム全体の情報 (gamehost.pdeを参照)
game_host   host;

// ウインドウのサイズの適用
public void settings() {
  size(GAME_RESOLUTION, GAME_RESOLUTION);
}

// 初期化
void setup() {
  // コントローラ、パーティクル、およびゲーム全体の初期化処理
  cont = new controller(this);
  host = new game_host(this, 0.8);
  init_particles();
  TIME = 0;
  DRAW_SCALE = float(width)/float(BASE_RESOLUTION);
}

// 描画
void draw() {
  TIME++;
  scale(DRAW_SCALE);
  controller_info cinfo = cont.update();
  host.main_process(cinfo);
}

void stop() {
  host.minim.stop();
  super.stop();
}