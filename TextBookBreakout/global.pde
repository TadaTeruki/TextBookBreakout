// [ global.pde ] プログラム全体で共有される定数や変数の定義


// =========================================
// ---- プレイヤーが設定可能な定数 (変更可能) ----
// =========================================

// GAME_RESOLUTION: ウインドウの幅(=高さ)
//                  このゲームでは、ウインドウの幅の変更にも対応している
//                  ディスプレイの大きさが小さすぎる/大きすぎる場合は、この値を変更することで対応できる
final int GAME_RESOLUTION = 1024;




// ==============================================
// ---- 内部パラメータ用の定数 (変更可能だが非推奨) ----
// ==============================================

// CONTROLLER_PIXEL_INTERVAL: 教科書を認識するためにカメラの撮影データから参照するピクセルの間隔
//                            大きいと計算が少なくなる一方、認識精度に問題が生じやすくなる
final int   CONTROLLER_PIXEL_INTERVAL       = 5;

// MIN_PIXEL_RATIO: 青/緑 各色の認識ピクセル数の、カメラの撮影データ全体に対する割合の最小値
//                  この値より認識ピクセル数の割合が小さければ、コントローラは自身の情報を更新しない
final float MIN_PIXEL_RATIO                 = 0.015;

// COLOR_COGNITION_STRENGTH: 青/緑のピクセルを認識する際の、他の色の値の合計と比べた青/緑の強さの最小比率
final float COLOR_COGNITION_STRENGTH        = 1.05;

// CONTROLLER_UPDATE_TIME_INTERVAL: コントローラの情報を更新する間隔
final int   CONTROLLER_UPDATE_TIME_INTERVAL = 2;

// FIRST_METEO_GENERATION_INTERVAL: ゲーム開始時の隕石の生成間隔 
final int   FIRST_METEO_GENERATION_INTERVAL = 150;

// LAST_METEO_GENERATION_INTERVAL: 隕石の生成間隔の最小値 
final int   LAST_METEO_GENERATION_INTERVAL  = 40;

// METEO_ANIMATION_INTERVAL: 隕石のアニメーションの間隔
final int   METEO_ANIMATION_INTERVAL        = 50;

// MIN_UNRELIABLE_TIME_FOR_KNOCK, MAX_UNRELIABLE_TIME_FOR_KNOCK: 教科書の振り上げを認識する際の、教科書の動きの間隔の最小値と最大値
final int   MIN_UNRELIABLE_TIME_FOR_KNOCK   = 5;
final int   MAX_UNRELIABLE_TIME_FOR_KNOCK   = 25;

// CONTROLLER_CHECK_PROPORTION : 教科書認識チェック時(ゲーム開始時と再開時に行われる)の、ゲーム開始に必要な適合セルの数の最小割合
final float CONTROLLER_CHECK_PROPORTION     = 0.6;

// MAX_VITALITY: ゲーム開始時の残り数
final int   MAX_VITALITY                    = 5;

// MOUNTAIN_HEIGHT: 山の最大高さ
final int   MOUNTAIN_HEIGHT                 = 200;




// ==========================
// ---- 内部定数 (変更不可) ----
// ==========================

// BASE_RESOLUTION: 内部での処理に使うウインドウの幅と高さ
//                  実際のウインドウの解像度との差は、描画情報全体の拡縮によって保管される
final int BASE_RESOLUTION = 1024;

// BASE_WIDTH, BASE_HEIGHT: 内部での処理に使うウインドウの幅と高さ (BASE_RESOLUTIONと同値)
final int BASE_WIDTH      = BASE_RESOLUTION;
final int BASE_HEIGHT     = BASE_RESOLUTION;


// COLOR_***: 青/緑 の認識情報の管理に用いる色フラグ
final int COLOR_NONE   = 0; // なし
final int COLOR_BLUE   = 1; // 青
final int COLOR_GREEN  = 2; // 緑
final int COLOR_HIDDEN = 3; // 弱い青・緑

// PHASE_***: 画面の種類
final int PHASE_NONE        = 0; // なし
final int PHASE_TITLE       = 1; // タイトル画面
final int PHASE_GAME        = 2; // ゲーム画面
final int PHASE_RESULT      = 3; // 結果画面

// PARTICLE_***: パーティクルの集合の種類
final int PARTICLE_TYPE_NONE                = 0; // なし
final int PARTICLE_TYPE_METEO_TAIL          = 1; // 隕石の尾
final int PARTICLE_TYPE_METEO_BROKEN        = 2; // 隕石の破壊時の効果
final int PARTICLE_TYPE_METEO_FALLEN        = 3; // 隕石の地表落下時の効果
final int PARTICLE_TYPE_BALL_TAIL           = 4; // ボールの尾

// =====================
// ---- グローバル変数 ----
// =====================


// TIME: 時間
int TIME;

// DRAW_SCALE: 内部解像度に対する実際のウインドウの解像度の大きさ
float DRAW_SCALE;
