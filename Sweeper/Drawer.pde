/**
 * 盤面を描画するための諸々を提供
 */
class Drawer {
  private final MineSweeper mineSweeper;
  private final int rows;
  private final int columns;
  private final int cellSize;
  private final color bgColor = color(171, 171, 171);
  private final color fgColor = color(0, 0, 0);

  public Drawer(MineSweeper mineSweeper, int rows, int columns, int cellSize) {
    this.mineSweeper = mineSweeper;
    this.rows = rows;
    this.columns = columns;
    this.cellSize = cellSize;
  }

  /**
   * ゲームの初期状態を描画
   */
  public void init() {
    // 全てのセルが伏せられた状態でスタート。
    background(bgColor);
    drawLines();
  }

  /**
   * クリックされたマスに旗を立てる。
   */
  public void mark(int x, int y) {
    mineSweeper.mark(y/cellSize, x/cellSize);
  }

  /**
   * マウスの座標からクリックされたマスを開ける。
   * 開けたマスが、周囲8マスが爆弾なしの場合には、これらも開ける。
   */
  public void open(int x, int y) {
    mineSweeper.open(y/cellSize, x/cellSize);
  }

  /**
   * ゲームの状況に合わせて描画する。
   */
  public void update() {
    // セルが閉じている状態の色で一旦塗りつぶし。
    background(bgColor);

    for (int i=0; i<this.rows; i++) {
      for (int j=0; j<this.columns; j++) {
        if (mineSweeper.status(i, j) == Status.OPENED) {
          // 開いているマス
          drawOpenCell(i, j);
          if (mineSweeper.neighbors(i, j) == BombInfo.TRAPPED) {
            // 爆弾のマス
            drawBomb(i, j);
          } else {
            // 何もないマス
            drawNumber(i, j);
          }
        } else if (!mineSweeper.isGameOver() && mineSweeper.status(i, j) == Status.MARKED) {
          // 旗が立っているマス
          drawFlag(i, j);
        } else if (mineSweeper.isGameOver() && mineSweeper.neighbors(i, j) == BombInfo.TRAPPED) {
          // ゲームオーバーで爆弾のマス
          drawBomb(i, j);
        }
      }
    }

    // セルの境界線を描く。
    drawLines();

    if (mineSweeper.isGameOver()) {
      // ゲームオーバー表示
      fill(255, 0, 0);
      textSize(40);
      text("GAME OVER", width/2, height/2);
    } else if (mineSweeper.isGameCleared()) { // ゲームクリア表示
      textSize(40);
      fill(255, 0, 0);
      text("CLEAR!", width/2, height/2);
    }
  }

  /**
   * 指定したマスに爆弾を描く。
   */
  private void drawBomb(int r, int c) {
    textAlign(CENTER, CENTER);
    fill(255, 0, 0);
    textSize(10);
    text("x", (c+0.5)*cellSize, (r+0.5)*cellSize);
  }

  /**
   * 指定したマスに旗を描く。
   */
  private void drawFlag(int r, int c) {
    textAlign(CENTER, CENTER);
    fill(210, 105, 30);
    textSize(10);
    text("F", (c+0.5)*cellSize, (r+0.5)*cellSize);
  }

  // マスの境界線を描く。
  private void drawLines() {
    stroke(fgColor);

    // 縦方向
    int x = cellSize;
    while (x<width) {
      line(x, 0, x, height);
      x += cellSize;
    }

    // 横方向
    int y = cellSize;
    while (y<height) {
      line(0, y, width, y);
      y += cellSize;
    }
  }

  /**
   * 指定したマスの周囲8マスの爆弾の数を描く。ゼロや爆弾なら描かない。
   */
  private void drawNumber(int r, int c) {
    textAlign(CENTER, CENTER);
    textSize(10);

    switch(mineSweeper.neighbors(r, c)) {
    case TRAPPED:
    case NONE:
    case UNKNOWN:
      return;
    case ONE:
      fill(0, 0, 255);
      break;
    case TWO:
      fill(0, 128, 0);
      break;
    case THREE:
      fill(255, 0, 0);
      break;
    case FOUR:
      fill(35, 59, 108);
      break;
    case FIVE:
      fill(134, 74, 43);
      break;
    case SIX:
      fill(0, 156, 209);
      break;
    case SEVEN:
      fill(0, 0, 0);
      break;
    case EIGHT:
      fill(119, 119, 119);
      break;
    }

    text(mineSweeper.neighbors(r, c).id(), (c+0.5)*cellSize, (r+0.5)*cellSize);
  }

  /**
   * 開いているマスを指定した位置に描く。
   */
  private void drawOpenCell(int r, int c) {
    if (mineSweeper.isLastClicked(r, c)) { // 最後にクリックしたマスは特別な色で
      fill(255, 255, 0);
    } else { // 最後にクリックしたマスでなければ普通の色で
      fill(226, 226, 226);
    }
    rect(c*cellSize, r*cellSize, cellSize, cellSize);
  }
}
