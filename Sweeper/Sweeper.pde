MineSweeper mineSweeper; //<>//

private final int rows = 15;      // 縦のマス目の数
private final int columns = 30;   // 横のマス目の数
private final int bombs = 100;    // 爆弾の数
private final int cellSize = 20;  // マス目の1辺の長さ

void settings() {
  size(columns*cellSize, rows*cellSize);
}

void setup() {
  // ゲームを初期化
  mineSweeper = new MineSweeper(rows, columns, bombs, cellSize);
}

void draw() {
  // どのマスを開けるかを決定する。
  // 人間が遊びたい時にはコメントアウトする。
  decide();

  // 盤面に応じて描画。ゲームオーバーならば全てオープンにして描画。
  mineSweeper.update();

  // ゲームクリア済みなので以降ループは回さない。
  if (mineSweeper.isGameCleared()) {
    noLoop();
  }

  // ゲームオーバーなので以降ループは回さない。
  if (mineSweeper.isGameOver()) {
    noLoop();
  }

  // オートプレイの場合、様子を見やすいように1秒停止。
  // 人間が遊びたい時にはコメントアウトする。
  delay(1000);
}

// マウスがクリックされた時に呼ばれる。
void mousePressed() {
  if (mouseButton == LEFT) {
    // 左クリックならば、そこのマス目をオープン。
    mineSweeper.open(mouseX, mouseY);
  } else if (mouseButton == RIGHT) {
    // 右クリックならば、そこのマス目に旗を立てる。
    // 既に旗が立っていれば、旗を消す。
    mineSweeper.mark(mouseX, mouseY);
  }
}

// オートプレイの挙動を決める。
void decide() {
  // 操作するマスをランダムに決定。
  int randomR = int(random(0, rows));
  int randomC = int(random(0, columns));

  // 指定したマスが開いているか、旗が立っている限り回るループ。
  do {
    randomR = int(random(0, rows));
    randomC = int(random(0, columns));
  } while (mineSweeper.isOpen(randomR, randomC) || mineSweeper.isMarked(randomR, randomC));

  if (mineSweeper.leftOpen() > (rows*columns-bombs)*0.9) {
    // 空きマス全体のうち9割以上が開いていなければ、指定したマスを開ける。
    mineSweeper.openByIndex(randomR, randomC);
  } else {
    if(mineSweeper.marked() > rows*columns-mineSweeper.leftOpen()-bombs){
      // 開けた数よりも旗の数が多ければ開ける。
      mineSweeper.openByIndex(randomR, randomC);
    } else{
      // 旗の数の方が少なければ旗を立てる。
      mineSweeper.markByIndex(randomR, randomC);
    }
  }
  
  // デバッグ用
  println("開けた数: " + (rows*columns-mineSweeper.leftOpen()-bombs) 
          + ", 旗の数: " + mineSweeper.marked()
          + ", 爆弾の数: " + bombs
          + ", 残りの空きマス数: " + mineSweeper.leftOpen());
}
