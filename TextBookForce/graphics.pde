// [ graphics.pde ] 描画に用いる関数の定義


// 2つの色を一定の割合で混ぜた色を出力
color blend_color(float pos, color c1, color c2) {
  float inv_pos = 1.0 - pos;
  return color(red(c1)*pos + red(c2)*inv_pos, green(c1)*pos + green(c2)*inv_pos, blue(c1)*pos + blue(c2)*inv_pos);
}

// Processingの標準関数'noise()'の出力するノイズを、さらに細かくする処理
float octaved_noise(float x, float y, float z, int oct, float persistence) {
  float sum_noise = 0.0;
  float frequency = 1.0;
  float ampl = 1.0;
  float sum_scale = 0.0;

  for (int i = 0; i < oct; i++) {
    sum_scale += ampl;
    sum_noise += noise(x*frequency, y*frequency, z*frequency) * ampl;
    ampl *= persistence;
    frequency *= 2;
  }
  return sum_noise/sum_scale;
}
