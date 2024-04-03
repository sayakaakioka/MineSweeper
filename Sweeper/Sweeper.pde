// マインスイーパーの盤面管理 //<>//
MineSweeper mineSweeper;

// 描画関連のツール
Drawer drawer;

final int ROWS = 15;      // 縦のマス目の数
final int COLUMNS = 30;   // 横のマス目の数
final int BOMBS = 100;    // 爆弾の数
final int CELLSIZE = 20;  // マス目の1辺の長さ

int startTime = 0; // 処理時間計測用

void settings() {
  size(COLUMNS*CELLSIZE, ROWS*CELLSIZE);
}

void setup() {
  // ゲームを初期化
  mineSweeper = new MineSweeper(ROWS, COLUMNS, BOMBS);
  drawer = new Drawer(mineSweeper, ROWS, COLUMNS, CELLSIZE);

  // 初期状態を描画
  drawer.init();

  // プログラムの開始時間を取得
  startTime = millis();
}

void draw() {
  // 前回の処理から1秒以上経っていたら、どのマスを開けるかを決定する。
  // 人間が遊びたい時にはコメントアウトする。
  if(millis()-startTime>=1000){
    decide();
    startTime = millis();
  }
  
  // 盤面に応じて描画。ゲームオーバーならば全てオープンにして描画。
  drawer.update();

  // ゲームクリア済みなので以降ループは回さない。
  if (mineSweeper.isGameCleared()) {
    noLoop();
  }

  // ゲームオーバーなので以降ループは回さない。
  if (mineSweeper.isGameOver()) {
    noLoop();
  }
}

// マウスがクリックされた時に呼ばれる。
void mousePressed() {
  if (mouseButton == LEFT) {
    // 左クリックならば、そこのマス目をオープン。
    drawer.open(mouseX, mouseY);
  } else if (mouseButton == RIGHT) {
    // 右クリックならば、そこのマス目に旗を立てる。
    // 既に旗が立っていれば、旗を消す。
    drawer.mark(mouseX, mouseY);
  }
}

// 最後にクリックしたマスの情報
int lastClickedR = -1;
int lastClickedC = -1;

// オートプレイの挙動を決める。
void decide() {
  // 先ほど開けたマスの周囲8マスの爆弾の数が3未満ならば
  // 近隣のマスを開ける
  if (lastClickedR != -1 && lastClickedC != -1 && mineSweeper.neighbors(lastClickedR, lastClickedC).id() < 3) {
    if (lastClickedR-1>=0 && !mineSweeper.isOpen(lastClickedR-1, lastClickedC)) {
      // 上が開けられるので上を開ける
      lastClickedR--;
      mineSweeper.open(lastClickedR, lastClickedC);
      return;
    } else if (lastClickedR+1<ROWS && !mineSweeper.isOpen(lastClickedR+1, lastClickedC)) {
      // 下が開けられるので下を開ける
      lastClickedR++;
      mineSweeper.open(lastClickedR, lastClickedC);
      return;
    } else if (lastClickedC-1>=0 && !mineSweeper.isOpen(lastClickedR, lastClickedC-1)) {
      // 左が開けられるので左を開ける
      lastClickedC--;
      mineSweeper.open(lastClickedR, lastClickedC);
      return;
    } else if (lastClickedC+1<COLUMNS && !mineSweeper.isOpen(lastClickedR, lastClickedC+1)) {
      // 右が開けられるので右を開ける
      lastClickedC++;
      mineSweeper.open(lastClickedR, lastClickedC);
      return;
    }
    // 近隣に開けられるマスがなかったので以下でランダムに開ける
  }

  // 操作するマスをランダムに決定。
  int randomR = int(random(0, ROWS));
  int randomC = int(random(0, COLUMNS));

  // 指定したマスが開いているか、旗が立っている限り回るループ。
  do {
    randomR = int(random(0, ROWS));
    randomC = int(random(0, COLUMNS));
  } while (mineSweeper.isOpen(randomR, randomC) || mineSweeper.isMarked(randomR, randomC));

  if (mineSweeper.leftOpen() > (ROWS*COLUMNS-BOMBS)*0.9) {
    // 空きマス全体のうち9割以上が開いていなければ、指定したマスを開ける。
    mineSweeper.open(randomR, randomC);
  } else {
    if (mineSweeper.marked() > ROWS*COLUMNS-mineSweeper.leftOpen()-BOMBS) {
      // 開けた数よりも旗の数が多ければ開ける。
      mineSweeper.open(randomR, randomC);
    } else {
      // 旗の数の方が少なければ旗を立てる。
      mineSweeper.mark(randomR, randomC);
    }
  }

  // 最後にクリックしたマス情報を更新
  lastClickedR = randomR;
  lastClickedC = randomC;

  // デバッグ用
  println("開けた数: " + (ROWS*COLUMNS-mineSweeper.leftOpen()-BOMBS)
    + ", 旗の数: " + mineSweeper.marked()
    + ", 爆弾の数: " + BOMBS
    + ", 残りの空きマス数: " + mineSweeper.leftOpen());
}
